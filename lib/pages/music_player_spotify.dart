import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hitster_2/pages/song_info_spotify.dart';
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
  ({String artist, String artwork, String id, String name, int year})? currentTrack;
  bool isReady = false;

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
        redirectUrl: 'hitster://android-callback',
        scope: 'app-remote-control streaming',
      );
    }

    await SpotifySdk.connectToSpotifyRemote(
      clientId: AppConfig.clientId,
      redirectUrl: Platform.isAndroid ? "hitster://android-callback" : "hitster://ios-callback",
    );
    }

  Future<void> _playTrack() async {
    final track = widget.mapper.scanCard(widget.cardNumber);

    SpotifySdk.subscribeConnectionStatus();
    await SpotifySdk.play(spotifyUri: "spotify:track:${track.id}");

    setState(() {
      currentTrack = track;
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: !isReady ? null :() {
            SpotifySdk.pause();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SongInfo(mapper: widget.mapper, currentTrack: currentTrack!, gameMode: widget.gameMode))
            );
          }, 
          label: Text("Karte aufdecken"),
          icon: Icon(Icons.arrow_right_alt_rounded),
        ),
      
        body: SafeArea(
          child: Column(
            children: [
              Text(
                "Spielmodus: ${widget.gameMode}",
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 12
                ),
              ),
              
              Spacer(flex: 1),
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  "Errate den Song\nund den Artist!",
                  style: TextStyle(fontSize: 28),
                ),
              ),
          
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: IconButton(
                  iconSize: 96,
                  onPressed: !isReady ? null : () {
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
          
              Spacer(flex: 2),
          
            ],
          ),
        ),
      ),
    );
  }
}

