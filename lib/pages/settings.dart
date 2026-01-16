import 'package:flutter/material.dart';
import 'package:hitster_2/api/spotify-auth.dart';
import 'package:hitster_2/config.dart';
import 'package:hitster_2/pages/about.dart';
import 'package:hitster_2/services/qr_code_creator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool authSuccess = false;
  List<int> cardNumbers = [];

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
                bool result = await spotifyAuth();
                setState(()  {
                  authSuccess = result;
                  // print(authSucess);   
                });
                
              }, 
              icon: Icon(Icons.private_connectivity_rounded),
              label: Text("Teste Verbindung zu Spotify"),
            ),

            Text("Verbindung war: $authSuccess"),
            
            SwitchListTile(
              title: Text("TEMP: Beispieleinstellung"),
              value: true,
              onChanged: (value) {
                // TODO: Handle Setting
              },
              secondary: const Icon(Icons.settings),
            ),

            TextButton(
              onPressed: () {
                QrPdfGenerator.generate(5);
              },
              child: Text("number_gen")
            ),

            Spacer(),
            
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
              },
              label: Text("Über diese App"),
              icon: Icon(Icons.info_rounded),
            ),

            Text(
              "Version: ${AppConfig.version}",
              style: TextStyle(color: Colors.black),
            )
          ],
        )
      ),
    );
  }
}