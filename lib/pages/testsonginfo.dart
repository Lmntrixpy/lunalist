import 'package:file_picker/file_picker.dart';
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
                });
              },
              child: Text("Datei wählen")
            ),
        
            Text("LiedName: $songName")
        
          ],
        ),
      ),
    );
  }
}