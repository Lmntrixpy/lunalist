import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:lunalist/pages/song_info.dart';
import 'package:lunalist/services/card_mapper.dart';
import 'package:lunalist/config.dart';
import 'package:lunalist/api/soundcloud_http.dart';

class PlayerSoundCloud extends StatefulWidget {
  final CardSongMapper mapper;
  final int cardNumber;
  final String gameMode;

  const PlayerSoundCloud({
    super.key,
    required this.mapper,
    required this.cardNumber,
    required this.gameMode,
  });

  @override
  State<PlayerSoundCloud> createState() => _PlayerSoundCloudState();
}

class _PlayerSoundCloudState extends State<PlayerSoundCloud> {
  final _player = AudioPlayer();

  bool isPlaying = true;
  late ({String artist, String artwork, String id, String name, int year}) currentTrack;

  bool isReady = false;
  String? _error;

  late final SoundCloudHttp _sc;

  @override
  void initState() {
    super.initState();
    _sc = SoundCloudHttp(
      clientId: AppConfig.soundcloudClientId,
      clientSecret: AppConfig.soundcloudClientSecret,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _player.dispose();
    _sc.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _error = null;
      isReady = false;
      isPlaying = true;
    });

    try {
      await _playTrack().timeout(const Duration(seconds: 12));

      if (!mounted) return;
      setState(() => isReady = true);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _error = "SoundCloud Verbindung dauert zu lange. Erneut versuchen.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _playTrack() async {
    final track = widget.mapper.scanCard(widget.cardNumber);
    currentTrack = track;

    final src = await _sc.getPlayableSource(trackId: track.id);

    await _player.setAudioSource(
      AudioSource.uri(src.uri, headers: src.headers),
    );
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return PopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("SoundCloud"),
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
                  await _player.pause();
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
                            await _player.pause();
                          } else {
                            await _player.play();
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