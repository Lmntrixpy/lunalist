import 'package:flutter/material.dart';
import 'package:hitster_2/pages/song_info.dart';
import 'package:hitster_2/services/card_mapper.dart';
import 'package:just_audio/just_audio.dart';

class ControlMusicState extends StatefulWidget {
  final CardSongMapper mapper;
  final int cardNumber;
  final String gameMode;
  
  const ControlMusicState({super.key, required this.mapper, required this.cardNumber, required this.gameMode});

  @override
  State<ControlMusicState> createState() => _ControlMusicStateState();
}

class _ControlMusicStateState extends State<ControlMusicState> {
  late final AudioPlayer player;
  bool isPlaying = true;
  late final ({String artist, String artwork, String id, String name, int year}) currentTrack;
  
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
      currentTrack.id,
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SongInfo(currentTrack: currentTrack, mapper: widget.mapper, gameMode: widget.gameMode,))
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
                style: TextStyle(fontSize: 12),
              ),

              Spacer(flex: 1),
              
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  "Errate den Song\nund den Artist!",
                  style: TextStyle(fontSize: 28),
                ),
              ),

              Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 50),
              child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_fill_rounded),
                  iconSize: 96,
                  onPressed: () async {
                    if (player.playing) {
                      await player.pause();
                    } else {
                      await player.play();
                    }
                  },
                ),
              ),

              Spacer(flex: 2),
              
            ],
          ),
        ),
      )
    );
  }
}