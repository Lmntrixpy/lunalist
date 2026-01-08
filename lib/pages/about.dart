import 'package:flutter/material.dart';
import 'package:hitster_2/config.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Über diese App"),
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Diese App wurde entwickelt für den Informatikunterricht der 12. Klasse am Gymnasium Christian Gottlieb Reichard in Bad Lobenstein von Jeremy Fröb und Emily Schwerdtner.",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.justify,
                
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: DecoratedBox(
                  
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(15)
                    
                  ),
                  
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Danksagungen",
                      style: TextStyle(color: Colors.white, fontSize: 24
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Herr Hofmann: für seine tatkräftige Unterstützung bei diesem Projekt\n\nJorid Langheinrich: für ihre konstruktive Kritik und Verbesserungsvorschläge\n\ndem einen Typen auf YouTube, der immer alles wunderbar erklärt"),
              ),

              Spacer(),

              Text("Version ${AppConfig.version}")

            ],
          ),
        ),
      )
    );
  }
}