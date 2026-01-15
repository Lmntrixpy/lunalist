// ignore: file_names
import 'package:spotify/spotify.dart';
import 'package:hitster_2/config.dart';

late SpotifyApi spotify;

Future<bool> spotifyAuth() async {
  print("------- in auth --------");

  final credentials = SpotifyApiCredentials(AppConfig.clientId, AppConfig.clientSecret);
  spotify = SpotifyApi(credentials);

  final artist = await spotify.artists.get('0OdUWJ0sBjDrqHygGUXeCF');
  print(artist.name);
  if (artist.name == "Band of Horses") {return true;}
  else {return false;}
}

String urlToId(String url) {
  print("------ in urlToId ------");
  // URL: https://open.spotify.com/playlist/34i2Aqmw8bgfxfardWSbNg?si=d3f28ff72605449d

  final match = RegExp(r'playlist\/([^?]+)').firstMatch(url);
  if (match == null) {
    throw FormatException('Ungültige Playlist-URL');
  }
  return match.group(1)!;
}

Future<Iterable<PlaylistTrack>> getPlaylistDetails(String id) async {
  print("------- in getPlaylistDetails -------");

  var songs = await spotify.playlists.getPlaylistTracks(id).all();

  return songs;
}