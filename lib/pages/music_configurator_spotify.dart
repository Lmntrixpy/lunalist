import 'package:flutter/material.dart';
import 'package:lunalist/api/spotify_http.dart';
import 'package:lunalist/pages/scanner.dart';
import 'package:lunalist/services/card_mapper.dart';
import 'package:lunalist/config.dart';
import 'package:lunalist/services/preloaded_playlists.dart';

typedef LunalistTrack = ({
  String id,
  String name,
  String artist,
  String artwork,
  int year,
});

// ignore: camel_case_types
class playlistInput extends StatefulWidget {
  const playlistInput({super.key});

  @override
  State<playlistInput> createState() => _playlistInputState();
}

// ignore: camel_case_types
class _playlistInputState extends State<playlistInput> {
  int playlistCount = 1;

  final List<TextEditingController> controllers = [];
  final List<String> playlists = [];
  final gameMode = "spotify";

  String? _errorText;
  bool _loading = false;

  final PlaylistCsvStore _csvStore = PlaylistCsvStore(assetPath: 'assets/playlists.csv');

  bool _csvLoaded = false;

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _ensureCsvLoaded() async {
    if (_csvLoaded) return;
    await _csvStore.load();
    _csvLoaded = true;
  }

  Future<void> _pickFromCsvIntoField(int fieldIndex) async {
    await _ensureCsvLoaded();

    if (!mounted) return;

    final selected = await showModalBottomSheet<PlaylistEntry>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final items = _csvStore.entries;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Playlist auswählen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Keine Playlists in der CSV.'),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e = items[i];
                      return ListTile(
                        title: Text(e.name),
                        subtitle: Text(
                          e.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.pop(ctx, e),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    while (controllers.length <= fieldIndex) {
      controllers.add(TextEditingController());
    }

    setState(() {
      controllers[fieldIndex].text = selected.url;
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spotify"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading
            ? null
            : () async {
                setState(() {
                  _errorText = null;
                  _loading = true;
                });

                try {
                  final spotifyHttp = SpotifyHttp(
                    clientId: AppConfig.spotifyClientId,
                    clientSecret: AppConfig.spotifyClientSecret,
                  );

                  final Map<String, LunalistTrack> allTracks = {};
                  final Set<String> seenPlaylistIds = {};

                  for (var i = 0; i < playlistCount; i++) {
                    final url = controllers[i].text.trim();
                    final idx = i + 1;

                    if (url.isEmpty) continue;

                    String playlistId;
                    try {
                      playlistId = SpotifyHttp.playlistUrlToId(url);
                    } on FormatException catch (e) {
                      setState(() => _errorText = "Playlist $idx: ${e.message}");
                      return;
                    }

                    if (!seenPlaylistIds.add(playlistId)) continue;

                    try {
                      final tracks = await spotifyHttp.getPlaylistTracks(
                        playlistUrl: url,
                        market: "DE",
                      );

                      if (tracks.isEmpty) {
                        setState(() => _errorText = "Playlist $idx: Keine Songs gefunden.");
                        return;
                      }

                      for (final track in tracks) {
                        allTracks[track.id] = track;
                      }
                    } catch (e) {
                      final msg = e.toString();
                      final pretty = msg.contains("404")
                          ? "Playlist $idx nicht gefunden (404). Prüfe Link / Playlist öffentlich?"
                          : "Playlist $idx: Spotify-Request fehlgeschlagen: $msg";

                      setState(() => _errorText = pretty);
                      return;
                    }
                  }

                  if (!context.mounted) return;

                  if (allTracks.isEmpty) {
                    setState(() => _errorText = "Keine Songs gefunden. Prüfe deine Playlist-Links.");
                    return;
                  }

                  final mapper = CardSongMapper(allTracks.values.toList());

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScannerPage(mapper: mapper, gameMode: gameMode),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  final msg = e.toString();
                  final pretty = msg.contains("404")
                      ? "Playlist nicht gefunden (404). Prüfe Link / Playlist öffentlich?"
                      : "Spotify-Request fehlgeschlagen: $msg";

                  setState(() => _errorText = pretty);
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
        label: Text(_loading ? "Lade..." : "Weiter"),
        icon: const Icon(Icons.arrow_right_alt_rounded),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Gib deine Playlisten ein.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                _errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (playlistCount > 1) {
                    setState(() => playlistCount--);
                  }
                },
              ),
              Text(
                "$playlistCount ${playlistCount == 1 ? 'Playlist' : 'Playlists'}",
                style: const TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () {
                  if (playlistCount < 10) {
                    setState(() => playlistCount++);
                  }
                  playlists
                    ..clear()
                    ..addAll(
                      controllers
                          .take(playlistCount)
                          .map((c) => c.text)
                          .where((t) => t.isNotEmpty),
                    );
                },
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: List.generate(
                playlistCount,
                (i) {
                  if (controllers.length <= i) {
                    controllers.add(TextEditingController());
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers[i],
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Playlist ${i + 1}",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Aus CSV auswählen',
                          onPressed: _loading ? null : () => _pickFromCsvIntoField(i),
                          icon: const Icon(Icons.playlist_add_rounded),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}