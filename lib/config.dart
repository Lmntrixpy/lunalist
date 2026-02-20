import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late final String spotifyClientId;
  static late final String spotifyClientSecret;
  static late final String version;
  static late final String soundcloudClientId;
  static late final String soundcloudClientSecret;

  static void load() {
    // General
    version = dotenv.env['version']!;

    // Spotify
    spotifyClientId = dotenv.env['SpotifyClientId']!;
    spotifyClientSecret = dotenv.env['SpotifyClientSecret']!;
    
    // SoundCloud
    soundcloudClientId = dotenv.env["SoundcloudClientId"]!;
    soundcloudClientSecret = dotenv.env["SoundcloudClientSecret"]!;
  }
}