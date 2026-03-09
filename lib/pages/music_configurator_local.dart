import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lunalist/pages/scanner.dart';
import 'package:lunalist/services/card_mapper.dart';
import 'package:lunalist/services/local_music.dart';


class LocalMusicConfigurator extends StatefulWidget {
  const LocalMusicConfigurator({super.key});

  @override
  State<LocalMusicConfigurator> createState() => _LocalMusicConfiguratorState();
}

class _LocalMusicConfiguratorState extends State<LocalMusicConfigurator> {
  List<String> tracks = [];
  bool musicLoadstatus = false;
  final gameMode = "local";

  Future<void> _showInvalidFolderDialog(List<String> invalidFolders) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ordnername nicht unterstützt"),
        content: Text(
          "Einige Songs konnten nicht geladen werden, weil ein Ordner im Pfad Sonderzeichen enthält.\n\n"
          "Betroffene Ordner:\n${invalidFolders.join("\n")}\n\n"
          "Bitte benenne diese Ordner um und versuche es erneut.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Modus"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (musicLoadstatus != true) {
            final music = LocalMusic();
            final result = await music.load();

            tracks = result.validTracks;


            if (result.invalidFolders.isNotEmpty && context.mounted) {
              await _showInvalidFolderDialog(result.invalidFolders);
            }

            setState(() {
              if (tracks.isEmpty) {
                debugPrint("-------- Selection is empty, cant go forward");
                musicLoadstatus = false;
              } else {
                musicLoadstatus = true;
                debugPrint("----------- Count Songs: ${tracks.length.toString()}");
              }
            });
          } else {
            final mapper = CardSongMapper.fromStringList(tracks);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScannerPage(mapper: mapper, gameMode: gameMode))
            );
          } 
        },
        label: Text(musicLoadstatus ? "Weiter" : "Musik auswählen"),
        icon: Icon(musicLoadstatus ? Icons.start_rounded : Icons.music_note_rounded),
      ),
      
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Text(
                "Das ist der Offline Musik Modus. Es kann mit bereits vorhandenen Musikdateien (mp3) gespielt werden.\n"
                "Bitte wähle deine gewünschten Songs aus deinen Dateien aus.",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Text(
            "Du hast ${tracks.length} Lieder ausgewählt.",
            style: TextStyle(fontSize: 20),
            )
        ],
      ),
    );
  }
}