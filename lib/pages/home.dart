import 'package:flutter/material.dart';
import 'package:hitster_2/pages/mode_selector.dart';
import 'package:hitster_2/pages/settings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Willkommen bei APPNAME!\nFalls du noch nie gespielt hast, findest du in den Einstellungen eine Anleitung. Falls doch, drücke einfach auf Start",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 24),

              ),
          ),
      
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
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text("APPNAME",
      style: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold)
        ),
      centerTitle: true,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          icon: Icon(Icons.settings),
          iconSize: 20,
        ),
      ],
    );
  }
}