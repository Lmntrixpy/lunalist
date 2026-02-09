import 'package:flutter/material.dart';
import 'package:lunalist/api/spotify_http.dart';
import 'package:lunalist/pages/scanner.dart';
import 'package:lunalist/services/card_mapper.dart';
import 'package:lunalist/config.dart';
import 'package:url_launcher/url_launcher.dart';

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

  

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spotify"),
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
                    clientId: AppConfig.clientId,
                    clientSecret: AppConfig.clientSecret,
                  );

                  final Map<String, LunalistTrack> allTracks = {};
                  final Set<String> seenPlaylistIds = {};

                  for (var i = 0; i < playlistCount; i++) {
                    final url = controllers[i].text.trim();
                    final idx = i + 1; // for ui

                    // if empty still continue
                    if (url.isEmpty) continue;

                    String playlistId;
                    try {
                      playlistId = SpotifyHttp.playlistUrlToId(url);
                    } on FormatException catch (e) {
                      setState(() => _errorText = "Playlist $idx: ${e.message}");
                      return;
                    }

                    // if playlist is a duplicate, skip
                    if (!seenPlaylistIds.add(playlistId)) {
                      continue;
                    }

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
            Text(
              "Gib deine Playlisten ein.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            TextButton.icon(
              onPressed: () async {
                showDialog(
                  context: context, 
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text("Lieblingssongs"),
                      content: Text("Wenn du mit deinen Lieblingssongs spielen möchtest musst du sie vorher in eine Playlist konvertieren. Um das zu tun kannst du Listify nehmen."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Abbrechen")
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final String url = "https://listify.rar-home.cloud";
                            final uri = Uri.parse(url);
                            
                            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                              throw Exception('URL konnte nicht geöffnet werden: $url');
                            }
                          },
                          label: Text("Listify öffnen"),
                          icon: Icon(Icons.link_rounded),
                        )
                      ],
                    );
                  }
                );
              },
              label: Text("Möchtest du mit deinen Lieblingssongs spielen?"),
              icon: Icon(Icons.info_outline_rounded),
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
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (playlistCount > 1) {
                    setState(() => playlistCount--);
                  }
                },
              ),

              Text(
                "$playlistCount ${playlistCount == 1 ? 'Playlist' : 'Playlists'}",
                style: TextStyle(fontSize: 18),
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
                icon: Icon(Icons.add_rounded),
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
                    child: TextField(
                      controller: controllers[i],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Playlist ${i + 1}",
                      ),
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