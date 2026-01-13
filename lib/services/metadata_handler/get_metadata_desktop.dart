import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';


GetMetadataDesktop create() => GetMetadataDesktop();

class GetMetadataDesktop {
  static String trackName = "";
  static int releaseYear = 0;
  static List<String> trackArtistNames = [];
  static Uint8List albumArt = Uint8List(0);

  static Future<void> load(String songPath) async {
    var retriever = await MetadataRetriever.fromFile(File(songPath)); // for rest of metadata

    trackName = retriever.trackName ?? "";
    releaseYear = 0;
    trackArtistNames = retriever.trackArtistNames ?? [];
    albumArt = retriever.albumArt ?? Uint8List(0);
  }
}