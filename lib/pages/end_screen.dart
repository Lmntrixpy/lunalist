import 'package:flutter/material.dart';
import 'package:hitster_2/pages/home.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage())
          );   
        },
        label: Text("Zum Hauptmenü"),
        icon: Icon(Icons.home_rounded),
      ),
      
      body: Center(child: Text("End Screen, Das Spiel ist vorbei wuhu")),
    );
  }
}