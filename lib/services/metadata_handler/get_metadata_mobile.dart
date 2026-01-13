import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audiotags/audiotags.dart'; // for release year
import 'package:flutter_media_metadata/flutter_media_metadata.dart'; // for metadata

class GetMetadataMobile {
  static String trackName = "";
  static int releaseYear = 0;
  static List<String> trackArtistNames = [];
  static Uint8List albumArt = Uint8List(0);
  static Tag? tags; // for ios & android

  static Future<void> load(String songPath) async {
    var retriever = await MetadataRetriever.fromFile(File(songPath)); // for rest of metadata
    var tags = await AudioTags.read(songPath); // for release year

    trackName = retriever.trackName ?? "";
    releaseYear = tags?.year ?? 0;
    trackArtistNames = retriever.trackArtistNames ?? [];
    albumArt = retriever.albumArt ?? Uint8List(0);
  }
}