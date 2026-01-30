import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hitster_2/pages/scanner.dart';
import 'package:hitster_2/pages/song_info.dart';
import 'package:hitster_2/services/card_mapper.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:hitster_2/config.dart';

class PlayerSpotify extends StatefulWidget {
  final CardSongMapper mapper;
  final int cardNumber;
  final String gameMode;

  const PlayerSpotify({super.key, required this.mapper, required this.cardNumber, required this.gameMode});

  @override
  State<PlayerSpotify> createState() => _PlayerSpotifyState();
}

class _PlayerSpotifyState extends State<PlayerSpotify> {
  bool isPlaying = true;
  late final ({String artist, String artwork, String id, String name, int year}) currentTrack;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await ensureSpotifyConnection();
    await _playTrack();
  }

  Future<void> ensureSpotifyConnection() async {
    print("--- auth spot");

    if (Platform.isAndroid) {
      await SpotifySdk.getAccessToken(
        clientId: AppConfig.clientId,
        redirectUrl: 'hitster://callback',
        scope: 'app-remote-control streaming',
      );
    }

    await SpotifySdk.connectToSpotifyRemote(
      clientId: AppConfig.clientId,
      redirectUrl: "spotify-ios-quick-start://spotify-login-callback",
    );
    }

  Future<void> _playTrack() async {
    currentTrack = widget.mapper.scanCard(widget.cardNumber);
    debugPrint("------ play track ----");
    await SpotifySdk.subscribeConnectionStatus(); // waits for spotify to be connected
    SpotifySdk.play(spotifyUri: "spotify:track:${currentTrack.id}");
    print("Playing ${currentTrack.name} by ${currentTrack.artist}");
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
          SpotifySdk.pause();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SongInfo(mapper: widget.mapper, currentTrack: currentTrack, gameMode: widget.gameMode))
          );
        }, 
        label: Text("Karte aufdecken"),
        icon: Icon(Icons.arrow_right_alt_rounded),
      ),

      body: Center(
        child: IconButton(
          iconSize: 128,
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

