import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:hitster_2/pages/music_player_local.dart';
import 'package:hitster_2/pages/music_player_spotify.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  final dynamic mapper; // CardSongwidget.mapper
  final String gameMode;


  const ScannerPage({super.key, required this.mapper, required this.gameMode});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _navigated = false;
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      initialZoom: Platform.isIOS ? 0.5 : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCard(int cardNumber) {
    if (_navigated) return;
    _navigated = true;

    _controller.stop();

    final nextPage = widget.gameMode == "local"
        ? ControlMusicState(mapper: widget.mapper, cardNumber: cardNumber, gameMode: widget.gameMode,)
        : PlayerSpotify(mapper: widget.mapper, cardNumber: cardNumber, gameMode: widget.gameMode,);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }


  @override
  Widget build(BuildContext context) {
    const double boxSize = 250;
    final textController = TextEditingController();
    int cardNumber = 0;
    bool singularSong = widget.mapper.remainingSongCount == 1;
    debugPrint("-------- is only one song left? $singularSong");

    debugPrint("----------- Count Songs ${widget.mapper.remainingSongCount.toString()}");

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Scanne eine Karte"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
      
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
                      final parsed = int.tryParse(textController.text);
                      if (parsed == null) return;

                      Navigator.of(context).pop();
                      _handleCard(parsed);
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
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final value = barcode.rawValue;
                  if (value != null) { // check if barcode value is != to null
                    final parsed = int.tryParse(value);
                    if (parsed != null) { // check if parsed value to int is != to null
                      _handleCard(parsed);
      
                      debugPrint("-------- QR cardNumber: $cardNumber ----------");
                      Navigator.pop(context);
                      if (widget.gameMode == "local") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ControlMusicState(mapper: widget.mapper, cardNumber: cardNumber, gameMode: widget.gameMode,)),
                        );
                      } if (widget.gameMode == "spotify") {
                        debugPrint("---- push to spotify");
                        // push to correct spotify page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlayerSpotify(mapper: widget.mapper, cardNumber: cardNumber, gameMode: widget.gameMode,)),
                        );
                      }
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
                  singularSong ? "Noch ${widget.mapper.remainingSongCount.toString()} Lied übrig." : "Noch ${widget.mapper.remainingSongCount.toString()} Lieder übrig.",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.justify,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*
class ScannerPage extends StatelessWidget {
  final dynamic widget.mapper; // CardSongwidget.mapper
  final String widget.gameMode;

  const ScannerPage({super.key, required this.widget.mapper, required this.widget.gameMode});

  @override
  Widget build(BuildContext context) {
    const double boxSize = 250;
    final textController = TextEditingController();
    int cardNumber = 0;
    bool singularSong = widget.mapper.remainingSongCount == 1;
    debugPrint("-------- is only one song left? $singularSong");

    debugPrint("----------- Count Songs ${widget.mapper.remainingSongCount.toString()}");

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Scanne eine Karte"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
      
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
                        debugPrint(widget.gameMode);
                        
                        Navigator.pop(context);
                        if (widget.gameMode == "local") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ControlMusicState(widget.mapper: widget.mapper, cardNumber: cardNumber, widget.gameMode: widget.gameMode,)),
                          );
                        } if (widget.gameMode == "spotify") {
                          debugPrint("---- push to spotify");
                          // push to correct spotify page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PlayerSpotify(widget.mapper: widget.mapper, cardNumber: cardNumber, widget.gameMode: widget.gameMode,)),
                          );
                        }
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
                      if (widget.gameMode == "local") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ControlMusicState(widget.mapper: widget.mapper, cardNumber: cardNumber, widget.gameMode: widget.gameMode,)),
                        );
                      } if (widget.gameMode == "spotify") {
                        debugPrint("---- push to spotify");
                        // push to correct spotify page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlayerSpotify(widget.mapper: widget.mapper, cardNumber: cardNumber, widget.gameMode: widget.gameMode,)),
                        );
                      }
      
                      
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
                  singularSong ? "Noch ${widget.mapper.remainingSongCount.toString()} Lied übrig." : "Noch ${widget.mapper.remainingSongCount.toString()} Lieder übrig.",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.justify,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
*/