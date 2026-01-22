import 'package:flutter/material.dart';
import 'package:hitster_2/services/local_music.dart';


class LocalMusicConfigurator extends StatefulWidget {
  const LocalMusicConfigurator({super.key});

  @override
  State<LocalMusicConfigurator> createState() => _LocalMusicConfiguratorState();
}

class _LocalMusicConfiguratorState extends State<LocalMusicConfigurator> {
  List<String> tracks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Modus"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final music = LocalMusic();
          tracks = await music.load();
          
        },
        label: Text("Musik auswählen"),
        icon: Icon(Icons.music_note_rounded),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Text(
          "Das ist der Offline Musik Modus. Es kann mit bereits vorhandenen Musikdateien (mp3) gespielt werden.\nBitte wähle deine gewünschten Songs aus deinen Dateien aus.",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}