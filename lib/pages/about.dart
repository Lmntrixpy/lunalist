import 'package:flutter/material.dart';
import 'package:lunalist/config.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Über diese App"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isTablet = width >= 500 && width < 1400;
          final isDesktop = width >= 1400;

          final maxContentWidth =
              isDesktop ? 900.0 : (isTablet ? 750.0 : double.infinity);

          final padding = isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);

          final bodyFontSize = isDesktop ? 22.0 : (isTablet ? 20.0 : 18.0);
          final headingFontSize = isDesktop ? 36.0 : (isTablet ? 34.0 : 30.0);
          final versionFontSize = isDesktop ? 14.0 : 12.0;
          final imageMaxHeight = isDesktop ? 260.0 : (isTablet ? 220.0 : 180.0);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Diese App wurde entwickelt für den Informatikunterricht der 12. Klasse am Gymnasium Christian Gottlieb Reichard in Bad Lobenstein von Jeremy Fröb und Emily Schwerdtner.",
                      style: textTheme.bodyLarge?.copyWith(fontSize: bodyFontSize),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Danksagungen",
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: headingFontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Herr Hofmann: für seine tatkräftige Unterstützung bei diesem Projekt\n\nJorid Langheinrich: für ihre konstruktive Kritik und Verbesserungsvorschläge\n\nAn alle Spielerinnen & Spieler die diese App getestet haben,",
                      style: textTheme.bodyLarge?.copyWith(fontSize: bodyFontSize),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50,),
                    Text(
                      "❤️",
                      style: TextStyle(fontSize: 100),
                      textAlign: TextAlign.center,
                    
                    ),

                    const SizedBox(height: 50),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: imageMaxHeight),
                      child: Image.asset(
                        isDarkMode
                            ? "assets/images/gym-lbs_logo_light.png"
                            : "assets/images/gym-lbs_logo_dark.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 80),
                    Text(
                      "Version: ${AppConfig.version}",
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: versionFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}