import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late final String SpotifyClientId;
  static late final String SpotifyClientSecret;
  static late final String version;

  static void load() {
    // General
    version = dotenv.env['version']!;

    // Spotify
    SpotifyClientId = dotenv.env['SpotifyClientId']!;
    SpotifyClientSecret = dotenv.env['SpotifyClientSecret']!;
    
  }
}