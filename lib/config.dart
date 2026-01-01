import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late final String clientId;
  static late final String clientSecret;
  static late final String version;

  static void load() {
    clientId = dotenv.env['clientId']!;
    clientSecret = dotenv.env['clientSecret']!;
    version = dotenv.env['version']!;
  }
}