import 'package:flutter/material.dart';
import 'package:lunalist/api/spotify_http.dart';
import 'package:lunalist/api/update_service_http.dart';
import 'package:lunalist/config.dart';
import 'package:lunalist/pages/about.dart';
import 'package:lunalist/pages/game_instructions.dart';
import 'package:lunalist/pages/playlist_edit.dart';
import 'package:lunalist/services/preloaded_playlists.dart';
import 'package:lunalist/services/qr_code_creator.dart';
import 'package:lunalist/services/rankings.dart';
import 'package:lunalist/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool experimentalMode = false;
  bool checkUpdateOnStartup = true;
  bool cameraAccess = true;
  bool useUserSpotifyTokens = false;

  late String userSpotifyId;
  late String userSpotifySecret;

  Set<BrightnessModes> _selected = {BrightnessModes.system}; // Default

  @override
  void initState() {
    super.initState();
    _loadBrightnessMode();
    _loadExperimentalMode();
    _loadUpdateOnStartup();
    _loadCameraAcess();
    _loadUseUserSpotifyTokens();
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

  Future<void> _loadExperimentalMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool("experimentalMode");
    setState(() {
      if (saved != null) {
        debugPrint(experimentalMode.toString());
        experimentalMode = saved;
      }
    });
  }

  Future<void> _saveExperimentalMode(bool experimentalMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("experimentalMode", experimentalMode);
    debugPrint(experimentalMode.toString());
  }

  Future<void> _loadUpdateOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool("checkUpdateOnStartup");
    setState(() {
      if (saved != null) {
        debugPrint(checkUpdateOnStartup.toString());
        checkUpdateOnStartup = saved;
      }
    });
  }

  Future<void> _saveUpdateOnStartup(bool checkUpdateOnStartup) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("checkUpdateOnStartup", checkUpdateOnStartup);
    debugPrint(checkUpdateOnStartup.toString());
  }

  // Camera Acess
  Future<void> _saveCameraAccess(bool cameraAccess) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("cameraAccess", cameraAccess);
    debugPrint(cameraAccess.toString());
  }

  Future<void> _loadCameraAcess() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool("cameraAccess");
    setState(() {
      if (saved != null) {
        debugPrint(cameraAccess.toString());
        cameraAccess = saved;
      }
    });
  }

  // Use user Spotify Tokens
  Future<void> _saveUseUserSpotifyTokens(bool useUserSpotifyTokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("useUserSpotifyTokens", cameraAccess);
    debugPrint(cameraAccess.toString());
  }

  Future<void> _loadUseUserSpotifyTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool("useUserSpotifyTokens");
    setState(() {
      if (saved != null) {
        debugPrint(useUserSpotifyTokens.toString());
        useUserSpotifyTokens = saved;
      }
    });
  }

  // get Spotify Credentials
  Future<void> _loadUserSpotifyTokens() async {
    final userSpotifyIdLocal = await SecureStorageService.instance.getId("spotify");
    final userSpotifySecretLocal = await SecureStorageService.instance.getSecret("spotify");
    setState(() {
      userSpotifyId = userSpotifyIdLocal;
      userSpotifySecret = userSpotifySecretLocal;
    });
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 500 && width < 1400;
            final isDesktop = width >= 1400;

            final maxContentWidth = isDesktop ? 900.0 : (isTablet ? 750.0 : double.infinity);

            final padding = isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);

            final String playlistAssetPath = "assets/packs/playlists_Spotify.csv";

            final clientIdController = TextEditingController();
            final clientSecretController = TextEditingController();

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Scrollbar(
                  thumbVisibility: isDesktop,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Spielregeln", style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 12),

                        Center(
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GameInstructions()),
                              );
                            },
                            icon: const Icon(Icons.link, size: 24),
                            label: const Text("Spielregeln anzeigen", style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Center(
                          child: FilledButton.tonalIcon(
                            label: const Text("Spielkarten drucken"),
                            icon: const Icon(Icons.print_rounded),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
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
                                                      await QrPdfGenerator.generateQrOnly(value, context: dialogContext);
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
                                                      await QrPdfGenerator.generate(value, context: dialogContext);
                                                      if (dialogContext.mounted) {
                                                        Navigator.of(dialogContext).pop();
                                                      }
                                                    } finally {
                                                      if (mounted) setState(() => isGenerating = false);
                                                      // quit if dialog is still open
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
                                }
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 28),
                        const Text("Einstellungen", style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 12),

                        Center(
                          child: FilledButton.tonalIcon(
                            onPressed: () async {
                              late final String clientId;
                              late final String clientSecret;
                              if (useUserSpotifyTokens) {
                                debugPrint("uses user stuff");
                                await _loadUserSpotifyTokens();
                                clientId = userSpotifyId;
                                clientSecret = userSpotifySecret;
                              } else {
                                clientId = AppConfig.spotifyClientId;
                                clientSecret = AppConfig.spotifyClientSecret;
                              }
                              
                              final spotifyHttp = SpotifyHttp(
                                clientId: clientId,
                                clientSecret: clientSecret
                              );

                              connectionSucces = await spotifyHttp.testConnection(market: "DE");

                              setState(() {
                                infoText = connectionSucces
                                    ? "Die Verbindung war erfolgreich"
                                    : "Die Verbindung ist fehlgeschlagen";
                              });
                              
                              if(!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(infoText))
                              );
                            },
                            icon: const Icon(Icons.private_connectivity_rounded),
                            label: const Text("Teste Verbindung zu Spotify"),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: FilledButton.tonalIcon(
                            onPressed: () async {
                              final versionApi = LunalistVersionApi();
                              late final dynamic check;

                              try {
                                check = await versionApi.check(current: AppConfig.version);
                              } on LunalistApiException catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Fehler bei Suche nach Updates\nFehler: ${e.toString()}",
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (check == null) return;

                              final String updateText = check.updateAvailable
                                  ? "Ein Update ist verfügbar: ${check.latest}\nDeine Version: ${AppConfig.version}"
                                  : "Du bist auf der neuesten Version: ${AppConfig.version}";

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(updateText)),
                              );
                            },
                            label: Text("Nach Updates suchen"),
                            icon: Icon(Icons.update_rounded),
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        Center(
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              QrPdfGenerator.clearTempCache();
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Temporäre Dateien gelöscht.")),
                              );
                            },
                            label: Text("Cache leeren"),
                            icon: Icon(Icons.delete_forever_rounded),
                          ),
                        ),

                        const SizedBox(height: 8),

                        

                        const Text("Rangliste", style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),

                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () async {
                                  try {
                                    final rankingStorage = RankingStorage();
                                    await rankingStorage.importRanking(merge: true);
                          
                                    if (!context.mounted) return;
                          
                                    setState(() {});
                                  } on InvalidRankingImport catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                },
                                label: const Text("Importieren"),
                                icon: const Icon(Icons.download_rounded),
                              ),

                              SizedBox(height: 8),

                              FilledButton.tonalIcon(
                                onPressed: () async {
                                  final rankingStorage = RankingStorage();
                                  await rankingStorage.exportRanking();
                                },
                                label: const Text("Exportieren"),
                                icon: const Icon(Icons.upload_rounded),
                              ),

                              SizedBox(height: 8,),
                          
                              FilledButton.tonalIcon(
                                onPressed: () async {
                                  final rankingStorage = RankingStorage();
                                  await rankingStorage.deleteRankingsFile();

                                  if(!context.mounted) return;
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Die Rangliste wurde zurückgesetzt"))
                                  );
                                },
                                label: Text("Zurücksetzen"),
                                icon: Icon(Icons.delete_forever_rounded),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text("Packs", style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),

                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Edit
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlaylistCsvEditorPage(
                                        store: PlaylistCsvStore(assetPath: 'assets/playlists.csv'),
                                        title: 'Packs verwalten',
                                      ),
                                    ),
                                  );
                                },
                                label: Text("Bearbeiten"),
                                icon: Icon(Icons.edit_rounded),
                              ),

                              SizedBox(height: 8),
                              
                              // Import
                              FilledButton.tonalIcon(
                                onPressed: () async {
                                  final store = PlaylistCsvStore(assetPath: playlistAssetPath);

                                  try {
                                    await store.importFromPicker();

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Importieren erfolgreich"))
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Importieren fehlgeschlagen!"))
                                    );
                                  }
                                },
                                label: Text("Importieren"),
                                icon: Icon(Icons.download_rounded),
                              ),

                              SizedBox(height: 8),
                              
                              // Export
                              FilledButton.tonalIcon(
                                onPressed: () async {
                                  final store = PlaylistCsvStore(assetPath: playlistAssetPath);
                                  await store.load();

                                  if (!context.mounted) return;
                                  await store.exportAndShare(context);
                                },
                                label: Text("Exportieren"),
                                icon: Icon(Icons.upload_rounded),
                              ),

                              SizedBox(height: 8),

                              // Reset
                              FilledButton.tonalIcon(
                                onPressed: () async {
                                  final store = PlaylistCsvStore(assetPath: playlistAssetPath);
                                  await store.resetFromAssets();
                                  debugPrint("file deleted");
                                },
                                label: Text("Zurücksetzen"),
                                icon: Icon(Icons.delete_forever_rounded),
                              ),

                              SizedBox(height: 8),
                            ],
                          ),
                        ),


                        const SizedBox(height: 24),
                        const Text("Erscheinungsbild", style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),

                        Center(
                          child: SegmentedButton<BrightnessModes>(
                            segments: const <ButtonSegment<BrightnessModes>>[
                              ButtonSegment(
                                value: BrightnessModes.light,
                                label: Text("Hell"),
                                icon: Icon(Icons.light_mode_rounded),
                              ),
                              ButtonSegment(
                                value: BrightnessModes.dark,
                                label: Text("Dunkel"),
                                icon: Icon(Icons.dark_mode_rounded),
                              ),
                              ButtonSegment(
                                value: BrightnessModes.system,
                                label: Text("System"),
                                icon: Icon(Icons.settings_rounded),
                              ),
                            ],
                            selected: _selected,
                            onSelectionChanged: (newSelection) {
                              final mode = newSelection.first;

                              setState(() => _selected = {mode});

                              final themeMode = switch (mode) {
                                BrightnessModes.light => ThemeMode.light,
                                BrightnessModes.dark => ThemeMode.dark,
                                BrightnessModes.system => ThemeMode.system,
                              };

                              widget.setThemeMode?.call(themeMode);
                              _saveBrightnessMode(mode);
                            },
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text("Entwickleroptionen", style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),

                        SwitchListTile(
                          value: experimentalMode, 
                          onChanged: (bool newValue) async {
                            setState(() {
                              experimentalMode = newValue;
                              _saveExperimentalMode(experimentalMode);
                              
                            });
                          },
                          title: Text("Experimentiermodus"),
                        ),

                        const SizedBox(height: 8,),

                        SwitchListTile(
                          value: checkUpdateOnStartup, 
                          onChanged: (bool newValue) async {
                            setState(() {
                              checkUpdateOnStartup = newValue;
                              _saveUpdateOnStartup(checkUpdateOnStartup);  
                            });
                          },
                          title: Text("Automatisch nach Updates suchen"),
                        ),

                        const SizedBox(height: 8,),

                        SwitchListTile(
                          value: cameraAccess, 
                          onChanged: (bool newValue) async {
                            setState(() {
                              cameraAccess = newValue;
                              _saveCameraAccess(cameraAccess);  
                            });
                          },
                          title: Text("Kamera zum Scannen nutzen"),
                        ),

                        const SizedBox(height: 8),

                        SwitchListTile(
                          value: useUserSpotifyTokens,
                          onChanged: (bool newValue) async {
                            setState(() {
                              useUserSpotifyTokens = newValue;
                              _saveUseUserSpotifyTokens(useUserSpotifyTokens);
                            });
                          },
                          title: Text("Eigene Spotify Tokens verwenden"),
                        ),

                        if (useUserSpotifyTokens)
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Spotify Access Tokens"),
                                        content: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: clientIdController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: "Client Id",
                                                labelText: "Spotfiy Client Id" 
                                              )
                                            ),
                                            
                                            SizedBox(height: 12,),
                                
                                            TextField(
                                              controller: clientSecretController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: "Client Secret",
                                                labelText: "Spotify Client Secret"
                                              ),
                                            )
                                          ],
                                        ),
                                
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            }, 
                                            child: Text("Abbrechen")
                                            ),
                                
                                          TextButton(
                                            onPressed: () async {
                                              await SecureStorageService.instance.saveId("spotify", clientIdController.text.trim()); // save spotify client id
                                              await SecureStorageService.instance.saveSecret("spotify", clientSecretController.text.trim()); // save spotify client secret
                                              debugPrint("Gespeichert");
                                              if (!context.mounted) return;
                                              Navigator.pop(context);
                                            }, 
                                            child: Text("Speichern")
                                          )
                                        ], 
                                      )
                                    );
                                  },
                                  label: Text("Spotify Access Tokens"),
                                  icon: Icon(Icons.security_rounded),
                                ),

                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    showDialog(
                                      context: context, 
                                      builder: (context) => AlertDialog(
                                        title: Text("Spotify Tokens"),
                                        content: Text("Um eigene Spotify-Zugangsdaten zu verwenden, erstelle im Spotify Developer Dashboard eine neue App und aktiviere bei den verwendeten APIs die Web API."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            }, 
                                            child: Text("Schließen"))
                                        ],
                                      )
                                    );
                                  },
                                  label: Text("Info"),
                                  icon:  Icon(Icons.info_rounded),
                                )
                              ],
                            )
                          ),                        

                        const SizedBox(height: 28),

                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AboutPage()),
                              );
                            },
                            label: const Text("Über diese App"),
                            icon: const Icon(Icons.info_rounded),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            "Version: ${AppConfig.version}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}