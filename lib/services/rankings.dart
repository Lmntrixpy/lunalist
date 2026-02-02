import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';


class RankingStorage {
  static const _fileName = 'ranking.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, int>> _loadJson() async {
    final file = await _getFile();

    if (!await file.exists()) {
      return {};
    }

    final content = await file.readAsString();
    final Map<String, dynamic> json = jsonDecode(content);

    return json.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> _saveJson(Map<String, int> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  // adds one win to name
  Future<void> setWin(String name) async {
    final ranking = await _loadJson();

    ranking[name] = (ranking[name] ?? 0) + 1;

    await _saveJson(ranking);
  }

  // gets count of wins from name
  Future<int> getWins(String name) async {
    final ranking = await _loadJson();
    return ranking[name] ?? 0;
  }

  Future<List<RankingEntry>> getAll() async {
    final ranking = await _loadJson();

    final list = ranking.entries
        .map((e) => RankingEntry(e.key, e.value))
        .toList();

    list.sort((a, b) => b.wins.compareTo(a.wins));

    return list;
  }

  Future<void> exportRanking() async {
    final file = await _getFile();

    if (!await file.exists()) {
      throw Exception('Keine Rangliste vorhanden');
    }

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
      ),
    );
  }

  Future<void> importRanking({bool merge = false}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();

    final imported = validateRankingJson(content);

    if (merge) {
      final current = await _loadJson();
      for (final entry in imported.entries) {
        current[entry.key] =
            (current[entry.key] ?? 0) + entry.value;
      }
      await _saveJson(current);
    } else {
      await _saveJson(imported);
    }
  }


  Map<String, int> validateRankingJson(String content) {
    late final dynamic decoded;

    try {
      decoded = jsonDecode(content);
    } catch (_) {
      throw InvalidRankingImport('JSON ist ungültig');
    }

    if (decoded is! Map<String, dynamic>) {
      throw InvalidRankingImport('JSON muss ein Objekt sein');
    }

    if (decoded.isEmpty) {
      throw InvalidRankingImport('Rangliste ist leer');
    }

    final Map<String, int> result = {};

    for (final entry in decoded.entries) {
      final name = entry.key;
      final wins = entry.value;

      if (name.trim().isEmpty) {
        throw InvalidRankingImport('Name darf nicht leer sein');
      }

      if (wins is! int || wins < 0) {
        throw InvalidRankingImport(
          'Ungültige Siege für "$name"',
        );
      }

      result[name] = wins;
    }

    return result;
  }
}

class RankingEntry {
  final String name;
  final int wins;

  RankingEntry(this.name, this.wins);
}

class InvalidRankingImport implements Exception {
  final String message;
  InvalidRankingImport(this.message);

  @override
  String toString() => message;
}