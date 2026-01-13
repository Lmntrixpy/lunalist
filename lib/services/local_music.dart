import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:audiotags/audiotags.dart';


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
  // TODO: add play functionality
}

Future<void> playMusic() async {
  debugPrint("----- in playMusic");

  final music = LocalMusic();
  final files = await music.load();

  if (files.isEmpty) return;

  final player = AudioPlayer();
  await player.setSourceDeviceFile(files.first);
  await player.resume();
}


class GetMetadata {
  static String trackName = "";
  static int releaseYear = 0;
  static List<String> trackArtistNames = [];
  static Uint8List albumArt = Uint8List(0);
  static Tag? tags;

  static Future<void> load(String songPath) async {
    var retriever = await MetadataRetriever.fromFile(File(songPath)); // for rest of metadata
    var tags = await AudioTags.read(songPath); // for release year

    trackName = retriever.trackName ?? "";
    releaseYear = tags?.year ?? 0;
    trackArtistNames = retriever.trackArtistNames ?? [];
    albumArt = retriever.albumArt ?? Uint8List(0);

  }
}