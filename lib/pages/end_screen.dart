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

  late String winner = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Leaderboard())
          );   
        },
        label: Text("Rangliste"),
        icon: Icon(Icons.leaderboard_rounded),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Text(
                "Das Spiel ist vorbei.",
                style: TextStyle(fontSize: 24),    
              )
            ),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: Text(
                      "Trage hier den Gewinner der Runde ein.",
                      style: TextStyle(
                        fontSize: 16
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Gewinner",
                        suffixIcon: IconButton(
                          onPressed: () {
                            _textEditingController.clear();
                          },
                          icon: Icon(Icons.clear_rounded))
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      winner = _textEditingController.text.trim();
                      final ranking = RankingStorage();
                      await ranking.setWin(winner);
                      _textEditingController.clear();
                    },
                    label: Text("Gewinner eintragen"),
                    icon: Icon(Icons.wine_bar_rounded),
                  )
                ],
              ),
            ),

            winner.isNotEmpty
            ? Text("Der Gewinner ist $winner")
            : SizedBox(height: 0,)
          ],
        ),
      ),
    );
  }
}