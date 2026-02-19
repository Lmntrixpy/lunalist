import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

@immutable
class PlaylistEntry {
  const PlaylistEntry({required this.name, required this.url});

  final String name;
  final String url;

  String toCsvLine() => '${_escape(name)};${_escape(url)}';

  static PlaylistEntry fromCsvFields(String name, String url) {
    final n = name.trim();
    final u = url.trim();
    if (n.isEmpty) throw FormatException('name ist leer');
    if (u.isEmpty) throw FormatException('url ist leer');
    return PlaylistEntry(name: n, url: u);
  }

  static String _escape(String v) {
    final needsQuotes =
        v.contains(';') || v.contains('"') || v.contains('\n') || v.contains('\r');
    if (!needsQuotes) return v;
    final doubled = v.replaceAll('"', '""');
    return '"$doubled"';
  }
}

class PlaylistCsvStore {
  PlaylistCsvStore({
    required this.assetPath,
    this.fileName = 'playlists.csv',
  });

  final String assetPath;
  final String fileName;

  List<PlaylistEntry> _entries = const [];
  List<PlaylistEntry> get entries => List.unmodifiable(_entries);

  Future<List<PlaylistEntry>> load() async {
    final file = await _localFile();

    if (await file.exists()) {
      final text = await file.readAsString();
      _entries = _parse(text);
      return entries;
    }

    final assetText = await rootBundle.loadString(assetPath);
    _entries = _parse(assetText);
    await _writeLocal(_entries);
    return entries;
  }

  /// Import via FilePicker:
  /// - URLs get checked (Spotify Playlist URL)
  /// - optional: duplicated urls get removed
  Future<List<PlaylistEntry>> importFromPicker({bool allowDuplicateUrls = false}) async {
    final res = await FilePicker.platform.pickFiles(
      dialogTitle: 'CSV auswählen',
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
      withData: true,
    );

    if (res == null || res.files.isEmpty) {
      throw StateError('User cancelled');
    }

    final f = res.files.first;

    // prefer bytes
    final bytes = f.bytes ??
        (f.path != null ? await File(f.path!).readAsBytes() : null);

    if (bytes == null) {
      throw StateError('Konnte Datei nicht lesen');
    }

    final text = utf8.decode(bytes, allowMalformed: true);
    final parsed = _parse(text); // removes header + empty lines

    // URL validation
    final out = <PlaylistEntry>[];
    final seen = <String>{};

    for (final e in parsed) {
      if (!_isValidSpotifyPlaylistUrl(e.url)) {
        throw FormatException('Ungültige Spotify Playlist URL: ${e.url}');
      }

      if (!allowDuplicateUrls) {
        final key = e.url.trim();
        if (seen.contains(key)) continue;
        seen.add(key);
      }

      out.add(e);
    }

    _entries = out;
    await _writeLocal(_entries);
    return entries;
  }

  Future<List<PlaylistEntry>> importFromString(String csvText) async {
    final parsed = _parse(csvText);

    // validation
    for (final e in parsed) {
      if (!_isValidSpotifyPlaylistUrl(e.url)) {
        throw FormatException('Ungültige Spotify Playlist URL: ${e.url}');
      }
    }

    _entries = parsed;
    await _writeLocal(_entries);
    return entries;
  }

  String exportToString({bool includeHeader = false}) {
    final lines = <String>[];
    if (includeHeader) lines.add('name;url');
    lines.addAll(_entries.map((e) => e.toCsvLine()));
    return lines.join('\n');
  }

  Future<File> exportToFile({bool includeHeader = false}) async {
    final file = await _localFile();
    await file.writeAsString(exportToString(includeHeader: includeHeader));
    return file;
  }

  /// Export Flow
  /// - Desktop/Android: Save to Files App
  /// - iOS: Share Sheet
  Future<void> exportAndShare(BuildContext context) async {
    final tmp = await _exportTempFile(includeHeader: true);
    if (!context.mounted) return;
    await _shareFile(tmp, context);
  }

