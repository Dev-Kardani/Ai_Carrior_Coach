import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/interview_model.dart';
import 'package:ai_career_coach/models/resume_model.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class InterviewSetupScreen extends StatefulWidget {
  const InterviewSetupScreen({super.key});

  @override
  State<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends State<InterviewSetupScreen> {
  final _supabaseService = SupabaseService();
  final _geminiService = GeminiService();
  final _roleController = TextEditingController();

  ResumeModel? _latestResume;
  bool _isLoading = true;
  bool _isGenerating = false;

  String _selectedRole = 'Software Engineer';
  String _difficulty = 'Medium';
  double _questionCount = 5;
  String _selectedFormat = 'descriptive'; // 'mcq' or 'descriptive'
  bool _useResume = false;

  final List<String> _suggestedRoles = [
    'Software Engineer',
    'Product Designer',
    'Data Scientist',
    'Product Manager',
    'Marketing Manager',
    'Sales Representative',
    'DevOps Engineer',
    'UX Researcher',
  ];

  final List<Map<String, dynamic>> _difficulties = [
    {
      'label': 'Easy',
      'desc': 'Introductory behavioral questions',
      'color': const Color(0xFF16A34A),
      'bg': const Color(0xFFF0FDF4),
      'border': const Color(0xFFDCFCE7),
    },
    {
      'label': 'Medium',
      'desc': 'Mix of technical & behavioral',
      'color': const Color(0xFFEAB308),
      'bg': const Color(0xFFFEFCE8),
      'border': const Color(0xFFFEF9C3),
    },
    {
      'label': 'Hard',
      'desc': 'Advanced technical deep-dives',
      'color': const Color(0xFFDC2626),
      'bg': const Color(0xFFFEF2F2),
      'border': const Color(0xFFFEE2E2),
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkResume();
    _roleController.text = _selectedRole;
  }

  Future<void> _checkResume() async {
    try {
      DebugLogger.info(
          'INTERVIEW_SETUP', 'FETCH_RESUME', 'Checking for latest resume');
      final resume = await _supabaseService.getLatestResume();
      setState(() {
        _latestResume = resume;
        _isLoading = false;
      });
      if (resume != null) {
        DebugLogger.success('INTERVIEW_SETUP', 'FETCH_RESUME',
            'Found resume to use for context');
      } else {
        DebugLogger.warning('INTERVIEW_SETUP', 'FETCH_RESUME',
            'No resume found, using generic context');
      }
    } catch (e) {
      DebugLogger.failed('INTERVIEW_SETUP', 'FETCH_RESUME', e.toString(),
          error: e);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startInterview() async {
    setState(() => _isGenerating = true);
    DebugLogger.info('INTERVIEW_SETUP', 'GENERATE_QUESTIONS',
        'Starting question generation for $_selectedRole at $_difficulty difficulty');

    try {
      final questionsData = await _geminiService.generateInterviewQuestions(
        role: _roleController.text,
        resumeText: _latestResume?.extractedText ?? "",
        format: _selectedFormat,
        useResume: _useResume,
      );

      final allQuestions =
          questionsData.map((q) => InterviewQuestion.fromJson(q)).toList();

      // Limit to selected count
      final questions = allQuestions.take(_questionCount.toInt()).toList();

      DebugLogger.success('INTERVIEW_SETUP', 'GENERATE_QUESTIONS',
          'Successfully generated ${questions.length} questions');

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushNamed(
          '/app/interview/active',
          arguments: {
            'role': _roleController.text,
            'questions': questions,
          },
        );
      }
    } catch (e) {
      DebugLogger.failed('INTERVIEW_SETUP', 'GENERATE_QUESTIONS', e.toString(),
          error: e);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // Slate 50
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: Column(
                    children: [
                      if (MediaQuery.of(context).size.width > 768) ...[
                        const Text(
                          'Mock Interview Setup',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                        const SizedBox(height: 12),
                        const Text(
                          'Configure your practice session and let AI challenge you.',
                          style:
                              TextStyle(color: Color(0xFF64748B), fontSize: 16),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 100.ms),
                      ],
                      const SizedBox(height: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRoleSelection(),
                          const SizedBox(height: 32),
                          _buildFormatSelection(),
                          const SizedBox(height: 32),
                          _buildResumeToggle(),
                          const SizedBox(height: 32),
                          _buildDifficultySelection(),
                          const SizedBox(height: 32),
                          _buildQuestionSlider(),
                          const SizedBox(height: 32),
                          _buildSummaryAndStart(),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.business_center_rounded,
                size: 18, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text(
              'Target Role',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _roleController,
          style: const TextStyle(
              color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'e.g. Senior Flutter Developer',
            prefixIcon:
                const Icon(Icons.edit_note_rounded, color: Color(0xFF4F46E5)),
            suffixIcon: _roleController.text.isNotEmpty
                ? const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF16A34A))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Popular Roles',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth > 500 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: cols == 1 ? 5 : 3.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _suggestedRoles.length,
            itemBuilder: (context, index) {
              final role = _suggestedRoles[index];
              final isSelected = _selectedRole == role;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedRole = role;
                    _roleController.text = role;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  key: ValueKey(
                      'role_card_${role.toLowerCase().replaceAll(' ', '_')}'),
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEEFFA) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      role,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF4338CA)
                            : const Color(0xFF475569),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildResumeToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _useResume ? const Color(0xFFEEF2FF) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description_rounded,
              color: _useResume
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalize with Resume',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Generate questions tailored to your experience',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _useResume,
            activeColor: const Color(0xFF4F46E5),
            onChanged: _latestResume == null
                ? null
                : (v) => setState(() => _useResume = v),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.format_list_bulleted_rounded,
                size: 18, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text(
              'Interview Format',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFormatCard(
                'descriptive',
                'Descriptive',
                'Tell us in detail',
                Icons.text_fields_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatCard(
                'mcq',
                'MCQ',
                'Multiple choice questions',
                Icons.checklist_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatCard(
      String format, String title, String subtitle, IconData icon) {
    final isSelected = _selectedFormat == format;
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = format),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF64748B),
                size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF1E1B4B)
                    : const Color(0xFF0F172A),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? const Color(0xFF4F46E5).withOpacity(0.8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.video_camera_back_rounded,
                size: 18, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text(
              'Difficulty Level',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _difficulties.map((lvl) {
              final isSelected = _difficulty == lvl['label'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _difficulty = lvl['label'] as String),
                child: AnimatedContainer(
                  key: ValueKey(
                      'difficulty_card_${(lvl['label'] as String).toLowerCase()}'),
                  duration: const Duration(milliseconds: 200),
                  width: 140, // Fixed width for scrollable behavior
                  margin:
                      EdgeInsets.only(right: lvl['label'] == 'Hard' ? 0 : 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? lvl['bg'] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? lvl['color'] : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lvl['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? lvl['color']
                              : const Color(0xFF0F172A),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lvl['desc'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? (lvl['color'] as Color).withOpacity(0.8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.history_toggle_off_rounded,
                    size: 18, color: Color(0xFF64748B)),
                SizedBox(width: 8),
                Text(
                  'Number of Questions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
            Text(
              '${_questionCount.toInt()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F46E5),
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF4F46E5),
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: const Color(0xFF4F46E5),
            overlayColor: const Color(0xFF4F46E5).withOpacity(0.1),
            trackHeight: 4,
          ),
          child: Slider(
            key: const ValueKey('interview_question_slider'),
            value: _questionCount,
            min: 3,
            max: 10,
            divisions: 7,
            onChanged: (v) => setState(() => _questionCount = v),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('3 questions',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text('10 questions',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryAndStart() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF), // Indigo 50
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedRole · $_difficulty · ${_questionCount.toInt()} questions',
                      style: const TextStyle(
                        color: Color(0xFF312E81), // Indigo 900
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Format: ${_selectedFormat.toUpperCase()} · ${_useResume ? "Tailored to resume" : "General questions"}',
                      style: const TextStyle(
                          color: Color(0xFF4F46E5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            key: const ValueKey('start_interview_button'),
            onPressed: _isGenerating ? null : _startInterview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isGenerating
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text('Generating Questions...',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Start Interview',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
