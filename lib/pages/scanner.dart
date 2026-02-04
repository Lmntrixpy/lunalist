import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:hitster_2/pages/music_player_local.dart';
import 'package:hitster_2/pages/music_player_spotify.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  final dynamic mapper;
  final String gameMode;

  const ScannerPage({super.key, required this.mapper, required this.gameMode});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _navigated = false;
  MobileScannerController? _controller;
  final TextEditingController _textController = TextEditingController();

  // Camera only on iOS and android
  bool get _isMobileDevice => Platform.isAndroid || Platform.isIOS;

final _manualFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (_isMobileDevice) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        autoStart: true,
      );
    } else {
      // autofocus Textfield
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _manualFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _manualFocus.dispose();
    _controller?.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleCard(int cardNumber) {
    if (_navigated) return;
    _navigated = true;

    _controller?.stop();

    final nextPage = widget.gameMode == "local"
        ? ControlMusicState(mapper: widget.mapper, cardNumber: cardNumber, gameMode: widget.gameMode)
        : PlayerSpotify(mapper: widget.mapper, cardNumber: cardNumber, gameMode: widget.gameMode);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final singularSong = widget.mapper.remainingSongCount == 1;
    final statusText = singularSong
        ? "Noch ${widget.mapper.remainingSongCount} Lied übrig."
        : "Noch ${widget.mapper.remainingSongCount} Lieder übrig.";

    // Desktop Ui
    if (!_isMobileDevice) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Karte erfassen"),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: _buildManualOnlyView(
            message: "Scanner nicht verfügbar",
            statusText: statusText,
          ),
        ),
      );
    }

    // Mobile Ui
    final controller = _controller!;

    return PopScope(
      canPop: false,
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, child) {
          final showFab = state.error == null && state.isInitialized;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text("Karte erfassen"),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            floatingActionButton: showFab ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Kartennummer"),
                    content: TextField(
                      controller: _textController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "Code eingeben"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Abbrechen"),
                      ),
                      TextButton(
                        onPressed: () {
                          final parsed = int.tryParse(_textController.text);
                          if (parsed != null) {
                            Navigator.pop(context);
                            _handleCard(parsed);
                          }
                        },
                        child: const Text("Weiter"),
                      ),
                    ],
                  ),
                );
              },
              label: const Text("Nummer eingeben"),
              icon: const Icon(Icons.keyboard),
            ) : null,
            body: _buildScannerView(statusText, state, controller),
          );
        },
      ),
    );
  }

  Widget _buildScannerView(String statusText, MobileScannerState state, MobileScannerController controller) {
    if (state.error != null) {
      return _buildManualOnlyView(
        message: state.error!.errorCode == MobileScannerErrorCode.permissionDenied
            ? "Kamerazugriff wurde abgelehnt."
            : "Kamera-Fehler: ${state.error!.errorCode}",
        statusText: statusText,
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            for (final barcode in capture.barcodes) {
              final value = barcode.rawValue;
              if (value != null) {
                final parsed = int.tryParse(value);
                if (parsed != null) _handleCard(parsed);
              }
            }
          },
        ),
          // Statustext
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                statusText,
                style: const TextStyle(
                  fontSize: 18, 
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2, 2))
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // Scan Box
        if (state.isInitialized)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

Widget _buildManualOnlyView({required String message, required String statusText}) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // statusText
              Text(
                statusText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              
              Icon(Icons.no_photography, size: 64, color: Colors.grey),
              
              SizedBox(height: 16),
              
              // Error Message
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent)),
              
              SizedBox(height: 32),
              
              // TextField
              TextField(
                focusNode: _manualFocus,
                controller: _textController,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Kartennummer",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    final p = int.tryParse(_textController.text);
                    if (p != null) {
                      _handleCard(p);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Bitte eine gültige Nummer eingeben")),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text("Weiter"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}