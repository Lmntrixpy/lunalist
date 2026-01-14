import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hitster_2/services/local_music.dart';

class Testsonginfo extends StatefulWidget {
  const Testsonginfo({super.key});

  @override
  State<Testsonginfo> createState() => _TestsonginfoState();
}

class _TestsonginfoState extends State<Testsonginfo> {
  GetMetadata songData = GetMetadata();
  String song = "";
  String songName = "";
  List<String> artist = [];
  Uint8List albumArt = Uint8List(0);
  int releaseYear = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TestSongInfo"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ["mp3"]
                  );

                if (result == null) return;
                
                final song = result.paths.whereType<String>().toList().first;
                await GetMetadata.load(song);

                debugPrint("---------- $song");
                setState(() {
                  songName = GetMetadata.trackName;
                  artist = GetMetadata.trackArtistNames;
                  albumArt = GetMetadata.albumArt;
                  releaseYear = GetMetadata.releaseYear;

                  print("--------- $releaseYear");
                });
              },
              child: Text("Datei wählen")
            ),
        
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