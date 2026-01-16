import 'package:flutter/foundation.dart';
import 'package:spotify/spotify.dart';
import 'package:hitster_2/config.dart';

late SpotifyApi spotify;

class SpotifyInterface {
  static Future<Iterable<PlaylistTrack>> playlistTracks = Future.error("Playlist not loaded");
  static Future<Track> track = Future.error("Track not loaded");
  static String year = "";

  bool authorize() {
    final credentials = SpotifyApiCredentials(AppConfig.clientId, AppConfig.clientSecret);
    spotify = SpotifyApi(credentials);
    return true;
  }

  String urlToId(String url) {
    debugPrint("------ in urlToId ------");
    // Playlist URL:        https://open.spotify.com/playlist/34i2Aqmw8bgfxfardWSbNg?si=d3f28ff72605449d
    // Track URL Desktop:   https://open.spotify.com/intl-de/track/2IODVe96sL1fkhcfRgqQ0s?si=da7726c005124baf
    // Track URL Mobile:    https://open.spotify.com/track/2IODVe96sL1fkhcfRgqQ0s?si=Z-NQ4THPRwWre2TnoLn1bg

    final match = RegExp(r"playlist\/([^?]+)").firstMatch(url);
    if (match == null) {
      throw FormatException("Ungültige Playlist-URL");
    }
    return match.group(1)!;
  }
  
  Future<Iterable<PlaylistTrack>> getPlaylist(String url) {
    playlistTracks = spotify.playlists.getPlaylistTracks(urlToId(url)).all(); // get all playlist tracks

    return playlistTracks;
  }

  Future<({int year, String name, String artist, String artwork})> getTrackMetadata(String id) async {
  final track = await spotify.tracks.get(id);

  return (
    year: int.tryParse(track.album?.releaseDate?.split("-").first ?? "") ?? 0,
    name: track.name ?? "",
    artist: track.artists?.first.name ?? "",
    artwork: track.album?.images?.first.url ?? "");
  }

}