import 'package:flutter/material.dart';

class PlayerInput extends StatefulWidget {
  const PlayerInput({super.key});

  @override
  State<PlayerInput> createState() => _PlayerInputState();
}

class _PlayerInputState extends State<PlayerInput> {
  bool isPlayerRandomized = false;
  int playerCount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Player Input",
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold)
          ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            Text(
              "Wer spielt mit?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
            ),

            SwitchListTile(
              title: Text("Reihenfolge vertauschen?"),
              value: isPlayerRandomized,
              onChanged: (value) {
                setState(() {
                  isPlayerRandomized = value;
                  }
                );
              },
              secondary: const Icon(Icons.shuffle),
            ),

            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (playerCount > 1) {
                    setState(() => playerCount--);
                  }
                },
              ),
              Text(
                "$playerCount Spieler",
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() => playerCount++);
                },
              ),
            ],
          ),

          Expanded(
            child: ListView(
              children: List.generate(
                playerCount,
                (i) => Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Spieler ${i + 1}",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}