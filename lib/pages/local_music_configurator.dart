import 'package:flutter/material.dart';
import 'package:hitster_2/services/local_music.dart';

/*
class LocalMusicConfigurator extends StatelessWidget {
  const LocalMusicConfigurator({super.key});

  @override
  Widget build(BuildContext context) {
    final cardCountController = TextEditingController();


    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Modus"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: push to Play Page
        },
        label: Text("Weiter"),
        icon: Icon(Icons.music_note_rounded),
        ),
        

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  // TODO: Fix get Music
                  final music = LocalMusic();
                  tracks = await music.load();
                },
                label: Text("Lieder auswählen")),
            )
          ],
        ),
      ),
    ); 
  }
}
*/

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