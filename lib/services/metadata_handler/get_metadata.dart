import 'dart:typed_data';
import 'get_metadata_desktop.dart'  // Desktop / alle Plattformen ohne Plugin
    if (dart.library.io) 'get_metadata_mobile.dart'; // Mobile = iOS + Android

abstract class GetMetadata {
  // Shared vars
  static String trackName = "";
  static int releaseYear = 0;
  static List<String> trackArtistNames = [];
  static Uint8List albumArt = Uint8List(0);

  static Future<void> load(String songPath) => GetMetadataDesktop.load(songPath);

  static final GetMetadataDesktop impl = create();
}