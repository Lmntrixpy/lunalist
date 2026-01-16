import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hitster_2/pages/mode_selector.dart';
import 'package:hitster_2/pages/qr_code.dart';
import 'package:hitster_2/pages/music_player.dart';
import 'package:hitster_2/pages/settings.dart';
import 'package:hitster_2/pages/temp_spotify_api.dart';
import 'package:hitster_2/pages/testsonginfo.dart';
import 'package:hitster_2/pages/test_spotify_sdk.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        children: [
          TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ControlMusicState()),
            );
          },
          child: Text(
            "TEMP: Start!", 
            style: TextStyle(
              fontSize: 24,
              color: Colors.deepPurple[300]
              ),
            )
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ModeSelector()),
              );
            },
            child: Text(
              "TEMP: Mode Selector", 
              style: TextStyle(
                fontSize: 24,
                color: Colors.deepPurple[300]
                ),
              )
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Testsonginfo())
              );
            },
            child: Text("TempSongInfo")
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TestSpotifySdkPage())
                );
            }, 
            child: Text("SDK")
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TempSpotifyApiPage())
                );
            },
            child: Text("API")
          )

        ],
        
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text("TEMP: Hitster",
      style: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold)
        ),
      centerTitle: true,
      backgroundColor: Colors.white,
      leading: (Platform.isAndroid || Platform.isIOS)
      ? IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScannerPage()),
            );
          },
          icon: Icon(Icons.qr_code_scanner),
          iconSize: 20,
        )
      : null,

      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          icon: Icon(Icons.settings),
          iconSize: 20,
        ),
      ],
    );
  }
}