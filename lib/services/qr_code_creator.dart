import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrPdfGenerator {
  static Future<void> clearTempCache() async {
    // clears temp folder
    final dir = await getTemporaryDirectory();

    if (!dir.existsSync()) return;

    for (final entity in dir.listSync()) {
      try {
        entity.deleteSync(recursive: true);
      } catch (_) {
        // ignore file (maybe in use)
      }
    }
}

  static Future<void> generate(int count, {required BuildContext context}) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null)
        ? (box.localToGlobal(Offset.zero) & box.size)
        : const Rect.fromLTWH(0, 0, 1, 1);

    final templateData = await rootBundle.load(
      'assets/templates/Karten-Vorlage.pdf',
    );

    final pdf = pw.Document();
    
    if (count == 0) {count += 1;}
    int roundedCount = ((count + 19) ~/ 20) * 20; // round to next 20

    int remaining = roundedCount;
    int index = 0;

    while (remaining > 0) {
      // page 1
      final page1 = await _raster(templateData.buffer.asUint8List(), 0);
      pdf.addPage(
        pw.Page(
          pageFormat: page1.format,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(page1.image),
        ),
      );

      // page 2
      final page2 = await _raster(templateData.buffer.asUint8List(), 1);
      final codes = remaining > 20 ? 20 : remaining;
      final indexSet = index;

      pdf.addPage(
      pw.Page(
        pageFormat: page2.format,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.SizedBox(
          width: page2.format.width,
          height: page2.format.height,
          child: pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(
                  page2.image,
                  fit: pw.BoxFit.fill,
                ),
              ),
              _buildQrGrid(codes, indexSet),
            ],
          ),
        ),
      ),
    );

      index += codes;
      remaining -= codes;
    }

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/APPNAME_Karten.pdf');
    await file.writeAsBytes(bytes);


    if (Platform.isAndroid) {
      final fileName = "APPNAME_Karten${DateTime.now().millisecondsSinceEpoch}.pdf";
      final downloadsDir = Directory("/storage/emulated/0/Download");

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final downloadFile = File("${downloadsDir.path}/$fileName");
      debugPrint(downloadFile.toString());
      await downloadFile.writeAsBytes(bytes);
      debugPrint("----- saved in Download dir");
    }

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], sharePositionOrigin: origin),
    );
  }

  static Future<_RasterPage> _raster(Uint8List pdf, int page) async {
    await for (final p in Printing.raster(
      pdf,
      pages: [page],
      dpi: 300,
    )) {
      final img = pw.MemoryImage(await p.toPng());
      return _RasterPage(
        image: img,
        format: PdfPageFormat.a4,
      );
    }
    throw Exception();
  }

  static pw.Widget _buildQrGrid(int count, int startIndex) {
    const double cardSizeCm = 4.5;
    const double verticalSpacingCm = 1.0;

    const double firstCenterXCm = 1.35;
    const double firstCenterYCm = 2.0;

    const int columns = 4;

    return pw.Stack(
      children: List.generate(count, (i) {
        final double yOffset = Platform.isAndroid ? (3.0 * PdfPageFormat.mm) : 0.0;
        
        final row = i ~/ columns;
        final col = i % columns;

        final centerXcm = firstCenterXCm + col * cardSizeCm;
        final centerYcm = firstCenterYCm + row * (cardSizeCm + verticalSpacingCm);

        final left = (centerXcm) * PdfPageFormat.cm;
        final top = (centerYcm * PdfPageFormat.cm) + yOffset;

        final value = (startIndex + i + 1).toString();

        return pw.Positioned(
          left: left,
          top: top,
          child: pw.SizedBox(
            width: cardSizeCm *  PdfPageFormat.cm,
            height: cardSizeCm  * PdfPageFormat.cm,
            child: _qrCard(value),
          ),
        );
      }),
    );
  }

  static pw.Widget _qrCard(String value) {
    const double cardSizeCm = 4.5;
    const double qrFraction = 0.5;

    final cardSize = cardSizeCm * PdfPageFormat.cm;
    final qrSize = cardSize * qrFraction;
    final textHeight = cardSize - qrSize;

    return pw.Container(
      width: cardSize,
      height: cardSize,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Container(
            width: qrSize,
            height: qrSize,
            color: PdfColors.white,
            child: pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(4),
                width: qrSize,
                height: qrSize,
                //color: PdfColors.white,
                child: pw.BarcodeWidget(
                  data: value, 
                  barcode: pw.Barcode.qrCode(),
                )
              )
            )
          ),

          pw.Container(
            height: textHeight,
            child: pw.Center(
              child: pw.Text(value, style: const pw.TextStyle(fontSize: 20))
            )
          )

        ],
      ),
    );
  } 

  static Future<void> generateQrOnly(int count, {required BuildContext context}) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null)
        ? (box.localToGlobal(Offset.zero) & box.size)
        : const Rect.fromLTWH(0, 0, 1, 1);

    final templateData = await rootBundle.load(
      'assets/templates/Karten-Vorlage.pdf',
    );
    final templateBytes = templateData.buffer.asUint8List();

    // round to 20 row
    final roundedCount = ((count + 19) ~/ 20) * 20;
    if (roundedCount <= 0) return;

    final pdf = pw.Document();

    int remaining = roundedCount;
    int index = 0;

    while (remaining > 0) {
      // only qr page
      final page2 = await _raster(templateBytes, 1);
      final codes = remaining > 20 ? 20 : remaining;

      final startForThisPage = index;

      pdf.addPage(
      pw.Page(
        pageFormat: page2.format,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.SizedBox(
          width: page2.format.width,
          height: page2.format.height,
          child: pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(page2.image, fit: pw.BoxFit.fill),
              ),
              _buildQrGrid(codes, startForThisPage),
            ],
          ),
        ),
      ),
    );

      index += codes;
      remaining -= codes;
    }

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/APPNAME_Karten_nur_Vorderseite.pdf');
    await file.writeAsBytes(bytes);

    if (Platform.isAndroid) {
      final fileName = "APPNAME_Karten_nur_Vorderseite${DateTime.now().millisecondsSinceEpoch}.pdf";
      final downloadsDir = Directory("/storage/emulated/0/Download");

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final downloadFile = File("${downloadsDir.path}/$fileName");
      debugPrint(downloadFile.toString());
      await downloadFile.writeAsBytes(bytes);
      debugPrint("----- saved in Download dir");
    }

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], sharePositionOrigin: origin),); 
  }
}

class _RasterPage {
  final pw.ImageProvider image;
  final PdfPageFormat format;

  _RasterPage({required this.image, required this.format});
}