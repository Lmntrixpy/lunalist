import 'package:flutter/material.dart';
import 'package:hitster_2/pages/music_player.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double boxSize = 250;
    final textController = TextEditingController();
    int? cardNumber = 0;

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
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                  cardNumber = int.tryParse(barcode.rawValue ?? "");
                
                debugPrint("Barcode found! ${barcode.rawValue}");
                debugPrint("Going to Control Music State");

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