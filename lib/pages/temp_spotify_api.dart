import 'package:flutter/material.dart';
import 'package:hitster_2/api/spotify-auth.dart';

class TempSpotifyApiPage extends StatefulWidget {
  const TempSpotifyApiPage({super.key});

  @override
  State<TempSpotifyApiPage> createState() => _TempSpotifyApiPageState();
}

class _TempSpotifyApiPageState extends State<TempSpotifyApiPage> {
  int trackYear = 0;
  String artwork = "";
  String artist = "";
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TempAPI"),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final spotifyInterface = SpotifyInterface();
                spotifyInterface.authorize();
                final meta = await spotifyInterface.getTrackMetadata("2IODVe96sL1fkhcfRgqQ0s");

                setState(() {
                  trackYear = meta.year;
                  artwork = meta.artwork;
                  artist = meta.artist;
                });
              },
              child: Text("auth")
            ),

            Text("year: $trackYear"),
            Text("year: $artist"),

            Image.network(artwork)

          ],
        ),
      ),
    );
  }
}