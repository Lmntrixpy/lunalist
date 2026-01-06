import 'package:flutter/material.dart';
import 'package:hitster_2/services/local_music.dart';

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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cardCountController,
              keyboardType: TextInputType.number,
              autocorrect: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Kartenanzahl",
                hintText: "Wie viele Karten hast du?",
                /* suffix: IconButton(
                  onPressed: () {
                    // TODO: clear textfield
                  },
                  icon: Icon(Icons.clear_rounded)) */
              ),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                // TODO: Fix get Music
                final music = LocalMusic();
                await music.load();
              },
              label: Text("Lieder auswählen"))
          ],
        ),
      ),
    ); 
  }
}