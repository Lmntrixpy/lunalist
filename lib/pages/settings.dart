import 'package:flutter/material.dart';
import 'package:hitster_2/api/spotify-auth.dart';
import 'package:hitster_2/config.dart';
import 'package:hitster_2/pages/about.dart';
import 'package:hitster_2/pages/game_instructions.dart';
import 'package:hitster_2/services/rankings.dart';
// import 'package:hitster_2/services/qr_code_creator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ({String artist, String artwork, String name, int year}) metadata;
  late String cover = "";
  late String infoText = "";
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Spielregeln",
                style: TextStyle(fontSize: 24),
              ),
              
              Center(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameInstructions())
                    );
                  }, 
                  icon: Icon(Icons.link, size: 24,),
                  label: Text("Spielregeln anzeigen", style: TextStyle(fontSize: 18),),
                  
                ),
              ),
          
              Text(
                "Einstellungen",
                style: TextStyle(fontSize: 24),
              ),
          
              Center(
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    SpotifyInterface().authorize();
                    metadata = await SpotifyInterface.getTrackMetadata("1x19UqLfi99ISgtBwfXb0m");
                    cover = metadata.artwork;
                    
                    setState(()  {
                      infoText = "Wenn du ein Capybara siehst,\ndann war die Verbindung erfolgreich";
                      cover = metadata.artwork;
                    });
                    
                  }, 
                  icon: Icon(Icons.private_connectivity_rounded),
                  label: Text("Teste Verbindung zu Spotify"),
                ),
              ),
          
              Text(
                "Rangliste",
                style: TextStyle(fontSize: 20),
              ),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () async{
                      try {
                        final rankingStorage = RankingStorage();
                        await rankingStorage.importRanking(merge: true);
                        setState(() {});
                      } on InvalidRankingImport catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    label: Text("Importieren"),
                    icon: Icon(Icons.download_rounded),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final rankingStorage = RankingStorage();
                      await rankingStorage.exportRanking();
                    },
                    label: Text("Exportieren"),
                    icon: Icon(Icons.upload_rounded),
                  )
                ],
              ),
          
              cover.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Center(child: Text(infoText, textAlign: TextAlign.center,)),
              )
              : SizedBox(width: 0, height: 0),
          
              cover.isNotEmpty 
              ? Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Image.network(cover),
                )
              : SizedBox(width: 0, height: 0,),
              
          
          
              /*
              TextButton(
                onPressed: () {
                  QrPdfGenerator.generate(5);
                },
                child: Text("number_gen")
              ), 
              */
          
              Spacer(),
              
              Center(
                child: TextButton.icon(
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
              ),
          
              Center(
                child: Text(
                  "Version: ${AppConfig.version}",
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}