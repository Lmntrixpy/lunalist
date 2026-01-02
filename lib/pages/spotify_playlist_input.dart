import 'package:flutter/material.dart';
import 'package:hitster_2/api/spotify-auth.dart';

// ignore: camel_case_types
class playlistInput extends StatefulWidget {
  const playlistInput({super.key});

  @override
  State<playlistInput> createState() => _playlistInputState();
}

// ignore: camel_case_types
class _playlistInputState extends State<playlistInput> {
  int playerCount = 2;

  final List<TextEditingController> controllers = [];
  final List<String> playlists = [];

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
        title: Text("Spotify",
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold)
          ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              for (var i = 0; i < playlists.length; i++) {
                getPlaylistDetails(urlToId(playlists[i]));
              }
              
            },
            icon: Icon(Icons.check_rounded, color: Colors.black,))
            
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            Text(
              "Gebe deine Playlisten ein.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
            ),

            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (playerCount > 1) {
                    setState(() => playerCount--);
                  }
                },
              ),

              Text(
                "$playerCount Playlist/en",
                style: TextStyle(fontSize: 18),
              ),

              IconButton(
                onPressed: () {
                  if (playerCount < 10) {
                    setState(() => playerCount++);
                  }
                  playlists
                    ..clear()
                    ..addAll(
                      controllers
                        .take(playerCount)
                        .map((c) => c.text)
                        .where((t) => t.isNotEmpty),
                    );

                  for (final url in playlists) {
                    // TODO: Fix Typerror
                    var id = getPlaylistDetails(urlToId(url));
                  }
                },
                icon: Icon(Icons.add_rounded, color: Colors.black),
              ),
            ],
          ),

          Expanded(
            child: ListView(
              children: List.generate(
                playerCount,
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