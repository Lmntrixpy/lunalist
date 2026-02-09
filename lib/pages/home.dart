import 'package:flutter/material.dart';
import 'package:lunalist/pages/leaderboard.dart';
import 'package:lunalist/pages/mode_selector.dart';
import 'package:lunalist/pages/settings.dart';

class HomePage extends StatelessWidget {
  final Function(ThemeMode)? setThemeMode;

  const HomePage({super.key, this.setThemeMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                "Willkommen bei lunalist!\nFalls du noch nie gespielt hast, findest du in den Einstellungen eine Anleitung. Falls doch, drücke einfach auf Start",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
            
                ),
            ),
          ),
      
          Column(
            children: [
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ModeSelector()),
                  );
                },
                label: Text(
                  "Start",
                  style: TextStyle(fontSize: 32),
                ),
                icon: Icon(Icons.start_rounded),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Leaderboard())
                    );
                  },
                  label: Text(
                    "Rangliste",
                    style: TextStyle(fontSize: 32),
                  ),
                  icon: Icon(Icons.leaderboard_rounded),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text("lunalist"),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(setThemeMode: setThemeMode)),
            );
          },
          icon: Icon(Icons.settings),
          iconSize: 20,
        ),
      ],
    );
  }
}