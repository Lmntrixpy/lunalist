import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lunalist/config.dart';
import 'package:lunalist/pages/scanner.dart';
import 'package:lunalist/pages/song_info.dart';
import 'package:lunalist/services/card_mapper.dart';
import 'package:music_kit/music_kit.dart';

class PlayerAppleMusic extends StatefulWidget {
  final CardSongMapper mapper;
  final int cardNumber;
  final String gameMode;

  const PlayerAppleMusic({
    super.key,
    required this.mapper,
    required this.cardNumber,
    required this.gameMode,
  });

  @override
  State<PlayerAppleMusic> createState() => _PlayerAppleMusicState();
}

class _PlayerAppleMusicState extends State<PlayerAppleMusic> {
  final MusicKit _musicKit = MusicKit();

  bool isPlaying = true;
  bool isReady = false;
  String? _error;

  late ({String artist, String artwork, String id, String name, int year})
      currentTrack;

  StreamSubscription<MusicPlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();

    _playerStateSub =
        _musicKit.onMusicPlayerStateChanged.listen((MusicPlayerState state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state.playbackStatus == MusicPlayerPlaybackStatus.playing;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _error = null;
      isReady = false;
    });

    try {
      await ensureAppleMusicConnection().timeout(const Duration(seconds: 12));
      await _playTrack().timeout(const Duration(seconds: 12));

      if (!mounted) return;
      setState(() => isReady = true);
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.code == "CANCELED"
            ? "Apple Music Anmeldung abgebrochen."
            : "Apple Music Fehler: ${e.message ?? e.toString()}";
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _error = "Apple Music Verbindung dauert zu lange. Apple Music öffnen und erneut versuchen.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> ensureAppleMusicConnection() async {

    final status = await _musicKit.requestAuthorizationStatus().timeout(const Duration(seconds: 12));

    if (status is! MusicAuthorizationStatusAuthorized) {
      throw PlatformException(
        code: "CANCELED",
        message: "User did not authorize Apple Music",
      );
    }

    String developerToken;
    try {
      developerToken = await _musicKit.requestDeveloperToken();
    } catch (_) {
      developerToken = AppConfig.appleMusicDeveloperToken;
    }

    String userToken;
    try {
      userToken = await _musicKit.requestUserToken(developerToken);
    } catch (_) {
      userToken = "";
    }

    if (Platform.isAndroid) {
      await _musicKit.initialize(
        developerToken,
        musicUserToken: userToken.isEmpty ? null : userToken,
      );
    }
  }

  Future<void> _playTrack() async {
    final track = widget.mapper.scanCard(widget.cardNumber);
    currentTrack = track;

    final Map<String, dynamic> songResource = {
      "id": track.id,
      "type": "songs",
      "href": "/v1/catalog/us/songs/${track.id}",
      "attributes": {
        "name": track.name,
        "artistName": track.artist,
        "playParams": {
          "id": track.id,
          "kind": "song",
        },
      },
    };

    await _musicKit.setQueue(songResource["type"], item: songResource);
    await _musicKit.play();

    if (!mounted) return;
    setState(() => isPlaying = true);
  }

  Future<void> _stopPlayback() async {
    try {
      await _musicKit.pause();
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return PopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Apple Music"),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Fehler!\nVersuche es durch Klicken erneut",
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(_error!, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.restart_alt_rounded),
                  onPressed: _init,
                  label: const Text("Erneut versuchen"),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await _stopPlayback();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ScannerPage(mapper: widget.mapper, gameMode: widget.gameMode),
                      ),
                    );
                  },
                  label: const Text("Nächste Karte"),
                  icon: const Icon(Icons.arrow_right_alt_rounded),
                ),
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
          onPressed: !isReady
              ? null
              : () async {
                  await _stopPlayback();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongInfo(
                        mapper: widget.mapper,
                        currentTrack: currentTrack,
                        gameMode: widget.gameMode,
                      ),
                    ),
                  );
                },
          label: const Text("Karte aufdecken"),
          icon: const Icon(Icons.arrow_right_alt_rounded),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Text(
                "Spielmodus: ${widget.gameMode}",
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(flex: 1),
              const Center(
                child: Text(
                  "Errate den Song\nund den Artist!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: IconButton(
                  iconSize: 96,
                  onPressed: !isReady
                      ? null
                      : () async {
                          if (isPlaying) {
                            await _musicKit.pause();
                          } else {
                            await _musicKit.play();
                          }
                          if (!mounted) return;
                          setState(() => isPlaying = !isPlaying);
                        },
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}