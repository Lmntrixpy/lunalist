import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:lunalist/config.dart';

class TestSpotifySdkPage extends StatefulWidget {
  const TestSpotifySdkPage({super.key});

  @override
  State<TestSpotifySdkPage> createState() => _TestSpotifySdkPageState();
}

class _TestSpotifySdkPageState extends State<TestSpotifySdkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                await SpotifySdk.getAccessToken(clientId: AppConfig.clientId, redirectUrl: "spotify-ios-quick-start://spotify-login-callback"); // for android???
                await SpotifySdk.connectToSpotifyRemote(clientId: AppConfig.clientId, redirectUrl: "spotify-ios-quick-start://spotify-login-callback");
                SpotifySdk.play(spotifyUri: "spotify:track:1O28S9MYZONNh5PNG1bYeC");

              },
              child: Text("initilise SDK")
            ),

            TextButton(
              onPressed: () {
                SpotifySdk.pause();
              },
              child: Text("Pause"))

          ],
        ),
      ),
    );
  }
}