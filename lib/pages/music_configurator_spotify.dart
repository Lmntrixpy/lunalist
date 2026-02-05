import 'package:flutter/material.dart';
import 'package:lunalist/api/spotify-auth.dart';
import 'package:lunalist/pages/scanner.dart';
import 'package:lunalist/services/card_mapper.dart';

typedef HitsterTrack = ({
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
        onPressed: () async {

          SpotifyInterface().authorize();

          final Map<String, HitsterTrack> allTracks = {};

          for (var i = 0; i < playlistCount; i++) {
            final url = controllers[i].text.trim();
            debugPrint("Controller: $i -> $url");
            if (url.isEmpty) continue;


            final tracks = await SpotifyInterface.getPlaylistTracks(url);
            

            for (final track in tracks) {
              allTracks[track.id] = track;
              debugPrint(track.name);
            }
          }

          if (!context.mounted) return;

          final List<HitsterTrack> uniqueTracks = allTracks.values.toList();
          debugPrint("Tracks ges: ${uniqueTracks.length}");
          debugPrint(uniqueTracks.toString());

          final mapper = CardSongMapper(uniqueTracks);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ScannerPage(mapper: mapper, gameMode: gameMode))
          );
        },
        label: Text("Weiter"),
        icon: Icon(Icons.arrow_right_alt_rounded)
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            Text(
              "Gib deine Playlisten ein.",
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