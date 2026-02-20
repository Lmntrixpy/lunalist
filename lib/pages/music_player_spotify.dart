import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:lunalist/pages/song_info.dart';
import 'package:lunalist/services/card_mapper.dart';
import 'package:lunalist/config.dart';

class PlayerSpotify extends StatefulWidget {
  final CardSongMapper mapper;
  final int cardNumber;
  final String gameMode;

  const PlayerSpotify({super.key, required this.mapper, required this.cardNumber, required this.gameMode});

  @override
  State<PlayerSpotify> createState() => _PlayerSpotifyState();
}

class _PlayerSpotifyState extends State<PlayerSpotify> {
  bool isPlaying = true;
  late ({String artist, String artwork, String id, String name, int year}) currentTrack;

  bool isReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    setState(() {
      _error = null;
      isReady = false;
    });

    try {
      await ensureSpotifyConnection().timeout(const Duration(seconds: 12));
      await _playTrack().timeout(const Duration(seconds: 12));

      if (!mounted) return;
      setState(() => isReady = true);
    } on PlatformException catch (_) {
      // User cancel on spotify authorizazion
      if (!mounted) return;
      setState(() {
        _error = "Spotify-Anmeldung abgebrochen oder fehlgeschlagen. Bitte erneut versuchen.";
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _error = "Spotify Verbindung dauert zu lange. Spotify öffnen und erneut versuchen.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> ensureSpotifyConnection() async {
    if (Platform.isAndroid) {
      await SpotifySdk.getAccessToken(
        clientId: AppConfig.spotifyClientId,
        redirectUrl: 'lunalist://android-callback',
        scope: 'app-remote-control streaming',
      );
    }

    final connected = await SpotifySdk.connectToSpotifyRemote(
      clientId: AppConfig.spotifyClientId,
      redirectUrl: "lunalist://android-callback",
    );

    if (connected != true) {
      throw PlatformException(code: "CANCELED", message: "User canceled Spotify auth");
    }
  }

  Future<void> _playTrack() async {
    final track = widget.mapper.scanCard(widget.cardNumber);
    currentTrack = track;

    await SpotifySdk.play(spotifyUri: "spotify:track:${track.id}");
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Spotify"),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Fehler!\n"
                "Versuche es durch Klicken erneut",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 40,),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
              
              const SizedBox(height: 12),
              
              OutlinedButton.icon(
                icon: Icon(Icons.restart_alt_rounded),
                onPressed: _init,
                label: const Text("Erneut versuchen")),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }


    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: !isReady ? null :() {
            SpotifySdk.pause();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SongInfo(mapper: widget.mapper, currentTrack: currentTrack, gameMode: widget.gameMode))
            );
          }, 
          label: Text("Karte aufdecken"),
          icon: Icon(Icons.arrow_right_alt_rounded),
        ),
      
        body: SafeArea(
          child: Column(
            children: [
              Text(
                "Spielmodus: ${widget.gameMode}",
                style: TextStyle(
                  fontSize: 12
                ),
              ),
              
              Spacer(flex: 1),
              
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  "Errate den Song\nund den Artist!",
                  style: TextStyle(fontSize: 28),
                ),
              ),
          
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: IconButton(
                  iconSize: 96,
                  onPressed: !isReady ? null : () {
                    setState(() {
                      if (isPlaying) {
                        SpotifySdk.pause();
                        isPlaying = false;
                      } else {
                        SpotifySdk.resume();
                        isPlaying = true;                        
                      }  
                    });
                  }, icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled)),
              ),
          
              Spacer(flex: 2),
          
            ],
          ),
        ),
      ),
    );
  }
}