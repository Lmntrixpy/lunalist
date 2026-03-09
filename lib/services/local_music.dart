import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

class LocalMusicResult {
  final List<String> validTracks;
  final List<String> invalidFolders;

  const LocalMusicResult({
    required this.validTracks,
    required this.invalidFolders,
  });
}

class LocalMusic {
  Future<LocalMusicResult> load() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ["mp3"],
    );

    if (result == null) {
      return const LocalMusicResult(
        validTracks: [],
        invalidFolders: [],
      );
    }

    final validTracks = <String>[];
    final invalidFolders = <String>[];

    for (final path in result.paths.whereType<String>()) {
      final invalidFolder = getInvalidFolder(path);

      if (invalidFolder != null) {
        debugPrint("Ordnername enthält nicht unterstützte Zeichen: $invalidFolder");

        if (!invalidFolders.contains(invalidFolder)) {
          invalidFolders.add(invalidFolder);
        }
        continue;
      }

      try {
        final retriever = await MetadataRetriever.fromFile(File(path));
        final meta = readMetadata(File(path), getImage: false);

        final trackName = retriever.trackName ?? "";
        final releaseYear = meta.year?.year ?? 0;
        final artists = retriever.trackArtistNames ?? [];

        if (trackName.isNotEmpty && releaseYear > 0 && artists.isNotEmpty) {
          validTracks.add(path);
        }
      } catch (_) {
        // skip track if not enough metadata
      }
    }

    return LocalMusicResult(
      validTracks: validTracks,
      invalidFolders: invalidFolders,
    );
  }

  String? getInvalidFolder(String path) {
    if (!Platform.isWindows) {
      return null;
    }

    final parts = p.split(path);
    final folders = parts.take(parts.length - 1);

    for (final folder in folders) {
      if (!RegExp(r'^[\x00-\x7F]+$').hasMatch(folder)) {
        return folder;
      }
    }

    return null;
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