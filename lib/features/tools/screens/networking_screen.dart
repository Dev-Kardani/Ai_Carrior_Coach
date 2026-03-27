import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NetworkingScreen extends StatefulWidget {
  const NetworkingScreen({super.key});

  @override
  State<NetworkingScreen> createState() => _NetworkingScreenState();
}

class _NetworkingScreenState extends State<NetworkingScreen> {
  final _geminiService = GeminiService();
  final _supabaseService = SupabaseService();

  String? _selectedIntent;
  bool _isGenerating = false;
  String? _generatedMessage;
  bool _copied = false;

  final List<Map<String, String>> _intents = [
    {'label': 'Informational Interview', 'value': 'Informational Interview'},
    {'label': 'Referral Request', 'value': 'Referral Request'},
    {'label': 'Coffee Chat', 'value': 'Coffee Chat'},
    {'label': 'Mentorship', 'value': 'Mentorship Request'},
  ];

  Future<void> _handleGenerate() async {
    if (_selectedIntent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an intent first')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    DebugLogger.info('TOOLS_NETWORKING', 'GENERATE_MESSAGE',
        'Generating message for intent: $_selectedIntent');

    try {
      final resume = await _supabaseService.getLatestResume();
      if (resume == null) {
        throw Exception(
            'Please upload your resume first to generate a tailored message.');
      }

      // We'll use a placeholder for target role since it's not in the design's immediate form but in resume
      final message = await _geminiService.generateNetworkingMessage(
        resumeText: resume.extractedText,
        targetRole: 'Professional in your network',
        intent: _selectedIntent!,
      );
      DebugLogger.success('TOOLS_NETWORKING', 'GENERATE_MESSAGE',
          'Message generated successfully');

      setState(() {
        _generatedMessage = message;
        _isGenerating = false;
      });
    } catch (e) {
      DebugLogger.failed('TOOLS_NETWORKING', 'GENERATE_MESSAGE', e.toString(),
          error: e);
      setState(() => _isGenerating = false);
      if (mounted) {
        ErrorHandler.showError(context, e.toString());
      }
    }
  }

  Future<void> _handleCopy() async {
    if (_generatedMessage == null) return;
    DebugLogger.info('TOOLS_NETWORKING_UI', 'COPY_MESSAGE');
    await Clipboard.setData(ClipboardData(text: _generatedMessage!));
    setState(() => _copied = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slate700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Networking Message',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.slate100),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildIntentSelection(),
                if (_generatedMessage != null) ...[
                  const SizedBox(height: 24),
                  _buildResultSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.people_alt_outlined,
              color: Color(0xFF16A34A), size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Networking Message',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900)),
              Text(
                  'Create professional LinkedIn outreach messages tailored to your profile.',
                  style: TextStyle(fontSize: 14, color: AppColors.slate500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntentSelection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's your intent?",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate700)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _intents.length,
            itemBuilder: (context, index) {
              final intent = _intents[index];
              final isSelected = _selectedIntent == intent['value'];
              return InkWell(
                onTap: () => setState(() => _selectedIntent = intent['value']),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.slate200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      intent['label']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected ? AppColors.primary : AppColors.slate600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _handleGenerate,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(_isGenerating ? 'Generating...' : 'Generate Message',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('LinkedIn Message Draft',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900)),
              TextButton.icon(
                onPressed: _handleCopy,
                icon: Icon(
                    _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                    size: 16),
                label: Text(_copied ? 'Copied!' : 'Copy'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: const Color(0xFFEEF2FF),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate100),
            ),
            child: Text(
              _generatedMessage!,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.slate700, height: 1.6),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
