import 'package:flutter/material.dart';
import 'package:lunalist/pages/music_configurator_apple_music.dart';
import 'package:lunalist/pages/music_configurator_local.dart';
import 'package:lunalist/pages/music_configurator_soundcloud.dart';
import 'package:lunalist/pages/music_configurator_spotify.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';


class ModeSelector extends StatefulWidget {
  const ModeSelector({super.key});

  @override
  State<ModeSelector> createState() => _ModeSelectorState();
}

class _ModeSelectorState extends State<ModeSelector> {

  bool experimentalMode = false;

  @override
  void initState() {
    super.initState();
    _loadExperimentalMode();
   
  }

  Future<void> _loadExperimentalMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool("experimentalMode");

    if (!mounted) return;

    setState(() {
      experimentalMode = saved ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spielauswahl"),
        centerTitle: true,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Wähle den Spielmodus aus!",
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 16),

          if (Platform.isAndroid || Platform.isIOS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                label: const Text(
                  "Online - Spotify",
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
                icon: const Icon(Icons.wifi_rounded),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const playlistInput()),
                  );
                },
              ),
            ),

          if (Platform.isMacOS || Platform.isIOS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                label: const Text(
                  "Online - Apple Music",
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
                icon: const Icon(Icons.wifi_rounded),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppleMusicPlaylistInput()),
                  );
                },
              ),
            ),

          if (experimentalMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                label: const Text(
                  "Online - Soundcloud",
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
                icon: const Icon(Icons.wifi_rounded),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const soundCloudPlaylistInput()),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              label: const Text(
                "Offline - Lokale Musik",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              icon: const Icon(Icons.wifi_off_rounded),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LocalMusicConfigurator()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}