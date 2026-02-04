import 'package:flutter/material.dart';
import 'package:hitster_2/api/spotify-auth.dart';
import 'package:hitster_2/config.dart';
import 'package:hitster_2/pages/about.dart';
import 'package:hitster_2/pages/game_instructions.dart';
import 'package:hitster_2/services/qr_code_creator.dart';
import 'package:hitster_2/services/rankings.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 500 && width < 1400;
            final isDesktop = width >= 1400;

            final maxContentWidth =
                isDesktop ? 900.0 : (isTablet ? 750.0 : double.infinity);

            final padding =
                isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);

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
                              SpotifyInterface().authorize();
                              connectionSucces = await SpotifyInterface.testConnection();

                              setState(() {
                                infoText = connectionSucces
                                    ? "Die Verbindung war erfolgreich"
                                    : "Die Verbindung ist fehlgeschlagen";
                              });
                            },
                            icon: const Icon(Icons.private_connectivity_rounded),
                            label: const Text("Teste Verbindung zu Spotify"),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Center(child: Text(infoText, style: const TextStyle(fontSize: 12))),
                        const SizedBox(height: 24),

                        const Text("Rangliste", style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),

                        Row(
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
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                final rankingStorage = RankingStorage();
                                await rankingStorage.exportRanking();
                              },
                              label: const Text("Exportieren"),
                              icon: const Icon(Icons.upload_rounded),
                            ),
                          ],
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