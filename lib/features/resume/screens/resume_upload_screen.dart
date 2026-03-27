import 'dart:async';

import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/features/resume/screens/processing_state_screen.dart';
import 'package:ai_career_coach/features/resume/screens/resume_analysis_screen.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/pdf_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  final _supabaseService = SupabaseService();
  final _geminiService = GeminiService();
  final _pdfService = PdfService();

  PlatformFile? _selectedFile;
  final bool _isDragging = false;
  final bool _isAnalyzing = false;

  Future<void> _pickFile() async {
    DebugLogger.info('RESUME', 'PICK_FILE', 'Attempting to pick file...');
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        DebugLogger.success(
            'RESUME', 'FILE_PICKED', 'File picked: ${result.files.first.name}');
        setState(() => _selectedFile = result.files.first);
      } else {
        DebugLogger.warning('RESUME', 'FILE_PICK_CANCELLED',
            'File picking cancelled or failed.');
      }
    } catch (e) {
      DebugLogger.failed('RESUME', 'PICK_FILE_FAILED', e.toString(), error: e);
    }
  }

  Future<void> _analyzeResume() async {
    if (_selectedFile == null) return;

    final completer = Completer<dynamic>();

    // Initial navigation to ProcessingStateScreen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProcessingStateScreen(
            processingFuture: completer.future,
            onComplete: () {}, // Handled by the pushReplacement logic if needed
          ),
        ),
      );
    }

    try {
      DebugLogger.info('RESUME', 'ANALYZE_PIPELINE',
          'Starting analysis pipeline for: ${_selectedFile!.name}');
      final bytes = _selectedFile!.bytes;
      if (bytes == null) {
        throw Exception('File data is not available.');
      }

      DebugLogger.info('RESUME', 'EXTRACT_TEXT', 'Extracting text from PDF...');
      final text = await _pdfService.extractText(bytes);
      DebugLogger.success('RESUME', 'EXTRACT_TEXT_SUCCESS',
          'Text extraction successful. Length: ${text.length}');

      DebugLogger.info('RESUME', 'UPLOAD_FILE', 'Uploading file to storage...');
      final filePath =
          await _supabaseService.uploadResume(bytes, _selectedFile!.name);

      DebugLogger.info(
          'RESUME', 'SAVE_METADATA', 'Saving resume metadata to database...');
      final resume = await _supabaseService.saveResumeData(
        fileName: _selectedFile!.name,
        filePath: filePath,
        extractedText: text,
      );

      DebugLogger.info(
          'RESUME', 'ANALYZE_AI', 'Analyzing resume with Gemini AI...');
      final analysis = await _geminiService.analyzeResume(text);

      DebugLogger.info('RESUME', 'SAVE_ANALYSIS',
          'Saving AI analysis results to database...');
      final savedAnalysis = await _supabaseService.saveAnalysisResult(
        resumeId: resume.id,
        score: analysis['score'] as int,
        strengths: List<String>.from(analysis['strengths']),
        weaknesses: List<String>.from(analysis['weaknesses']),
        atsCompatibility: analysis['ats_compatibility'] as String,
        atsTips: analysis['ats_tips'] as String?,
        suggestions: List<String>.from(analysis['suggestions']),
      );

      DebugLogger.success('RESUME', 'PIPELINE_COMPLETED',
          'Analysis pipeline completed successfully');

      completer.complete(savedAnalysis);

      if (mounted) {
        // Replace processing screen with analysis screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResumeAnalysisScreen(analysis: savedAnalysis),
          ),
        );
      }
    } catch (e) {
      DebugLogger.failed('RESUME', 'ANALYZE_FAILED', e.toString(), error: e);
      completer.completeError(e);
      if (mounted) {
        Navigator.of(context).pop(); // Go back to upload screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.formatError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF64748B)),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Page Header
                const Text(
                  'Upload Your Resume',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A), // Slate 900
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                const Text(
                  "We'll analyze your CV against millions of job descriptions to give you actionable feedback.",
                  style: TextStyle(
                    color: Color(0xFF475569), // Slate 600
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 24),

                // Upload card
                _buildUploadCard()
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Feature grid
                _buildFeatureGrid().animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Drag-and-drop zone
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('resume_pick_zone'),
              onTap: _isAnalyzing ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              // hitTestBehavior: HitTestBehavior.opaque, // This was not in the instruction, but often useful with InkWell
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: _selectedFile != null
                      ? const Color(0xFFF0FDF4) // green-50
                      : (_isDragging
                          ? const Color(0xFFEEF2FF)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFile != null
                        ? const Color(0xFF22C55E) // green-500
                        : (_isDragging
                            ? const Color(0xFF6366F1)
                            : const Color(
                                0xFFCBD5E1)), // indigo-500 : slate-300
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedFile != null
                    ? _buildFileSelected()
                    : _buildDropZoneEmpty(),
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Fallback button
          OutlinedButton.icon(
            key: const ValueKey('resume_pick_button'),
            onPressed: _isAnalyzing ? null : _pickFile,
            icon: const Icon(Icons.file_open_rounded, size: 18),
            label: const Text('Choose File'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              foregroundColor: const Color(0xFF64748B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),

          const SizedBox(height: 24),

          // Analyze button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                key: const ValueKey('resume_analyze_button'),
                onPressed: (_selectedFile == null || _isAnalyzing)
                    ? null
                    : _analyzeResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5), // Indigo 600
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0), // Slate 200
                  disabledForegroundColor: const Color(0xFF94A3B8), // Slate 400
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Analyze Resume',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 550;
      return Column(
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.description_rounded,
                    title: 'ATS Check',
                    desc:
                        'See how well your resume parses for applicant tracking systems.',
                    iconColor: const Color(0xFF2563EB),
                    titleColor: const Color(0xFF1E3A8A), // Blue 900
                    descColor: const Color(0xFF1D4ED8), // Blue 700
                    bgColor: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFFDBEAFE),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.check_circle_rounded,
                    title: 'Action Verbs',
                    desc:
                        "We'll highlight weak verbs and suggest stronger alternatives.",
                    iconColor: const Color(0xFF9333EA),
                    titleColor: const Color(0xFF581C87), // Purple 900
                    descColor: const Color(0xFF7E22CE), // Purple 700
                    bgColor: const Color(0xFFFAF5FF),
                    borderColor: const Color(0xFFF3E8FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.warning_rounded,
                    title: 'Formatting',
                    desc:
                        'Check specifically for layout issues that confuse bots.',
                    iconColor: const Color(0xFFEA580C),
                    titleColor: const Color(0xFF7C2D12), // Orange 900
                    descColor: const Color(0xFFC2410C), // Orange 700
                    bgColor: const Color(0xFFFFF7ED),
                    borderColor: const Color(0xFFFFEDD5),
                  ),
                ),
              ],
            )
          else ...[
            _buildFeatureCard(
              icon: Icons.description_rounded,
              title: 'ATS Check',
              desc:
                  'See how well your resume parses for applicant tracking systems.',
              iconColor: const Color(0xFF2563EB),
              titleColor: const Color(0xFF1E3A8A),
              descColor: const Color(0xFF1D4ED8),
              bgColor: const Color(0xFFEFF6FF),
              borderColor: const Color(0xFFDBEAFE),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.check_circle_rounded,
              title: 'Action Verbs',
              desc:
                  "We'll highlight weak verbs and suggest stronger alternatives.",
              iconColor: const Color(0xFF9333EA),
              titleColor: const Color(0xFF581C87),
              descColor: const Color(0xFF7E22CE),
              bgColor: const Color(0xFFFAF5FF),
              borderColor: const Color(0xFFF3E8FF),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.warning_rounded,
              title: 'Formatting',
              desc: 'Check specifically for layout issues that confuse bots.',
              iconColor: const Color(0xFFEA580C),
              titleColor: const Color(0xFF7C2D12),
              descColor: const Color(0xFFC2410C),
              bgColor: const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFFFEDD5),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildDropZoneEmpty() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.upload_rounded,
              size: 32, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text('Click to upload or drag and drop',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.slate900)),
        const SizedBox(height: 4),
        const Text('PDF only (max. 10 MB)',
            style: TextStyle(fontSize: 13, color: AppColors.slate400)),
      ],
    );
  }

  Widget _buildFileSelected() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              size: 32, color: Color(0xFF16A34A)),
        ),
        const SizedBox(height: 16),
        Text(
          _selectedFile!.name,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.slate900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
          style: const TextStyle(fontSize: 13, color: AppColors.slate400),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _selectedFile = null),
          child: const Text('Remove file',
              style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color titleColor,
    required Color descColor,
    required String title,
    required String desc,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: titleColor)),
          const SizedBox(height: 4),
          Text(desc,
              style: TextStyle(fontSize: 12, color: descColor, height: 1.4)),
        ],
      ),
    );
  }
}
