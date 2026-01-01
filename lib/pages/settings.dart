import 'package:flutter/material.dart';
import 'package:hitster_2/api/spotify-auth.dart';
import 'package:hitster_2/config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.white,
    extendBody: true,
    appBar: AppBar(
        title: Text("Einstellungen & Spielregeln",
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold)
          ),
        centerTitle: true,
        backgroundColor: Colors.white,
        ),
    
    body: SafeArea(
      top: false,
      bottom: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Spielregeln",
            style: TextStyle(fontSize: 24),
          ),
          
          FilledButton.icon(
            onPressed: () {
              // TODO: Spielregeln;
            }, 
            icon: Icon(Icons.link, size: 24,),
            label: Text("Spielregeln anzeigen", style: TextStyle(fontSize: 18),),
            
          ),

          Text(
            "Einstellungen",
            style: TextStyle(fontSize: 24),
          ),

          FilledButton.icon(
            onPressed: () async {
              bool auth_sucess = await spotifyAuth(); 
            }, 
            icon: Icon(Icons.private_connectivity_rounded),
            label: Text("Teste Verbindung zu Spotify"),
          ),
          
          SwitchListTile(
            title: Text("TEMP: Beispieleinstellung"),
            value: true,
            onChanged: (value) {
              // TODO: Handle Setting
            },
            secondary: const Icon(Icons.settings),
          ),

          Spacer(),
          
          Text(
            "Version: ${AppConfig.version}",
            style: TextStyle(color: Colors.black),
            )
          ],
        ),  
      ),
    );
  }
}