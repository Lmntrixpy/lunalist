import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Chips {
  static Future<void> shareFile(BuildContext context, String fileType) async {
    String fileName = "lunalist_Spielchips.stl";

    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null)
        ? (box.localToGlobal(Offset.zero) & box.size)
        : const Rect.fromLTWH(0, 0, 1, 1);

  
    if (fileType == "3mf") {
      fileName = "lunalist_Spielchips.3mf";
    } else {
      fileName = "lunalist_Spielchips.stl";
    }

    final byteData = await rootBundle.load('assets/chips/lunalist_Spielchip.$fileType');
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/lunalist_Spielchip.$fileType');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows || Platform.isAndroid) {
      final bytes = await file.readAsBytes();

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: "Suche einen Ausgabeordner aus:",
        fileName: fileName,
        bytes: bytes,
      );

      if (outputFile == null) {
        debugPrint("User cancelled");
      }
      return;
    }

    if (Platform.isIOS) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/3mf', name: fileName)],
          sharePositionOrigin: origin,
        ),
      );
      return;
    }

    debugPrint("Export/Share nicht unterstützt auf dieser Plattform.");
  }
}