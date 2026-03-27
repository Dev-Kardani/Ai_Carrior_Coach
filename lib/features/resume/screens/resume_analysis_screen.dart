import 'dart:io';
import 'dart:math' as math;

import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/analysis_model.dart';
import 'package:ai_career_coach/services/pdf_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart' as intl;

/// Resume analysis results screen
class ResumeAnalysisScreen extends StatefulWidget {
  final AnalysisModel analysis;

  const ResumeAnalysisScreen({
    super.key,
    required this.analysis,
  });

  @override
  State<ResumeAnalysisScreen> createState() => _ResumeAnalysisScreenState();
}

class _ResumeAnalysisScreenState extends State<ResumeAnalysisScreen> {
  String? _expandedSectionId = 'strengths';
  bool _isDownloading = false;

  Future<void> _downloadReport() async {
    setState(() => _isDownloading = true);
    try {
      final role = (widget.analysis.suggestions.isNotEmpty)
          ? widget.analysis.suggestions.first.split(' ').take(3).join(' ')
          : 'Career';

      final pdfBytes = await PdfService().generateResumeAnalysisReport(
        widget.analysis,
        role,
      );

      // Use FilePicker to save the file
      final String fileName =
          'Resume_Analysis_${intl.DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Analysis Report',
        fileName: fileName,
        // bytes: pdfBytes, // Removing bytes due to macOS 'Unsupported operation'
      );

      if (outputPath != null) {
        // Manually write the bytes for macOS compatibility
        final File file = File(outputPath);
        await file.writeAsBytes(pdfBytes);

        if (mounted) {
          DebugLogger.success(
              'RESUME_UI', 'DOWNLOAD_REPORT', 'Report saved to: $outputPath');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report saved to $fileName'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      } else if (mounted) {
        DebugLogger.info('RESUME_UI', 'DOWNLOAD_REPORT', 'Download cancelled');
      }
    } catch (e) {
      DebugLogger.failed('RESUME_UI', 'DOWNLOAD_REPORT', e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF64748B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Analysis Results',
          style: TextStyle(
            color: Color(0xFF0F172A), // Slate 900
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isDownloading ? null : _downloadReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _isDownloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Download Report',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: _buildScoreCard()),
                    const SizedBox(width: 32),
                    Expanded(child: _buildDetailedBreakdownTheme()),
                  ],
                );
              }

              return Column(
                children: [
                  _buildScoreCard(),
                  const SizedBox(height: 24),
                  _buildDetailedBreakdownTheme(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedBreakdownTheme() {
    return Column(
      children: [
        _buildSection(
          id: 'strengths',
          title: 'Strengths',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
          bg: const Color(0xFFF0FDF4),
          items: widget.analysis.strengths,
        ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        _buildSection(
          id: 'weaknesses',
          title: 'Weaknesses',
          icon: Icons.cancel_rounded,
          color: const Color(0xFFDC2626),
          bg: const Color(0xFFFEF2F2),
          items: widget.analysis.weaknesses,
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        _buildSection(
          id: 'ats',
          title: 'ATS Compatibility',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFEA580C),
          bg: const Color(0xFFFFF7ED),
          items: [widget.analysis.atsCompatibility],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        _buildSection(
          id: 'suggestions',
          title: 'AI Suggestions',
          icon: Icons.track_changes_rounded,
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFEFF6FF),
          items: widget.analysis.suggestions,
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 32),
        _buildNextStep().animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildScoreCard() {
    final score = widget.analysis.score;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          _buildDonutChart(score),
          const SizedBox(height: 24),
          const Text(
            'Top 20% of candidates applying for similar roles.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildDonutChart(int score) {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(192, 192),
            painter: _ScoreDonutPainter(score: score.toDouble()),
          ),
          Text(
            '$score/100',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String id,
    required String title,
    required IconData icon,
    required Color color,
    required Color bg,
    required List<String> items,
  }) {
    final isExpanded = _expandedSectionId == id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              DebugLogger.info(
                  'RESUME_UI', 'SECTION_TOGGLED', 'Section $id toggled');
              setState(() {
                _expandedSectionId = isExpanded ? null : id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 64, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.slate400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.slate600,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNextStep() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 40),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          ElevatedButton(
            onPressed: () {
              DebugLogger.info('RESUME_UI', 'ROUTING',
                  'Navigating to skill gap from footer');
              Navigator.pushNamed(context, '/app/resume/skills');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'View Skill Gap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              DebugLogger.info('RESUME_UI', 'ROUTING',
                  'Navigating to skill gap from next step');
              Navigator.pushNamed(context, '/app/resume/skills');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Analyze Skill Gaps',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreDonutPainter extends CustomPainter {
  final double score;

  _ScoreDonutPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
