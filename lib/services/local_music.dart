import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

Future<List<String>> _load() async {
  final result = await FilePicker.platform.pickFiles(allowMultiple: true);
  if (result == null) return [];
  
  if (kDebugMode) {print(result);}

  return result.paths.whereType<String>().toList();
}

Future<void> playMusic() async {
  debugPrint("----- in playMusic");
  
  final files = await _load();
  if (files.isEmpty) return;
  final player = AudioPlayer();
  await player.setSourceDeviceFile(files.first);
  await player.resume();
}
