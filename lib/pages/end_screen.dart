import 'package:flutter/material.dart';
import 'package:hitster_2/pages/leaderboard.dart';
import 'package:hitster_2/services/rankings.dart';

class EndScreen extends StatefulWidget {
  const EndScreen({super.key});

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  final _textEditingController = TextEditingController();
  String winner = "";

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _submitWinner() async {
    final name = _textEditingController.text.trim();
    if (name.isEmpty) return;

    final ranking = RankingStorage();
    await ranking.setWin(name);

    if (!mounted) return;
    setState(() => winner = name);

    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Leaderboard()),
            );
          },
          label: const Text("Rangliste"),
          icon: const Icon(Icons.leaderboard_rounded),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final isTablet = width >= 700 && width < 1100;
              final isDesktop = width >= 1100;

              final maxContentWidth =
                  isDesktop ? 900.0 : (isTablet ? 750.0 : double.infinity);

              final padding =
                  isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);

              final titleSize =
                  isDesktop ? 40.0 : (isTablet ? 34.0 : 24.0);

              final subtitleSize =
                  isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);

              final form = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Trage hier den Gewinner der Runde ein.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: subtitleSize),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Gewinner",
                      suffixIcon: IconButton(
                        onPressed: _textEditingController.clear,
                        icon: const Icon(Icons.clear_rounded),
                      ),
                    ),
                    onSubmitted: (_) => _submitWinner(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: _submitWinner,
                    label: const Text("Gewinner eintragen"),
                    icon: const Icon(Icons.wine_bar_rounded),
                  ),
                  if (winner.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      "Der Gewinner ist $winner",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              );

              Widget content;

              if (isTablet || isDesktop) {
                // Tablet/Desktop: zentriert, optional zweispaltig
                content = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        "Das Spiel ist vorbei.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 6,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: form,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile: alles untereinander
                content = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Das Spiel ist vorbei.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    form,
                  ],
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: content,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}