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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Diese App wurde entwickelt für den Informatikunterricht der 12. Klasse am Gymnasium Christian Gottlieb Reichard in Bad Lobenstein von Jeremy Fröb und Emily Schwerdtner.",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.justify,
                
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 14),
                child: Text(
                  "Danksagungen",
                  style: TextStyle(fontSize: 32),
                ),
              ),

              Text(
                "Herr Hofmann: für seine tatkräftige Unterstützung bei diesem Projekt\n\nJorid Langheinrich: für ihre konstruktive Kritik und Verbesserungsvorschläge",
                style: TextStyle(fontSize: 20),
              ),

              Spacer(),

              Text("Version ${AppConfig.version}", style: TextStyle(fontSize: 12),)

            ],
          ),
        ),
      )
    );
  }
}