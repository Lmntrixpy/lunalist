import 'package:flutter/material.dart';
import 'package:hitster_2/pages/local_music_configurator.dart';
import 'package:hitster_2/services/local_music.dart';
import 'package:hitster_2/pages/spotify_playlist_input.dart';
import 'dart:io';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spielauswahl"),
        centerTitle: true,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        
        children: [
          Center(),

          Text("Wähle den Spielmodus aus!",
            style: TextStyle(fontSize: 24),
          ),
          
          if (Platform.isAndroid || Platform.isIOS) 
            FilledButton.icon(
              label: Text("Online - Spotify", style: TextStyle(color: Colors.black, fontSize: 24),),
              icon: Icon(Icons.wifi_rounded),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black
                ),
              onPressed: () {
                // TODO: Spotify Game Mode
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const playlistInput()),
                );
              },
            ),

          FilledButton.icon(
          label: Text("Offline - lokale Musik", style: TextStyle(color: Colors.black, fontSize: 24),),
          icon: Icon(Icons.wifi_off_rounded),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.pinkAccent[100],
            foregroundColor: Colors.black
            ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LocalMusicConfigurator()),
              );
            },
          ),
        ],
      ),
    );
  }
}