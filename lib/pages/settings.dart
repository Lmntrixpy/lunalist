import 'package:flutter/material.dart';
import 'package:hitster_2/api/spotify-auth.dart';
import 'package:hitster_2/config.dart';
import 'package:hitster_2/pages/about.dart';
import 'package:hitster_2/pages/game_instructions.dart';
import 'package:hitster_2/services/rankings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hitster_2/services/qr_code_creator.dart';

enum BrightnessModes{light, dark, system}

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode)? setThemeMode;
  const SettingsPage({super.key, this.setThemeMode});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {
  late String infoText = "";
  late bool connectionSucces = false;
  List<int> cardNumbers = [];
  TextEditingController textController = TextEditingController();
  int cardCount = 0;
  bool isGenerating = false;

  Set<BrightnessModes> _selected = {BrightnessModes.system}; // Default

  @override
  void initState() {
    super.initState();
    _loadBrightnessMode();
  }

  Future<void> _loadBrightnessMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('brightnessMode');
    setState(() {
      _selected = {
        if (saved == 'light')
          BrightnessModes.light
        else if (saved == 'dark')
          BrightnessModes.dark
        else
          BrightnessModes.system
      };
    });
  }

  Future<void> _saveBrightnessMode(BrightnessModes mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('brightnessMode', mode.name);
  }


  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text("Einstellungen & Spielregeln"),
        centerTitle: true,
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

              Center(
                child: FilledButton.tonalIcon(
                  label: Text("Spielkarten drucken"),
                  icon: Icon(Icons.print_rounded),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false, // optional
                      builder: (dialogContext) {
                        bool isGeneratingDialog = false;

                        return StatefulBuilder(
                          builder: (dialogContext, setDialogState) {
                            return AlertDialog(
                              title: const Text("Kartenanzahl"),
                              content: TextField(
                                controller: textController,
                                autocorrect: false,
                                autofocus: true,
                                enabled: !isGeneratingDialog,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  label: const Text("Wie viele Karten brauchst du?"),
                                  hintText: "Anzahl Karten",
                                  suffix: IconButton(
                                    onPressed: isGeneratingDialog ? null : () => textController.clear(),
                                    icon: const Icon(Icons.clear_rounded),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: isGeneratingDialog
                                      ? null
                                      : () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                  child: Text("Abbrechen"),
                                ),
                                TextButton(
                                  onPressed: isGeneratingDialog
                                      ? null
                                      : () async {
                                          
                                          if (isGeneratingDialog) return;

                                          final value = int.tryParse(textController.text);
                                          if (value == null || value <= 0) return;

                                          setDialogState(() => isGeneratingDialog = true);
                                          
                                          setState(() => isGenerating = true);

                                          try {
                                            await QrPdfGenerator.generateQrOnly(value);
                                            if (dialogContext.mounted) {
                                              Navigator.of(dialogContext).pop();
                                            }
                                          } finally {
                                            if (mounted) setState(() => isGenerating = false);
                                            if (dialogContext.mounted) {
                                              setDialogState(() => isGeneratingDialog = false);
                                            }
                                          }
                                  },
                                  child: isGeneratingDialog
                                      ? const Text("")
                                      : const Text("ohne Rückseite"),
                                ),

                                TextButton(
                                  onPressed: isGeneratingDialog
                                      ? null
                                      : () async {
                                          
                                          if (isGeneratingDialog) return;

                                          final value = int.tryParse(textController.text);
                                          if (value == null || value <= 0) return;

                                          
                                          setDialogState(() => isGeneratingDialog = true);

                                          
                                          setState(() => isGenerating = true);

                                          try {
                                            await QrPdfGenerator.generate(value);
                                            if (dialogContext.mounted) {
                                              Navigator.of(dialogContext).pop();
                                            }
                                          } finally {
                                            if (mounted) setState(() => isGenerating = false);
                                            // falls Dialog noch offen ist:
                                            if (dialogContext.mounted) {
                                              setDialogState(() => isGeneratingDialog = false);
                                            }
                                          }
                                        },
                                  child: isGeneratingDialog
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text("mit Rückseite"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
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
                    connectionSucces = await SpotifyInterface.testConnection();
                    
                    setState(()  {
                      if (connectionSucces) {
                        infoText = "Die Verbindung war erfolgreich";
                      } else {
                        infoText = "Die Verbindung ist fehlgeschlagen";
                      }
                    });
                    
                  }, 
                  icon: Icon(Icons.private_connectivity_rounded),
                  label: Text("Teste Verbindung zu Spotify"),
                ),
              ),

              Center(
                child: Text(
                  infoText,
                  style: TextStyle(fontSize: 12),
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
              Text(
                "Erscheinungsbild",
                style: TextStyle(fontSize: 20),
                ),

              Center(
                child: SegmentedButton<BrightnessModes>(
                  segments: const <ButtonSegment<BrightnessModes>>[
                    ButtonSegment(
                      value: BrightnessModes.light,
                      label: Text("Hell"),
                      icon: Icon(Icons.light_mode_rounded)),
                    ButtonSegment(
                      value: BrightnessModes.dark,
                      label: Text("Dunkel"),
                      icon: Icon(Icons.dark_mode_rounded)),
                    ButtonSegment(
                      value: BrightnessModes.system,
                      label: Text("System"),
                      icon: Icon(Icons.settings_rounded)),
                  ],
                  selected: _selected,
                  onSelectionChanged: (Set<BrightnessModes> newSelection) {
                    final mode = newSelection.first;
                
                    setState(() {
                      _selected = {mode};
                    });
                
                    ThemeMode themeMode;
                
                    switch (mode) {
                      case BrightnessModes.light:
                        themeMode = ThemeMode.light;
                        break;
                      case BrightnessModes.dark:
                        themeMode = ThemeMode.dark;
                        break;
                      case BrightnessModes.system:
                        themeMode = ThemeMode.system;
                        break;
                    }
                
                    if (widget.setThemeMode != null) {
                     widget.setThemeMode!(themeMode);
                    }
                    _saveBrightnessMode(mode);
                  }
                ),
              ),
                      
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
                  style: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}