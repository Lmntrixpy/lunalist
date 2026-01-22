import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:hitster_2/config.dart';

class PlayerSpotify extends StatefulWidget {
  const PlayerSpotify({super.key});

  @override
  State<PlayerSpotify> createState() => _PlayerSpotifyState();
}

class _PlayerSpotifyState extends State<PlayerSpotify> {
  bool isPlaying = false;

  @override
    void initState() {
    super.initState();
   spotifyInit();
  } 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SpotPlayerPgae"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

        }, 
        label: Text("Karte aufdecken"),
        icon: Icon(Icons.arrow_right_alt_rounded),
      ),

      body: Center(
        child: IconButton(
          onPressed: () {
            setState(() {
              if (isPlaying) {
                SpotifySdk.pause();
                isPlaying = false;
              } else {
                SpotifySdk.resume();
                isPlaying = true;
              }  
            });
          }, icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled)),
      ),
    );
  }
}

Future<void> spotifyInit() async {
    if (Platform.isAndroid) {
      await SpotifySdk.getAccessToken(clientId: AppConfig.clientId, redirectUrl: "hitster://callback", scope: 'app-remote-control streaming',
);
    }
    await SpotifySdk.connectToSpotifyRemote(clientId: AppConfig.clientId, redirectUrl: "spotify-ios-quick-start://spotify-login-callback");
    SpotifySdk.pause();
  }
