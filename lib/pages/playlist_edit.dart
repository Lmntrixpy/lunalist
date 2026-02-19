import 'package:flutter/material.dart';
import 'package:lunalist/services/preloaded_playlists.dart';

class PlaylistCsvEditorPage extends StatefulWidget {
  const PlaylistCsvEditorPage({
    super.key,
    required this.store,
    this.title = 'Packs',
  });

  final PlaylistCsvStore store;
  final String title;

  @override
  State<PlaylistCsvEditorPage> createState() => _PlaylistCsvEditorPageState();
}

class _RowModel {
  _RowModel({
    required this.nameController,
    required this.urlController,
    required this.originalUrlKey,
    required this.isNew,
  });

  final TextEditingController nameController;
  final TextEditingController urlController;

  final String? originalUrlKey;

  final bool isNew;

  void dispose() {
    nameController.dispose();
    urlController.dispose();
  }
}

class _PlaylistCsvEditorPageState extends State<PlaylistCsvEditorPage> {
  final List<_RowModel> _rows = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    await widget.store.load();

    for (final r in _rows) {
      r.dispose();
    }
    _rows.clear();

    for (final e in widget.store.entries) {
      _rows.add(
        _RowModel(
          nameController: TextEditingController(text: e.name),
          urlController: TextEditingController(text: e.url),
          originalUrlKey: e.url,
          isNew: false,
        ),
      );
    }

    setState(() => _loading = false);
  }

  void _addRow() {
    setState(() {
      _rows.add(
        _RowModel(
          nameController: TextEditingController(),
          urlController: TextEditingController(),
          originalUrlKey: null,
          isNew: true,
        ),
      );
    });
  }

  Future<void> _deleteRow(int index) async {
    final row = _rows[index];

    if (!row.isNew && row.originalUrlKey != null) {
      await widget.store.removeByUrl(row.originalUrlKey!);
    }

    setState(() {
      row.dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _saveAll() async {
    if (_saving) return;

    // validation
    final seenUrls = <String>{};
    for (final r in _rows) {
      final name = r.nameController.text.trim();
      final url = r.urlController.text.trim();

      if (name.isEmpty || url.isEmpty) {
        _showSnack('Name und URL dürfen nicht leer sein.');
        return;
      }

      if (!_isValidSpotifyPlaylistUrl(url)) {
        _showSnack('Ungültige Spotify Playlist URL: $url');
        return;
      }

      if (seenUrls.contains(url)) {
        _showSnack('Doppelte URL gefunden: $url');
        return;
      }

      seenUrls.add(url);
    }

    setState(() => _saving = true);
    try {
      final csv = _rowsToCsv(includeHeader: true);
      await widget.store.importFromString(csv);

      await _load();
      _showSnack('Gespeichert.');
    } catch (e) {
      _showSnack('Fehler beim Speichern: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _rowsToCsv({required bool includeHeader}) {
    final lines = <String>[];
    if (includeHeader) lines.add('name;url');

    for (final r in _rows) {
      final name = r.nameController.text.trim();
      final url = r.urlController.text.trim();
      lines.add(PlaylistEntry(name: name, url: url).toCsvLine());
    }
    return lines.join('\n');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isValidSpotifyPlaylistUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  if (uri.scheme != 'https') return false;
  if (uri.host != 'open.spotify.com') return false;

  final segments = uri.pathSegments;
  if (segments.length < 2) return false;
  if (segments[0] != 'playlist') return false;

  final playlistId = segments[1];

  final idRegex = RegExp(r'^[A-Za-z0-9]{22}$');
  return idRegex.hasMatch(playlistId);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Aus Assets zurücksetzen',
            onPressed: _loading || _saving
                ? null
                : () async {
                    await widget.store.resetFromAssets();
                    await _load();
                    _showSnack('Zurückgesetzt.');
                  },
            icon: const Icon(Icons.restore_rounded),
          ),
          IconButton(
            tooltip: 'CSV exportieren',
            onPressed: _loading || _saving
                ? null
                : () async {
                    try {
                      await widget.store.exportAndShare(context);
                    } catch (e) {
                      _showSnack('Export fehlgeschlagen: $e');
                    }
                  },
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            tooltip: 'Speichern',
            onPressed: _loading || _saving ? null : _saveAll,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading || _saving ? null : _addRow,
        icon: const Icon(Icons.add),
        label: const Text('Hinzufügen'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rows.isEmpty
              ? const Center(child: Text('Keine Playlists. Tippe auf “Hinzufügen”.'))
              : _buildTable(),
    );
  }

  Widget _buildTable() {
    return LayoutBuilder(
      builder: (context, c) {
        final nameWidth = (c.maxWidth * 0.35).clamp(160.0, 320.0);
        final urlWidth = (c.maxWidth * 0.55).clamp(220.0, 900.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('URL')),
                DataColumn(label: Text('')),
              ],
              rows: List.generate(_rows.length, (i) {
                final r = _rows[i];
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: nameWidth,
                        child: TextField(
                          controller: r.nameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: 'z.B. Party',
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: urlWidth,
                        child: TextField(
                          controller: r.urlController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: 'https://...',
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        tooltip: 'Zeile löschen',
                        onPressed: _saving ? null : () => _deleteRow(i),
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}