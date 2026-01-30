import 'package:flutter/material.dart';
import 'package:hitster_2/pages/end_screen.dart';
import 'package:hitster_2/pages/scanner.dart';
import 'package:hitster_2/services/card_mapper.dart';

class SongInfo extends StatefulWidget {
  final ({String artist, String artwork, String id, String name, int year}) currentTrack;
  final CardSongMapper mapper;
  final String gameMode;

  const SongInfo({super.key, required this.currentTrack, required this.mapper, required this.gameMode});

  @override
  State<SongInfo> createState() => _SongInfoState();
}

class _SongInfoState extends State<SongInfo> {
  
  @override
  Widget build(BuildContext context) {
      int trackYear = widget.currentTrack.year;
      String artwork = widget.currentTrack.artwork;
      String artist = widget.currentTrack.artist;
      String name = widget.currentTrack.name;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.mapper.remainingSongCount == 0
                  ? EndScreen()
                  : ScannerPage(mapper: widget.mapper, gameMode: widget.gameMode,),
            ),
          );
        },
        label: widget.mapper.remainingSongCount == 0 ? Text("Spiel beenden") : Text("Nächste Karte"),
        icon: widget.mapper.remainingSongCount == 0 ? Icon(Icons.flag_rounded) : Icon(Icons.qr_code_rounded),
      ),
      
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Spielmodus: ${widget.gameMode}",
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 12
                ),
              ),

              Spacer(flex: 1,),

              Text(
                trackYear.toString(),
                style: TextStyle(
                  color: Colors.deepPurple[300],
                  fontSize: 30,
                  ),
              ),
        
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
                child: Image.network(artwork),
              ),
        
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.deepPurple[400],
                  fontSize: 30
                ),
              ),
        
              Text(
                artist,
                style: TextStyle(
                  color: Colors.deepPurple[200],
                  fontSize: 24
                ),
              ),

              Spacer(flex: 2,)
        
            ],
          ),
        ),
      ),
    );
  }
}