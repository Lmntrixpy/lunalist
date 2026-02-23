import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';


class AppConfig {
  static late final String spotifyClientId;
  static late final String spotifyClientSecret;
  static late final String version;
  static late final String soundcloudClientId;
  static late final String soundcloudClientSecret;

  static Future<void> load() async {
    // General
    final packageInfo = await PackageInfo.fromPlatform();
    version = "${packageInfo.version}+${packageInfo.buildNumber}";
    

    // Spotify
    spotifyClientId = dotenv.env['SpotifyClientId']!;
    spotifyClientSecret = dotenv.env['SpotifyClientSecret']!;
    
    // SoundCloud
    soundcloudClientId = dotenv.env["SoundcloudClientId"]!;
    soundcloudClientSecret = dotenv.env["SoundcloudClientSecret"]!;
  }
}