import 'package:flutter/material.dart';
import 'package:hitster_2/api/spotify-auth.dart';

class SongInfo extends StatefulWidget {
  const SongInfo({super.key});

  @override
  State<SongInfo> createState() => _SongInfoState();
}

class _SongInfoState extends State<SongInfo> {
  // TODO: load stuff before page opens, on page before in background
  String trackId = "5Gf7tvReZyeXAXy3RVGFfC"; // TODO: gets pushed from page before
  int trackYear = 0;
  String artwork = "";
  String artist = "";

  @override
  void initState() {
    super.initState();
    _loadTrack(); // async-Funktion aufrufen
  }

  Future<void> _loadTrack() async {
    final spotifyInterface = SpotifyInterface();
    spotifyInterface.authorize();
    final meta = await spotifyInterface.getTrackMetadata(trackId);

    if (!mounted) return; // Safety Check

    setState(() {
      trackYear = meta.year;
      artwork = meta.artwork;
      artist = meta.artist;
      }
    );
  }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              trackYear.toString(),
              style: TextStyle(
                color: Colors.deepPurple[300],
                fontSize: 30,
                ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
              child: Image.network(artwork),
            ),

            Text(
              artist,
              style: TextStyle(
                color: Colors.deepPurple[400],
                fontSize: 30
              ),
            )

          ],
        ),
      ),
    );
  }
}