  Future<List<PlaylistEntry>> resetFromAssets() async {
    final assetText = await rootBundle.loadString(assetPath);
    final parsed = _parse(assetText);

    for (final e in parsed) {
      if (!_isValidSpotifyPlaylistUrl(e.url)) {
        throw FormatException('Ungültige Spotify Playlist URL in assets: ${e.url}');
      }
    }

    _entries = parsed;
    await _writeLocal(_entries);
    return entries;
  }

  Future<void> add({
    required String name,
    required String url,
    bool preventDuplicateUrl = true,
  }) async {
    if (!_isValidSpotifyPlaylistUrl(url)) {
      throw FormatException('Ungültige Spotify Playlist URL: $url');
    }

    final entry = PlaylistEntry.fromCsvFields(name, url);

    if (preventDuplicateUrl) {
      final exists = _entries.any((e) => e.url.trim() == entry.url.trim());
      if (exists) throw StateError('URL existiert bereits: ${entry.url}');
    }

    _entries = [..._entries, entry];
    await _writeLocal(_entries);
  }

  Future<bool> removeByUrl(String url) async {
    final u = url.trim();
    final idx = _entries.indexWhere((e) => e.url.trim() == u);
    if (idx == -1) return false;

    final copy = [..._entries]..removeAt(idx);
    _entries = copy;
    await _writeLocal(_entries);
    return true;
  }

  Future<bool> removeAt(int index) async {
    if (index < 0 || index >= _entries.length) return false;
    final copy = [..._entries]..removeAt(index);
    _entries = copy;
    await _writeLocal(_entries);
    return true;
  }

  Future<void> sortByName() async {
    final copy = [..._entries]..sort((a, b) => a.name.compareTo(b.name));
    _entries = copy;
    await _writeLocal(_entries);
  }

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<void> _writeLocal(List<PlaylistEntry> entries) async {
    final file = await _localFile();
    final text = entries.map((e) => e.toCsvLine()).join('\n');
    await file.writeAsString(text);
  }

  Future<File> _exportTempFile({required bool includeHeader}) async {
    const exportName = 'lunalist_playlists.csv';
    final dir = await Directory.systemTemp.createTemp('lunalist_export_');
    final file = File('${dir.path}/$exportName');
    await file.writeAsString(exportToString(includeHeader: includeHeader));
    return file;
  }

  static Future<void> _shareFile(File file, BuildContext context) async {
    const String fileName = "lunalist_playlists.csv";

    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null)
        ? (box.localToGlobal(Offset.zero) & box.size)
        : const Rect.fromLTWH(0, 0, 1, 1);

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows || Platform.isAndroid) {
      final bytes = await file.readAsBytes();

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: "Suche einen Ausgabeordner aus:",
        fileName: fileName,
        bytes: bytes,
      );

      if (outputFile == null) {
        debugPrint("User cancelled");
      }
      return;
    }

    if (Platform.isIOS) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
          sharePositionOrigin: origin,
        ),
      );
      return;
    }

    debugPrint("Export/Share nicht unterstützt auf dieser Plattform.");
  }

  List<PlaylistEntry> _parse(String csvText) {
    final lines = const LineSplitter().convert(csvText);

    final out = <PlaylistEntry>[];
    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i].trim();
      if (raw.isEmpty) continue; // remove empty lines

      if (i == 0 && raw.toLowerCase() == 'name;url') continue;

      final fields = _splitSemicolonCsvLine(raw);
      if (fields.length != 2) {
        throw FormatException(
          'Ungültige Zeile ${i + 1}: erwartet 2 Felder, got ${fields.length}',
        );
      }

      out.add(PlaylistEntry.fromCsvFields(fields[0], fields[1]));
    }
    return out;
  }

  List<String> _splitSemicolonCsvLine(String line) {
    final result = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final c = line[i];

      if (c == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (c == ';' && !inQuotes) {
        result.add(buf.toString());
        buf.clear();
        continue;
      }

      buf.write(c);
    }

    result.add(buf.toString());
    return result;
  }

  static bool _isValidSpotifyPlaylistUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;

    if (uri.scheme != 'https') return false;
    if (uri.host != 'open.spotify.com') return false;

    final seg = uri.pathSegments;
    if (seg.length < 2) return false;
    if (seg[0] != 'playlist') return false;

    final id = seg[1];
    return RegExp(r'^[A-Za-z0-9]{22}$').hasMatch(id);
  }
}