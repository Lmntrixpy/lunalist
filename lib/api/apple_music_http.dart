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

class AppleMusicHttp {
  AppleMusicHttp({
    required String developerToken,
    http.Client? httpClient,
    this.defaultStorefront = "de",
    Future<String> Function()? developerTokenProvider,
  })  : _developerToken = developerToken,
        _developerTokenProvider = developerTokenProvider,
        _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Apple Music storefront, e.g. "de", "us"
  final String defaultStorefront;

  String _developerToken;
  final Future<String> Function()? _developerTokenProvider;

  Future<String> _getDeveloperToken() async {
    if (_developerTokenProvider != null) {
      try {
        _developerToken = await _developerTokenProvider();
      } catch (_) {
        // keep existing token if provider fails
      }
    }
    return _developerToken;
  }
  Future<bool> testConnection({String? storefront}) async {
    final sf = (storefront ?? defaultStorefront).toLowerCase();
    try {
      final token = await _getDeveloperToken();
      final uri = Uri.https("api.music.apple.com", "/v1/catalog/$sf/genres", {"limit": "1"});

      final resp = await _http.get(uri, headers: {
        "Authorization": "Bearer $token",
      });

      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static String playlistUrlToId(String url) {
    final u = Uri.tryParse(url);
    if (u == null) throw FormatException("Ungültige Playlist-URL");

    // find a segment starting with "pl."
    for (final seg in u.pathSegments) {
      if (seg.startsWith("pl.")) return seg;
    }

    final m = RegExp(r"(pl\.[A-Za-z0-9\.\-_]+)").firstMatch(url);
    if (m != null) return m.group(1)!;

    throw FormatException("Ungültige Playlist-URL (keine pl.-ID gefunden)");
  }


  Uri _resolveNext(String next) {
    final parsed = Uri.parse(next);
    if (parsed.hasScheme) return parsed; // if already absolute
    return Uri.parse("https://api.music.apple.com$next");
  }

  Future<List<LunalistTrack>> getPlaylistTracks({
    required String playlistUrl,
    String? storefront,
  }) async {
    final sf = (storefront ?? defaultStorefront).toLowerCase();
    final playlistId = playlistUrlToId(playlistUrl);
    final token = await _getDeveloperToken();

    var uri = Uri.https(
      "api.music.apple.com",
      "/v1/catalog/$sf/playlists/$playlistId",
      {"include": "tracks"},
    );

    final List<LunalistTrack> out = [];

    while (true) {
      final resp = await _http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      if (resp.statusCode == 404) {
        throw Exception("Playlist nicht gefunden (404).");
      }
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw Exception("Apple Music Auth fehlgeschlagen (${resp.statusCode}): ${resp.body}");
      }
      if (resp.statusCode != 200) {
        throw Exception("Apple Music Request fehlgeschlagen (${resp.statusCode}): ${resp.body}");
      }

      final nextUrl = _parsePlaylistOrTracksResponseAndAppend(resp.body, out);
      if (nextUrl == null) break;

      uri = _resolveNext(nextUrl);
    }

    debugPrint("tracks collected: ${out.length}");
    return out;
  }

  String? _parsePlaylistOrTracksResponseAndAppend(String body, List<LunalistTrack> out) {
    final root = jsonDecode(body) as Map<String, dynamic>;

    final data = (root["data"] as List?) ?? const [];
    if (data.isNotEmpty) {
      final first = data.first as Map<String, dynamic>;
      final rel = first["relationships"] as Map<String, dynamic>?;
      final tracksRel = rel?["tracks"] as Map<String, dynamic>?;
      if (tracksRel != null) {
        final next = tracksRel["next"] as String?;
        final tracksData = (tracksRel["data"] as List?) ?? const [];
        _appendTracksData(tracksData, out);
        return next;
      }
    }

    final tracksData = (root["data"] as List?) ?? const [];
    if (tracksData.isNotEmpty) {
      _appendTracksData(tracksData, out);
      return root["next"] as String?;
    }

    return null;
  }

  void _appendTracksData(List tracksData, List<LunalistTrack> out) {
    for (final it in tracksData) {
      final m = it as Map<String, dynamic>;

      final id = (m["id"] as String?) ?? "";
      if (id.isEmpty) continue;

      final attributes = m["attributes"] as Map<String, dynamic>?;

      final name = (attributes?["name"] as String?) ?? "";
      final artist = (attributes?["artistName"] as String?) ?? "";

      final releaseDate = (attributes?["releaseDate"] as String?) ?? "";
      final year = int.tryParse(releaseDate.split("-").first) ?? 0;

      final artworkObj = attributes?["artwork"] as Map<String, dynamic>?;
      final artwork = _artworkUrl(artworkObj);

      out.add((
        id: id,
        name: name,
        artist: artist,
        artwork: artwork,
        year: year,
      ));
    }
  }

  String _artworkUrl(Map<String, dynamic>? artworkObj, {int w = 640, int h = 640}) {
    final url = (artworkObj?["url"] as String?) ?? "";
    if (url.isEmpty) return "";
    return url.replaceAll("{w}", "$w").replaceAll("{h}", "$h");
  }

  void dispose() => _http.close();
}