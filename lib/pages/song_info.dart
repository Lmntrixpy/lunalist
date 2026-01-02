import 'package:flutter/material.dart';

class SongInfo extends StatefulWidget {
  const SongInfo({super.key});

  @override
  State<SongInfo> createState() => _SongInfoState();
}

class _SongInfoState extends State<SongInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Route to QR-Code Scanner Page
        },
        label: Text("Nächste Karte"),
        icon: Icon(Icons.qr_code_rounded),
      ),
      
      body: Center(
        child: Text("Song Info"),
      ),
    );
  }
}