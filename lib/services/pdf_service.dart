import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/analysis_model.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// PDF service for extracting text and generating reports
class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  /// Extract text from PDF bytes
  Future<String> extractText(Uint8List bytes) async {
    DebugLogger.info('PDF_SERVICE', 'EXTRACT_TEXT',
        'Parsing PDF bytes, size: ${bytes.length}');
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Extract text from all pages
      final String text = PdfTextExtractor(document).extractText();

      // Dispose the document
      document.dispose();

      if (text.trim().isEmpty) {
        DebugLogger.failed(
            'PDF_SERVICE', 'EXTRACT_TEXT', 'No text found in PDF');
        throw Exception('No text found in PDF. The file might be image-based.');
      }

      DebugLogger.success(
          'PDF_SERVICE', 'EXTRACT_TEXT', 'Extracted ${text.length} characters');
      return text;
    } catch (e) {
      DebugLogger.failed('PDF_SERVICE', 'EXTRACT_TEXT', e.toString(), error: e);
      throw Exception('Failed to extract text from PDF: ${e.toString()}');
    }
  }

  /// Generate a PDF report for resume analysis
  Future<Uint8List> generateResumeAnalysisReport(
      AnalysisModel analysis, String role) async {
    DebugLogger.info('PDF_SERVICE', 'GENERATE_REPORT',
        'Generating PDF for analysis: ${analysis.id}');
    try {
      // Create a new PDF document
      final PdfDocument document = PdfDocument();

      // Add a page to the document
      final PdfPage page = document.pages.add();
      final PdfGraphics graphics = page.graphics;

      // Define fonts
      final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 24,
          style: PdfFontStyle.bold);
      final PdfFont subHeaderFont = PdfStandardFont(PdfFontFamily.helvetica, 18,
          style: PdfFontStyle.bold);
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 14,
          style: PdfFontStyle.bold);
      final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
      final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

      double y = 0;

      // 1. Header
      graphics.drawString('Resume Analysis Report', headerFont,
          bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 30));
      y += 40;

      graphics.drawString('Role: $role', titleFont,
          bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 20));
      y += 20;

      graphics.drawString(
          'Date: ${intl.DateFormat('MMM dd, yyyy').format(analysis.createdAt)}',
          smallFont,
          bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 15));
      y += 40;

      // 2. Score Section
      graphics.drawRectangle(
          brush: PdfSolidBrush(PdfColor(79, 70, 229)), // Indigo 600
          bounds: Rect.fromLTWH(0, y, 100, 40));
      graphics.drawString(
          'Score: ${analysis.score}/100',
          PdfStandardFont(PdfFontFamily.helvetica, 14,
              style: PdfFontStyle.bold),
          brush: PdfBrushes.white,
          bounds: Rect.fromLTWH(10, y + 10, 80, 20));
      y += 60;

      // 3. Sections
      y = _drawPdfSection(graphics, 'Strengths', analysis.strengths, y,
          PdfColor(22, 163, 74), subHeaderFont, titleFont, bodyFont);
      y += 20;

      y = _drawPdfSection(graphics, 'Weaknesses', analysis.weaknesses, y,
          PdfColor(220, 38, 38), subHeaderFont, titleFont, bodyFont);
      y += 20;

      // ATS Check
      graphics.drawString('ATS Compatibility', subHeaderFont,
          bounds: Rect.fromLTWH(0, y, 500, 25));
      y += 30;
      graphics.drawString(analysis.atsCompatibility, bodyFont,
          bounds: Rect.fromLTWH(20, y, 480, 40));
      y += 50;

      y = _drawPdfSection(graphics, 'AI Suggestions', analysis.suggestions, y,
          PdfColor(37, 99, 235), subHeaderFont, titleFont, bodyFont);

      // Save the document
      final List<int> bytes = await document.save();
      document.dispose();

      DebugLogger.success('PDF_SERVICE', 'GENERATE_REPORT',
          'Successfully generated PDF report');
      return Uint8List.fromList(bytes);
    } catch (e) {
      DebugLogger.failed('PDF_SERVICE', 'GENERATE_REPORT', e.toString(),
          error: e);
      throw Exception('Failed to generate PDF report: ${e.toString()}');
    }
  }

  double _drawPdfSection(
      PdfGraphics graphics,
      String title,
      List<String> items,
      double startY,
      PdfColor color,
      PdfFont titleFont,
      PdfFont itemTitleFont,
      PdfFont bodyFont) {
    double y = startY;

    // Draw Section Title
    graphics.drawRectangle(
        brush: PdfSolidBrush(color), bounds: Rect.fromLTWH(0, y, 5, 25));
    graphics.drawString(title, titleFont,
        bounds: Rect.fromLTWH(15, y, 500, 25));
    y += 35;

    // Draw Items
    for (var item in items) {
      graphics.drawRectangle(
          brush: PdfSolidBrush(color), bounds: Rect.fromLTWH(20, y + 6, 4, 4));
      graphics.drawString(item, bodyFont,
          bounds: Rect.fromLTWH(35, y, 465, 40));
      y += 30; // Approximation - in production you'd calculate text height
    }

    return y;
  }
}
