import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hitster_2/pages/end_screen.dart';
import 'package:hitster_2/pages/scanner.dart';
import 'package:hitster_2/services/card_mapper.dart';
import 'package:hitster_2/services/local_music.dart';

class SongInfoLocal extends StatefulWidget {
  final String currentTrack;
  final CardSongMapper mapper;
  final String gameMode;

  const SongInfoLocal({super.key, required this.currentTrack, required this.mapper, required this.gameMode});

  @override
  State<SongInfoLocal> createState() => _SongInfoLocalState();
}

class _SongInfoLocalState extends State<SongInfoLocal> {
  GetMetadata trackData = GetMetadata();
  String songName = "";
  List<String> artist = [];
  Uint8List albumArt = Uint8List(0);
  int releaseYear = 0;

   @override
  void initState() {
  super.initState();

  if (!mounted) return;
   
  _getTrackData();
  }

  Future<void> _getTrackData() async {
    await GetMetadata.load(widget.currentTrack);
    
    setState(() {
      songName = GetMetadata.trackName;
      artist = GetMetadata.trackArtistNames;
      albumArt = GetMetadata.albumArt;
      releaseYear = GetMetadata.releaseYear;  
    });
    
    debugPrint("--------- $songName");
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
                  style: TextStyle(fontSize: 12),
                ),
      
                Spacer(flex: 1,),
      
                Text(
                  releaseYear.toString(),
                  style: TextStyle(fontSize: 30,),
                ),
          
                Padding(
                padding: const EdgeInsets.all(50.0),
                child: albumArt.isNotEmpty
                  ? Image.memory(albumArt)
                  : const Text("Kein AlbumArt")
                ),
          
                Text(
                  songName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30),
                ),
          
                Text(artist.first),
      
                Spacer(flex: 2,)
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}