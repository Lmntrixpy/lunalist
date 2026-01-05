import 'package:flutter/material.dart';
import 'package:hitster_2/pages/music_player.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double boxSize = 250;

    return Scaffold(
      appBar: AppBar(
        title: Text("Scanne eine Karte"),
        centerTitle: true,),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Alert Dialog
        },
        label: Text("Nummer eingeben"),
        icon: Icon(Icons.keyboard_alt_outlined),
        
        ),
        

      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                debugPrint('Barcode found! ${barcode.rawValue}');
                debugPrint('Going to Control Music State');
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ControlMusicState()),
                );
              }
            }
           ),

          Center(
            child: Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),        
        ],
      ),
    );
  }
}

/*
Future openDialog() => showDialog(
            context: ,
            builder: (context) => AlertDialog(
              title: Text("Gebe die Nummer von der Karte ein"),
              content: TextField(
                decoration: InputDecoration(),
              ),
            )
*/