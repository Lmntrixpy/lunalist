// ignore: file_names
import 'package:flutter/foundation.dart';
import 'package:spotify/spotify.dart';
import 'package:hitster_2/config.dart';

late SpotifyApi spotify;

class SpotifyInterface {
  static Future<Iterable<PlaylistTrack>> playlistTracks = Future.error("Playlist not loaded");
  static Future<Track> track = Future.error("Track not loaded");
  static String year = "";

  void authorize() {
    final credentials = SpotifyApiCredentials(AppConfig.clientId, AppConfig.clientSecret);
    spotify = SpotifyApi(credentials);
  }

  static String urlToId(String url) {
    debugPrint("------ in urlToId ------");
    // Playlist URL:        https://open.spotify.com/playlist/34i2Aqmw8bgfxfardWSbNg?si=d3f28ff72605449d
    // Track URL Desktop:   https://open.spotify.com/intl-de/track/2IODVe96sL1fkhcfRgqQ0s?si=da7726c005124baf
    // Track URL Mobile:    https://open.spotify.com/track/2IODVe96sL1fkhcfRgqQ0s?si=Z-NQ4THPRwWre2TnoLn1bg

    final match = RegExp(r"playlist\/([^?]+)").firstMatch(url);
    if (match == null) {
      throw FormatException("Ungültige Playlist-URL");
    }
    debugPrint("Extracted ID: ${match.group(1)}");
    return match.group(1)!;
  }
  
  static Future<List<({int year, String name, String artist, String artwork, String id})>>
    getPlaylistTracks(String url) async {

      Iterable<PlaylistTrack> playlistTracks = [];

      try {
        playlistTracks = await spotify.playlists.getPlaylistTracks(urlToId(url)).all();

      } on ApiRateException catch (e) {
        print('Rate limit reached: ${e.message}');
      }

      return playlistTracks
          .map((pt) => pt.track)
          .whereType<Track>()
          .where((t) => 
            // t.isPlayable == true && // check if track is available (not working)
            t.id != null &&
            t.artists != null &&
            t.artists!.isNotEmpty &&
            t.album != null &&
            t.album!.images != null &&
            t.album!.images!.isNotEmpty &&
            t.album!.releaseDate != null &&
            int.tryParse(t.album!.releaseDate!.split("-").first) != null) // check and get release year
          .map((t) => (
                id: t.id!,
                year: int.tryParse(t.album?.releaseDate?.split("-").first ?? "") ?? 0,
                name: t.name ?? "",
                artist: t.artists?.first.name ?? "",
                artwork: t.album?.images?.first.url ?? "",
              ))
          .toList();
  }

  static Future<bool> testConnection() async {
    try {
      await spotify.search.get("Lady Gaga").first;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Deprecated: will be removed on next release
  static Future<({int year, String name, String artist, String artwork})> getTrackMetadata(String id) async {
  final track = await spotify.tracks.get(id);

  return (
    year: int.tryParse(track.album?.releaseDate?.split("-").first ?? "") ?? 0,
    name: track.name ?? "",
    artist: track.artists?.first.name ?? "",
    artwork: track.album?.images?.first.url ?? "");
  }
}