import 'package:flutter/material.dart';
import 'package:hitster_2/pages/song_info_local.dart';
import 'package:hitster_2/services/card_mapper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hitster_2/pages/song_info.dart';

class ControlMusicState extends StatefulWidget {
  final CardSongMapper mapper;
  final int cardNumber;
  
  const ControlMusicState({super.key, required this.mapper, required this.cardNumber});

  @override
  State<ControlMusicState> createState() => _ControlMusicStateState();
}

class _ControlMusicStateState extends State<ControlMusicState> {
  late final AudioPlayer player;
  bool isPlaying = true;
  late final String currentTrack;
  
  @override
  void initState() {
  super.initState();
  player = AudioPlayer();

  player.playerStateStream.listen((state) {
    if (!mounted) return;
    setState(() {});
  });

  _playTrack();
  }

  Future<void> _playTrack() async {
    currentTrack = widget.mapper.scanCard(widget.cardNumber);
    await player.setFilePath(
      currentTrack,
    );
    await player.play();

    player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
      isPlaying = state.playing;
      });
    });


    if (!mounted) return;
    setState(() {
      isPlaying = true;
    });
  }
 
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SongInfoLocal(currentTrack: currentTrack, mapper: widget.mapper))
            );
        },
        
        label: Text("Karte aufdecken"),
        icon: Icon(Icons.arrow_right_alt_rounded),
        ),
        
        
      body: Center(
        child: IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_fill_rounded),
          iconSize: 64,
          onPressed: () async {
            if (player.playing) {
              await player.pause();
            } else {
              await player.play();
            }
          },
        ),
      ),
    );
  }
}