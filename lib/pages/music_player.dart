import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioStatus {
  static const platform = MethodChannel('audio_status');

  static Future<bool> isMusicActive() async {
    final result = await platform.invokeMethod('isMusicActive');
    return result as bool;
  }
}

class ControlMusicState extends StatefulWidget {
  const ControlMusicState({super.key});

  @override
  State<ControlMusicState> createState() => _ControlMusicStateState();
}

class _ControlMusicStateState extends State<ControlMusicState> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          onPressed: () async{
            final status = await AudioStatus.isMusicActive();
            setState(() {
              isPlaying = status;
            });
          },
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          iconSize: 64,
          ),
      ),
    );
  }
}