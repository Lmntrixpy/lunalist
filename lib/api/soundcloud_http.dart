import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

typedef LunalistTrack = ({
  String id,
  String name,
  String artist,
  String artwork,
  int year,
});

class SoundCloudHttp {
  SoundCloudHttp({
    required this.clientId,
    required this.clientSecret,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String clientId;
  final String clientSecret;
  final http.Client _http;

  String? _token;
  DateTime? _tokenExpiresAt;
  String? _refreshToken;

  Future<bool> testConnection() async {
    try {
      final token = await _getAccessToken();

      // öffentliche Suche (erfordert nur App-Token)
      final uri = Uri.https("api.soundcloud.com", "/tracks", {
        "q": "test",
        "limit": "1",
        "linked_partitioning": "true",
        "access": "playable",
      });

      final resp = await _http.get(
        uri,
        headers: _authHeaders(token),
      );

      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> playlistUrlToId(String playlistUrl) async {
    final token = await _getAccessToken();

    final uri = Uri.https("api.soundcloud.com", "/resolve", {
      "url": playlistUrl,
    });

    final resp = await _http.get(uri, headers: _authHeaders(token));

    if (resp.statusCode == 401) {
      await _invalidateTokenAndRetry();
      return playlistUrlToId(playlistUrl);
    }
    if (resp.statusCode != 200) {
      throw Exception("Resolve fehlgeschlagen (${resp.statusCode}): ${resp.body}");
    }

    final json = jsonDecode(resp.body);

    if (json is! Map<String, dynamic>) {
      throw Exception("Resolve: unerwartete Antwort.");
    }

    final kind = (json["kind"] as String?) ?? "";
    if (kind != "playlist") {
      throw Exception("URL ist keine Playlist (kind=$kind).");
    }

    final id = json["id"];
    if (id != null) return id.toString();

    final urn = json["urn"];
    if (urn != null) return urn.toString();

    throw Exception("Resolve: keine id/urn gefunden.");
  }

  Future<Uri> getPlayableStreamUrl({required String trackId}) async {
    var token = await _getAccessToken();

    // get track Metadata & check playable
    final trackUri = Uri.https("api.soundcloud.com", "/tracks/$trackId");
    final trackResp = await _http.get(trackUri, headers: _authHeaders(token));

    if (trackResp.statusCode == 401) {
      await _invalidateTokenAndRetry();
      token = await _getAccessToken();
      return getPlayableStreamUrl(trackId: trackId);
    }
    if (trackResp.statusCode != 200) {
      throw Exception("Track-Request fehlgeschlagen (${trackResp.statusCode}): ${trackResp.body}");
    }

    final trackJson = jsonDecode(trackResp.body) as Map<String, dynamic>;

    final access = (trackJson["access"] as String?) ?? "";
    final streamUrl = (trackJson["stream_url"] as String?) ?? "";

    if (access == "blocked" || streamUrl.isEmpty) {
      throw Exception("Track ist nicht streamable (access=$access).");
    }

    final streamsUri = Uri.https("api.soundcloud.com", "/tracks/$trackId/streams");
    final streamsResp = await _http.get(streamsUri, headers: _authHeaders(token));

    if (streamsResp.statusCode == 401) {
      await _invalidateTokenAndRetry();
      token = await _getAccessToken();
      final retry = await _http.get(streamsUri, headers: _authHeaders(token));
      if (retry.statusCode != 200) {
        return _resolveRedirectStreamUrl(Uri.parse(streamUrl), token);
      }
      return _pickBestFromStreamsJson(retry.body);
    }

    if (streamsResp.statusCode == 200) {
      return _pickBestFromStreamsJson(streamsResp.body);
    }

    return _resolveRedirectStreamUrl(Uri.parse(streamUrl), token);
  }

  Future<Uri> _resolveRedirectStreamUrl(Uri streamUrl, String token) async {
    final req = http.Request("GET", streamUrl)
      ..headers.addAll(_authHeaders(token))
      ..followRedirects = false;

    final streamed = await _http.send(req);

    if (streamed.statusCode == 302 || streamed.statusCode == 301) {
      final loc = streamed.headers["location"];
      if (loc == null || loc.isEmpty) {
        throw Exception("Redirect ohne Location Header.");
      }
      return Uri.parse(loc);
    }

    final text = await streamed.stream.bytesToString();
    throw Exception("stream_url unerwartet (${streamed.statusCode}): $text");
  }

  Future<String> _getAccessToken() async {
    final now = DateTime.now();
    if (_token != null && _tokenExpiresAt != null && now.isBefore(_tokenExpiresAt!)) {
      return _token!;
    }

    // client creds flow
    final basic = base64Encode(utf8.encode("$clientId:$clientSecret"));

    final resp = await _http.post(
      Uri.parse("https://secure.soundcloud.com/oauth/token"),
      headers: {
        "Accept": "application/json; charset=utf-8",
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Basic $basic",
      },
      body: {
        "grant_type": "client_credentials",
      },
    );

    if (resp.statusCode != 200) {
      throw Exception("Token fehlgeschlagen (${resp.statusCode}): ${resp.body}");
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final token = (json["access_token"] as String?) ?? "";
    if (token.isEmpty) {
      throw Exception("Token-Antwort ohne access_token: ${resp.body}");
    }

    final expiresIn = (json["expires_in"] as num?)?.toInt() ?? 3600;
    _refreshToken = json["refresh_token"] as String?;
    _token = token;
    _tokenExpiresAt = now.add(Duration(seconds: expiresIn - 30)); // puffer
    return token;
  }

  Future<void> _invalidateTokenAndRetry() async {
    _token = null;
    _tokenExpiresAt = null;

    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      try {
        final refreshed = await _refreshAccessToken(_refreshToken!);
        _token = refreshed;
        return;
      } catch (_) {
        // fallback
      }
    }

    await _getAccessToken();
  }

  Future<String> _refreshAccessToken(String refreshToken) async {
    final resp = await _http.post(
      Uri.parse("https://secure.soundcloud.com/oauth/token"),
      headers: {
        "Accept": "application/json; charset=utf-8",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "grant_type": "refresh_token",
        "client_id": clientId,
        "client_secret": clientSecret,
        "refresh_token": refreshToken,
      },
    );

    if (resp.statusCode != 200) {
      throw Exception("Refresh Token fehlgeschlagen (${resp.statusCode}): ${resp.body}");
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final token = (json["access_token"] as String?) ?? "";
    if (token.isEmpty) throw Exception("Refresh: keine access_token.");

    final expiresIn = (json["expires_in"] as num?)?.toInt() ?? 3600;
    _refreshToken = json["refresh_token"] as String? ?? _refreshToken;

    final now = DateTime.now();
    _tokenExpiresAt = now.add(Duration(seconds: expiresIn - 30));
    return token;
  }

  Map<String, String> _authHeaders(String token) => {
        "Accept": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      };

  Future<List<LunalistTrack>> getPlaylistTracks({
    required String playlistUrl,
  }) async {
    final playlistId = await playlistUrlToId(playlistUrl);
    var token = await _getAccessToken();

    final List<LunalistTrack> out = [];

    Uri next = Uri.https(
      "api.soundcloud.com",
      "/playlists/$playlistId/tracks",
      {
        "linked_partitioning": "true",
        "limit": "50",
        "access": "playable",
      },
    );

    while (true) {
      final resp = await _http.get(next, headers: _authHeaders(token));

      if (resp.statusCode == 401) {
        await _invalidateTokenAndRetry();
        token = await _getAccessToken();
        final retry = await _http.get(next, headers: _authHeaders(token));
        if (retry.statusCode != 200) {
          throw Exception("SoundCloud-Request fehlgeschlagen (${retry.statusCode}): ${retry.body}");
        }
        _parseTracksPageAndAppend(retry.body, out);
        next = _nextHrefFromBody(retry.body) ?? Uri();
        if (next.toString().isEmpty) break;
        continue;
      }

      if (resp.statusCode == 404) {
        final fallback = await _tryPlaylistDetailsTracks(playlistId, token, out);
        debugPrint("tracks collected: ${fallback.length}");
        return fallback;
      }

      if (resp.statusCode != 200) {
        throw Exception("SoundCloud-Request fehlgeschlagen (${resp.statusCode}): ${resp.body}");
      }

      _parseTracksPageAndAppend(resp.body, out);

      final nh = _nextHrefFromBody(resp.body);
      if (nh == null) break;
      next = nh;
    }

    debugPrint("tracks collected: ${out.length}");
    return out;
  }

  Future<List<LunalistTrack>> _tryPlaylistDetailsTracks(
    String playlistId,
    String token,
    List<LunalistTrack> out,
  ) async {
    final uri = Uri.https("api.soundcloud.com", "/playlists/$playlistId", {
      "show_tracks": "true",
    });

    final resp = await _http.get(uri, headers: _authHeaders(token));
    if (resp.statusCode != 200) {
      throw Exception("Playlist nicht gefunden/zugreifbar (${resp.statusCode}): ${resp.body}");
    }

    final root = jsonDecode(resp.body);
    if (root is! Map<String, dynamic>) return out;

    final tracks = (root["tracks"] as List?) ?? const [];
    for (final t in tracks) {
      final m = t as Map<String, dynamic>;
      final parsed = _mapTrackToLunalist(m);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  void _parseTracksPageAndAppend(String body, List<LunalistTrack> out) {
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      final coll = (decoded["collection"] as List?) ?? const [];
      for (final item in coll) {
        if (item is! Map<String, dynamic>) continue;
        final parsed = _mapTrackToLunalist(item);
        if (parsed != null) out.add(parsed);
      }
      return;
    }

    if (decoded is List) {
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final parsed = _mapTrackToLunalist(item);
        if (parsed != null) out.add(parsed);
      }
      return;
    }

    throw Exception("Unerwartetes Response-Format.");
  }

  Uri? _nextHrefFromBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;

    final nh = decoded["next_href"];
    if (nh is! String || nh.isEmpty) return null;

    return Uri.parse(nh);
  }

  LunalistTrack? _mapTrackToLunalist(Map<String, dynamic> track) {
    // filter: playable
    final access = track["access"];
    if (access is String && access.isNotEmpty && access != "playable") {
      return null;
    }

    final id = track["id"]?.toString();
    if (id == null || id.isEmpty) return null;

    final title = (track["title"] as String?) ?? "";
    if (title.isEmpty) return null;

    // Artist -> Uploader
    String artist = "";
    final user = track["user"];
    if (user is Map<String, dynamic>) {
      artist = (user["username"] as String?) ?? "";
    }

    // Artwork
    final artwork = (track["artwork_url"] as String?) ?? "";

    // Year
    int year = 0;
    final releaseDate = track["release_date"];
    if (releaseDate is String && releaseDate.isNotEmpty) {
      final y = releaseDate.split(RegExp(r"[-T/ ]")).first;
      year = int.tryParse(y) ?? 0;
    } else {
      final ry = track["release_year"];
      if (ry is int) year = ry;
      if (ry is String) year = int.tryParse(ry) ?? 0;
    }

    return (
      id: id,
      name: title,
      artist: artist,
      artwork: artwork,
      year: year,
    );
  }

  Future<({Uri uri, Map<String, String> headers})> getPlayableSource({
    required String trackId,
  }) async {
    var token = await _getAccessToken();

    final streamsUri = Uri.https("api.soundcloud.com", "/tracks/$trackId/streams");
    final streamsResp = await _http.get(streamsUri, headers: _authHeaders(token));

    if (streamsResp.statusCode == 401) {
      await _invalidateTokenAndRetry();
      token = await _getAccessToken();
      return getPlayableSource(trackId: trackId);
    }

    Uri picked;
    if (streamsResp.statusCode == 200) {
      picked = _pickBestFromStreamsJson(streamsResp.body);
    } else {
      final trackUri = Uri.https("api.soundcloud.com", "/tracks/$trackId");
      final trackResp = await _http.get(trackUri, headers: _authHeaders(token));
      if (trackResp.statusCode != 200) {
        throw Exception("Track-Request fehlgeschlagen (${trackResp.statusCode}): ${trackResp.body}");
      }
      final trackJson = jsonDecode(trackResp.body) as Map<String, dynamic>;
      final streamUrl = (trackJson["stream_url"] as String?) ?? "";
      if (streamUrl.isEmpty) throw Exception("Track hat keine stream_url.");
      picked = Uri.parse(streamUrl);
    }

    final resolved = await _resolveToFinalUrl(picked, token);

    final headers = (resolved.host == "api.soundcloud.com")
        ? _authHeaders(token)
        : <String, String>{};

    if (resolved.scheme != "https") {
      throw Exception("Nicht-HTTPS Stream URL (ATS blockt): $resolved");
    }

    return (uri: resolved, headers: headers);
  }

  Uri _pickBestFromStreamsJson(String body) {
    final streamsJson = jsonDecode(body) as Map<String, dynamic>;

    // for Apple mp3
    final preferKeysApple = <String>[
      "http_mp3_128_url",
      "preview_mp3_128_url",
      "hls_aac_160_url",
      "hls_aac_96_url",
      "hls_mp3_128_url",
    ];

    // for others HLS
    final preferKeysOther = <String>[
      "hls_aac_160_url",
      "hls_aac_96_url",
      "http_mp3_128_url",
      "preview_mp3_128_url",
      "hls_mp3_128_url",
    ];

    final keys = (Platform.isIOS || Platform.isMacOS) ? preferKeysApple : preferKeysOther;

    for (final k in keys) {
      final v = streamsJson[k];
      if (v is String && v.isNotEmpty) return Uri.parse(v);
    }

    throw Exception("Kein unterstützter Stream in /streams gefunden.");
  }

  Future<Uri> _resolveToFinalUrl(Uri url, String token) async {
    Uri current = url;

    // up to 6 redirects
    for (var i = 0; i < 6; i++) {
      final headers = (current.host == "api.soundcloud.com")
          ? _authHeaders(token)
          : <String, String>{};

      final req = http.Request("GET", current)
        ..headers.addAll(headers)
        ..followRedirects = false;

      final resp = await _http.send(req);

      // 301/302/303/307/308 -> follow location
      if (resp.statusCode == 301 ||
          resp.statusCode == 302 ||
          resp.statusCode == 303 ||
          resp.statusCode == 307 ||
          resp.statusCode == 308) {
        final loc = resp.headers["location"];
        if (loc == null || loc.isEmpty) return current;
        current = Uri.parse(loc);
        continue;
      }

      // no redirect left
      return current;
    }

    return current;
  }

  void dispose() => _http.close();
}