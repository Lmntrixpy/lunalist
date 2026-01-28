import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:hitster_2/pages/music_player.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatelessWidget {
  final List<String> tracks;

  const ScannerPage({super.key, required this.tracks});

  @override
  Widget build(BuildContext context) {
    const double boxSize = 250;
    final textController = TextEditingController();
    int? cardNumber = 0;
    bool singularSong = tracks.length == 1;
    print(singularSong);

    debugPrint("----------- Count Songs ${tracks.length.toString()}");

    // TODO: implement tracks count on top of screen (e.g. Noch N Songs übrig)

    return Scaffold(
      appBar: AppBar(
        title: Text("Scanne eine Karte"),
        centerTitle: true,),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Kartennummer"),
              content: TextField(
                controller: textController,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Gib den Code auf der Karte ein",
                  suffix: IconButton(
                    onPressed: () {
                      textController.clear();
                    },
                    icon: Icon(Icons.clear_rounded))
                  )
                ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (int.tryParse(textController.text) != null) {
                      cardNumber = int.parse(textController.text);

                      debugPrint("-------- cardNumber: $cardNumber ----------");
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ControlMusicState()),
                        );
                    } else {
                      debugPrint("---------- no cardnumber input ---------");
                    }
                  },
                  child: Text("Weiter"),
                )
              ],
            )
          );
        },
        label: Text("Nummer eingeben"),
        icon: Icon(Icons.keyboard_alt_outlined),
        
        ),
        
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates,
            facing: CameraFacing.back,
            initialZoom: Platform.isIOS ? 0.5 : null, // for iPhones to fake using the main camera (using .5x but looks like 1x)
            ),
            
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final value = barcode.rawValue;
                if (value != null) { // check if barcode value is != to null
                  final parsed = int.tryParse(value);
                  if (parsed != null) { // check if parsed value to int is != to null
                    cardNumber = parsed;

                    debugPrint("-------- QR cardNumber: $cardNumber ----------");
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ControlMusicState()),
                    );
                  }
                } 
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

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                singularSong ? "Noch ${tracks.length.toString()} Lied übrig." : "Noch ${tracks.length.toString()} Lieder übrig.",
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.justify,
              ),
            ),
          )
        ],
      ),
    );
  }
}