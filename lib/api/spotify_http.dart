import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

typedef LunalistTrack = ({
  String id,
  String name,
  String artist,
  String artwork,
  int year,
});

class SpotifyHttp {
  SpotifyHttp({
    required this.clientId,
    required this.clientSecret,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String clientId;
  final String clientSecret;
  final http.Client _http;

  String? _token;
  DateTime? _tokenExpiresAt;

  Future<bool> testConnection({String market = "DE"}) async {
    try {
      final token = await _getAccessToken();

      final uri = Uri.https("api.spotify.com", "/v1/markets");

      final resp = await _http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      if (resp.statusCode != 200) return false;

      // optional: prüfen ob DE enthalten ist
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final markets = (body["markets"] as List?)?.cast<String>() ?? const <String>[];
      if (markets.isEmpty) return false;

      return markets.contains(market);
    } catch (_) {
      return false;
    }
  }

  static String playlistUrlToId(String url) {
    final match = RegExp(r"open\.spotify\.com\/playlist\/([^?\/]+)").firstMatch(url);
    if (match == null) throw FormatException("Ungültige Playlist-URL");
    return match.group(1)!;
  }

  Future<String> _getAccessToken() async {
    final now = DateTime.now();
    if (_token != null && _tokenExpiresAt != null && now.isBefore(_tokenExpiresAt!)) {
      return _token!;
    }

    final basic = base64Encode(utf8.encode("$clientId:$clientSecret"));

    final resp = await _http.post(
      Uri.parse("https://accounts.spotify.com/api/token"),
      headers: {
        "Authorization": "Basic $basic",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {"grant_type": "client_credentials"},
    );

    if (resp.statusCode != 200) {
      throw Exception("Token fehlgeschlagen (${resp.statusCode}): ${resp.body}");
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final token = json["access_token"] as String;
    final expiresIn = (json["expires_in"] as num).toInt(); // in seconds

    _token = token;
    _tokenExpiresAt = now.add(Duration(seconds: expiresIn - 30)); // puffer
    return token;
  }

  Future<List<LunalistTrack>> getPlaylistTracks({
    required String playlistUrl,
    String market = "DE",
  }) async {
    final playlistId = playlistUrlToId(playlistUrl);
    final token = await _getAccessToken();

    const limit = 50;
    var offset = 0;

    final List<LunalistTrack> out = [];

    while (true) {
      final uri = Uri.https(
        "api.spotify.com",
        "/v1/playlists/$playlistId/tracks",
        {
          "market": market,
          "limit": "$limit",
          "offset": "$offset",
          "fields": "items(is_local,track(id,name,is_playable,restrictions,artists(name),album(release_date,images(url)))),total",
        },
      );

      final resp = await _http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      if (resp.statusCode == 404) {
        throw Exception("Playlist nicht gefunden (404).");
      }
      if (resp.statusCode == 401) {
        // Token expired
        _token = null;
        _tokenExpiresAt = null;
        final retryToken = await _getAccessToken();
        final retryResp = await _http.get(uri, headers: {"Authorization": "Bearer $retryToken"});
        if (retryResp.statusCode != 200) {
          throw Exception("Spotify-Request fehlgeschlagen (${retryResp.statusCode}): ${retryResp.body}");
        }
        return _parseAndCollect(retryResp.body, out, market, limit, () => offset += limit);
      }

      if (resp.statusCode != 200) {
        throw Exception("Spotify-Request fehlgeschlagen (${resp.statusCode}): ${resp.body}");
      }

      final done = _parsePageAndAppend(resp.body, out, market);
      offset += limit;
      if (done) break;
    }

    debugPrint("tracks collected: ${out.length}");
    return out;
  }

  // returns true if last page
  bool _parsePageAndAppend(String body, List<LunalistTrack> out, String market) {
    final root = jsonDecode(body) as Map<String, dynamic>;
    final items = (root["items"] as List?) ?? const [];

    for (final it in items) {
      final m = it as Map<String, dynamic>;

      if (m["is_local"] == true) continue;

      final track = m["track"] as Map<String, dynamic>?;
      if (track == null) continue;

      // not playable
      if (track["is_playable"] == false) continue;

      // if restrictions
      if (track["restrictions"] != null) continue;

      final id = track["id"] as String?;
      if (id == null) continue;

      final name = (track["name"] as String?) ?? "";

      final artists = (track["artists"] as List?) ?? const [];
      final artist = artists.isNotEmpty
          ? ((artists.first as Map<String, dynamic>)["name"] as String? ?? "")
          : "";

      final album = track["album"] as Map<String, dynamic>?;
      final releaseDate = (album?["release_date"] as String?) ?? "";
      final year = int.tryParse(releaseDate.split("-").first) ?? 0;

      final images = (album?["images"] as List?) ?? const [];
      final artwork = images.isNotEmpty
          ? ((images.first as Map<String, dynamic>)["url"] as String? ?? "")
          : "";

      out.add((
        id: id,
        name: name,
        artist: artist,
        artwork: artwork,
        year: year,
      ));
    }

    // last page, less than limit
    return items.length < 50;
  }

  // helper for 401 retry
  List<LunalistTrack> _parseAndCollect(
    String body,
    List<LunalistTrack> out,
    String market,
    int limit,
    void Function() bumpOffset,
  ) {
    while (true) {
      final done = _parsePageAndAppend(body, out, market);
      bumpOffset();
      if (done) break;
      // Retry Helper stuff?
      break;
    }
    return out;
  }

  void dispose() => _http.close();
}