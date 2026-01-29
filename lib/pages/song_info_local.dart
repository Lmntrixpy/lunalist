import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hitster_2/services/local_music.dart';

class SongInfoLocal extends StatefulWidget {
  final String track;

  const SongInfoLocal({super.key, required this.track});

  @override
  State<SongInfoLocal> createState() => _SongInfoLocalState();
}

class _SongInfoLocalState extends State<SongInfoLocal> {
  GetMetadata trackData = GetMetadata();
  String song = "";
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
    await GetMetadata.load(widget.track);
    song = GetMetadata.trackName;
    artist = GetMetadata.trackArtistNames;
    albumArt = GetMetadata.albumArt;
    releaseYear = GetMetadata.releaseYear;
    debugPrint("--------- $song");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        
            Text("Liedname: $songName"),

            Text("Artist: $artist"),

            Padding(
              padding: const EdgeInsets.all(50.0),
              child: albumArt.isNotEmpty
                ? Image.memory(albumArt)
                : const Text("Kein AlbumArt")
            ),

            Text("Realease Year: $releaseYear")

          ],
        ),
      ),
    );
  }
}