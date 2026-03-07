import 'package:flutter/material.dart';

class GameInstructions extends StatelessWidget {
  const GameInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    const double topPadding = 20;
    const double bottomPadding = 8;

    return Scaffold(
      appBar: AppBar(
        title: Text("Spielanleitung"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(bottom: bottomPadding),
              child: Center(child: Text("Materialien", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ),
            Text(
              "- beliebig viele Spielkarten (zu finden in den Einstellungen)\n"
              "- Spielchips\n"
              "- ein Gerät mit Spotify, Apple Music ODER heruntergeladenen mp3-Dateien",
              style: TextStyle(fontSize: 16),
            ),
            
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(top: topPadding, bottom: bottomPadding),
              child: Center(child: Text("Vorbereitung", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ),
            Text(
              "Jeder Spieler kann seine Spotify-Playlist einfügen. Alternativ können auch die Audio-Dateien eingefügt werden.\n"
              "Aus den vorgegebenen Liedern wird zufällig eins ausgewählt, das die Gruppe dann erkennen muss.\n"
              "Jeder Spieler bekommt zu Anfang des Spiels eine Karte. Der QR-Code wird gescannt, das Lied muss noch nicht erkannt werden, sondern wird gleich angezeigt. Das Jahr wird auf die Karte geschrieben. Das ist die Startkarte. An ihr richtet sich der Rest des Spiels aus.\n"
              "Jeder bekommt drei Spielchips.",
              style: TextStyle(fontSize: 16),
            ),
        
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(top: topPadding, bottom: bottomPadding),
              child: Center(child: Text("So wird gespielt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ),
            Text(
              "Nun wird reihum je eine Karte gezogen. Der Spieler, mit den wenigsten Kopfhaaren beginnt.\n"
              "Der QR-Code auf der Karte wird gescannt. Jeder Spieler darf den Songtitel und den Interpreten raten. Der Spieler, der die Karte gezogen hat, muss nun das Lied in eine Zeitspanne einordnen, entweder vor oder nach der bereits  vorliegenden Karte. Danach dürfen die Songinformationen in der App angeschaut, und das Jahr, optional auch Titel und Interpret, auf die Karte geschrieben werden. Ist die Einordnung richtig, darf die Karte behalten werden. Wurde der Song zeitlich falsch eingeordnet, wird die Karte weggelegt.\n"
              "Der Spieler, der zuerst zehn Karten in einer Reihe hat, gewinnt.",
              style: TextStyle(fontSize: 16),
              ),
        
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(top: topPadding, bottom: bottomPadding),
              child: Center(child: Text("Spielchips", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ),
            Text(
              "Die Spielchips können verdient werden, indem Songtitel und / oder Interpreten richtig erraten werden.\n"
              "Ordnet ein Spieler seine Karte in eine Zeitspanne ein, darf jeder andere einen Chip an eine andere Stelle legen, wenn er anderer Meinung ist. Vor, hinter oder zwischen zwei Karten darf je nur ein Chip gelegt werden.\n"
              "Ist die Platzierung eines Chips richtig, bekommt der Spieler, der ihn gelegt hat die Karte und darf sie in seine Zeitleiste einordnen. ",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}