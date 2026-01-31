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
  String trackName = "";
  
  
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
                final tracks = await SpotifyInterface.getPlaylistTracks("https://open.spotify.com/playlist/45bK1ooBB4dbG524i5cDaR?si=8916287399c04720");
                for (final t in tracks) {
                  print(t.artist);
                  print(t.year);
                }
              },
              child: Text("playlistgetter")),
            TextButton(
              onPressed: () async {
                
                await SpotifyInterface().authorize();
                final meta = await SpotifyInterface.getTrackMetadata("2IODVe96sL1fkhcfRgqQ0s");

                setState(() {
                  trackYear = meta.year;
                  artwork = meta.artwork;
                  artist = meta.artist;
                  trackName = meta.name;
                });
              },
              child: Text("auth")
            ),

            Text("year: $trackYear"),
            Text("artist: $artist"),
            Text("track: $trackName"),

            Image.network(artwork)

          ],
        ),
      ),
    );
  }
}