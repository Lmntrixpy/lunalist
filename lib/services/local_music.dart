import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';


class LocalMusic {
  Future<List<String>> load() async {
    final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ["mp3"]);

    if (result == null) {
      return <String>[];
    }
    return result.paths.whereType<String>().toList();
  }
}

class GetMetadata {
  static String trackName = "";
  static int releaseYear = 0;
  static List<String> trackArtistNames = [];
  static Uint8List albumArt = Uint8List(0);

  static Future<void> load(String songPath) async {
    var retriever = await MetadataRetriever.fromFile(File(songPath)); // for rest of metadata
    final newRetriever = readMetadata(File(songPath), getImage: false); // for year of track

    trackName = retriever.trackName ?? "";
    releaseYear = newRetriever.year?.year.toInt() ?? 0;
    trackArtistNames = retriever.trackArtistNames ?? [];
    albumArt = retriever.albumArt ?? Uint8List(0);
  }
}