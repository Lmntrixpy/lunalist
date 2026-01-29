import 'package:flutter/material.dart';
import 'package:hitster_2/services/card_mapper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hitster_2/pages/song_info.dart';

class ControlMusicState extends StatefulWidget {
  final List<String> tracks;
  
  const ControlMusicState({super.key, required this.tracks});

  @override
  State<ControlMusicState> createState() => _ControlMusicStateState();
}

class _ControlMusicStateState extends State<ControlMusicState> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SongInfo())
            );
        },
        
        label: Text("Karte aufdecken"),
        icon: Icon(Icons.arrow_right_alt_rounded),
        ),
        
        
      body: Center(
        child: IconButton(
          onPressed: () async{
            // mapper = CardSongMapper(tracks)
            // TODO: implement Play / Pause
          },
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          iconSize: 64,
          ),
      ),
    );
  }
}