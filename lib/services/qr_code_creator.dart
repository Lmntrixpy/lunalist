import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrPdfGenerator {
  static Future<void> generate(int count) async {
    final templateData = await rootBundle.load(
      'assets/templates/Karten-Vorlage.pdf',
    );

    final pdf = pw.Document();
    
    if (count == 0) {count += 1;}
    int roundedCount = ((count + 19) ~/ 20) * 20; // round to next 20

    int remaining = roundedCount;
    int index = 0;

    while (remaining > 0) {
      // Seite 1
      final page1 = await _raster(templateData.buffer.asUint8List(), 0);
      pdf.addPage(
        pw.Page(
          pageFormat: page1.format,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(page1.image),
        ),
      );

      // Seite 2
      final page2 = await _raster(templateData.buffer.asUint8List(), 1);
      final codes = remaining > 20 ? 20 : remaining;
      final indexSet = index;

      pdf.addPage(
        pw.Page(
          pageFormat: page2.format,
          build: (_) {
            return pw.Stack(
              children: [
                pw.Image(page2.image),
                _buildQrGrid(
                  codes,
                  indexSet,
                ),
              ],
            );
          },
        ),
      );

      index += codes;
      remaining -= codes;
    }

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qr_codes.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)]);
  }

  static Future<_RasterPage> _raster(
    Uint8List pdf,
    int page,
  ) async {
    await for (final p in Printing.raster(
      pdf,
      pages: [page],
      dpi: 300,
    )) {
      final img = pw.MemoryImage(await p.toPng());

      final widthPt = p.width / 300 * PdfPageFormat.inch;
      final heightPt = p.height / 300 * PdfPageFormat.inch;

      return _RasterPage(
        image: img,
        format: PdfPageFormat(widthPt, heightPt),
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
        final row = i ~/ columns;
        final col = i % columns;

        final centerXcm = firstCenterXCm + col * cardSizeCm;
        final centerYcm = firstCenterYCm + row * (cardSizeCm + verticalSpacingCm);

        final left = (centerXcm) * PdfPageFormat.cm;
        final top = (centerYcm) * PdfPageFormat.cm;

        final value =
            (startIndex + i + 1).toString();

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

          
          /*
          pw.SizedBox(
            width: cardSize,
            height: qrSize,
            child: pw.Center(
              child: pw.SizedBox(
                width: qrSize + 10,
                height: qrSize + 10,
                
                
                child: pw.Container(
                  width: qrSize,
                  height: qrSize,
                  color: PdfColors.white,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: value,
                    drawText: false,
                  ),
                ),
              )
            ),
          ),

          // Text unter dem QR-Code
          pw.SizedBox(
            height: textHeight,
            child: pw.Center(
              child: pw.Text(
                value,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ), */
        ],
      ),
    );
  }

}

class _RasterPage {
  final pw.ImageProvider image;
  final PdfPageFormat format;

  _RasterPage({required this.image, required this.format});
}