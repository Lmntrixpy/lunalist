import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

class LocalMusic {

  Future<List<String>> load() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.audio);

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