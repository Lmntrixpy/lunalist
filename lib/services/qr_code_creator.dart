import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrPdfGenerator {
  static Future<void> generate(int count) async {
    try {
      print("------- in generate -----");
      
      // Font laden
      final fontData = await rootBundle.load(
        'assets/fonts/Roboto-Regular.ttf',
      );
      final ttf = pw.Font.ttf(fontData);
      
      // PDF-Vorlage laden
      final templateData = await rootBundle.load(
        'assets/templates/Karten-Vorlage.pdf',
      );
      final templateBytes = templateData.buffer.asUint8List();
      
      // Neues PDF erstellen
      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
          italic: ttf,
          boldItalic: ttf,
        ),
      );
      
      // QR-Codes in Gruppen von 20 aufteilen
      int remainingCodes = count;
      int currentIndex = 0;
      
      while (remainingCodes > 0) {
        // Seite 1 (Titelseite) als Bild hinzufügen
        final page1Image = await pdfPageToImage(templateBytes, pageNumber: 0);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(
                page1Image,
                fit: pw.BoxFit.fill,
              ),
            ),
          ),
        );
        
        // Seite 2 (QR-Codes) hinzufügen
        final page2Image = await pdfPageToImage(templateBytes, pageNumber: 1);
        final codesForThisPage = remainingCodes > 20 ? 20 : remainingCodes;
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return pw.Container(
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                child: pw.Stack(
                  children: [
                    // Hintergrund (Vorlage) - volle Seite
                    pw.Positioned.fill(
                      child: pw.Image(
                        page2Image,
                        fit: pw.BoxFit.fill,
                      ),
                    ),
                    // QR-Codes darüber
                    _buildQrGrid(codesForThisPage, currentIndex),
                  ],
                ),
              );
            },
          ),
        );
        
        currentIndex += codesForThisPage;
        remainingCodes -= codesForThisPage;
      }
      
      final bytes = await pdf.save();
      print("PDF generated, size: ${bytes.length} bytes");
      
      // Temporäre Datei erstellen und teilen
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_codes.pdf');
      await file.writeAsBytes(bytes);
      print("PDF saved to: ${file.path}");
      
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'QR Codes',
        text: 'QR Codes PDF',
      );
      
      print("Share result: ${result.status}");
      
    } catch (e, stackTrace) {
      print("Error generating PDF: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  // Hilfsfunktion: PDF-Seite in Bild konvertieren
  static Future<pw.ImageProvider> pdfPageToImage(
    Uint8List pdfBytes, {
    required int pageNumber,
  }) async {
    await for (final page in Printing.raster(
      pdfBytes,
      pages: [pageNumber],
      dpi: 150,
    )) {
      final imageBytes = await page.toPng();
      return pw.MemoryImage(imageBytes);
    }
    
    throw Exception('Could not rasterize page $pageNumber');
  }

  static pw.Widget _buildQrGrid(int count, int startIndex) {
    // Grid-Layout: 4 Spalten x 5 Zeilen = 20 Kästchen
    // Positionierung anpassen um in die Kästchen zu passen
    return pw.Positioned(
      left: 60,   // Anpassen für dein Layout
      top: 120,   // Anpassen für dein Layout
      right: 60,
      bottom: 120,
      child: pw.Container(
        child: pw.GridView(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: List.generate(count, (i) {
            final value = (startIndex + i + 1).toString().padLeft(4, '0');
            return _qrCard(value);
          }),
        ),
      ),
    );
  }

  static pw.Widget _qrCard(String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: value,
              drawText: false,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }
}