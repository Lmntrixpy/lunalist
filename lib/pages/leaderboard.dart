import 'package:flutter/material.dart';
import 'package:lunalist/pages/home.dart';
import 'package:lunalist/services/rankings.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final rankingStorage = RankingStorage();
  final double rankingTextSize = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rangliste"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const HomePage())
          ); 
        },
        label: Text("Hauptmenü"),
        icon: Icon(Icons.home_rounded),
      ),
      
      body: Center(
        child: Column(
          children: [
            Text("Platz, Person, Anzahl an Siegen", style: TextStyle(fontSize: 16),),
            Expanded(
              child: FutureBuilder(
                future: RankingStorage().getAll(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final ranking = snapshot.data!;
              
                  return ListView.builder(
                    itemCount: ranking.length,
                    itemBuilder: (context, index) {
                      final entry = ranking[index];
                      return ListTile(
                        leading: Text("#${index +1 }", style: TextStyle(fontSize: rankingTextSize - 4),),
                        title: Text(entry.name, style: TextStyle(fontSize: rankingTextSize),),
                        trailing: Text(entry.wins.toString(), style: TextStyle(fontSize: rankingTextSize),),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        )
      )
    );
  }
}