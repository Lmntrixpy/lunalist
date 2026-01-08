import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hitster_2/services/local_music.dart';

class Testsonginfo extends StatefulWidget {
  const Testsonginfo({super.key});

  @override
  State<Testsonginfo> createState() => _TestsonginfoState();
}

class _TestsonginfoState extends State<Testsonginfo> {
  String songName = "";
  GetMetadata songData = GetMetadata();
  String song = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.audio);
              if (result == null) {
                song = "";
              } else {
                song = result.paths.whereType<String>().toList().first;
              }
              debugPrint(song);  
            },
            child: Text("Datei wählen")
          ),

          Text("LiedName: $songName")

        ],
      ),
    );
  }
}