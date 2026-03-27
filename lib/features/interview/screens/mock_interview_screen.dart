import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/interview_model.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MockInterviewScreen extends StatefulWidget {
  final String role;
  final List<InterviewQuestion> questions;

  const MockInterviewScreen({
    super.key,
    required this.role,
    required this.questions,
  });

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  final _geminiService = GeminiService();
  final _answerController = TextEditingController();

  int _currentIndex = 0;
  bool _isAnalyzing = false;
  bool _showFeedback = false;
  InterviewFeedback? _currentFeedback;
  String? _selectedMcqOption;
  final List<InterviewFeedback> _feedbacks = [];
  final List<Map<String, String>> _chatHistory =
      []; // Stores pairs of { 'q': '...' , 'a': '...' , 'f': '...' }

  Future<void> _submitAnswer() async {
    final currentQuestion = widget.questions[_currentIndex];
    final answerText = currentQuestion.type == InterviewType.mcq
        ? _selectedMcqOption ?? ""
        : _answerController.text.trim();

    if (answerText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide an answer")),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      DebugLogger.info('INTERVIEW_UI', 'ANALYZING_ANSWER');
      final currentQuestion = widget.questions[_currentIndex];

      if (currentQuestion.type == InterviewType.mcq) {
        // Simple MCQ Feedback
        final isCorrect = answerText.trim().toLowerCase() ==
            currentQuestion.expectedAnswer.trim().toLowerCase();

        _currentFeedback = InterviewFeedback(
          overallScore: isCorrect ? 100 : 0,
          strengths: isCorrect ? ['Correct identification'] : [],
          improvements: isCorrect ? [] : ['Review this concept'],
          summary: isCorrect
              ? "Correct! ${currentQuestion.tip}"
              : "Incorrect. The correct answer was: ${currentQuestion.expectedAnswer}. ${currentQuestion.tip}",
          skillScores: {
            'Communication': 100,
            'Technical Depth': isCorrect ? 100 : 0,
            'Problem Solving': isCorrect ? 100 : 0,
            'Confidence': 100,
            'Structure': 100,
          },
        );
      } else {
        final feedbackData = await _geminiService.analyzeInterviewResponse(
          question: currentQuestion.question,
          answer: answerText,
        );
        _currentFeedback = InterviewFeedback.fromJson(feedbackData);
      }

      setState(() {
        _isAnalyzing = false;
        _showFeedback = true;
      });
    } catch (e) {
      DebugLogger.failed('INTERVIEW_UI', 'ANALYSIS_FAILED', e.toString(),
          error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to analyze response. Try again.")),
        );
      }
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _nextQuestion() {
    if (_currentFeedback != null) {
      _feedbacks.add(_currentFeedback!);
    }

    _chatHistory.add({
      'q': widget.questions[_currentIndex].question,
      'a': widget.questions[_currentIndex].type == InterviewType.mcq
          ? _selectedMcqOption ?? "No answer"
          : _answerController.text,
      'f': _currentFeedback?.summary ?? "",
    });

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answerController.clear();
        _selectedMcqOption = null;
        _showFeedback = false;
        _currentFeedback = null;
      });
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/app/interview/feedback',
          arguments: {
            'role': widget.role,
            'questions': widget.questions,
            'feedbacks': _feedbacks,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mock Interview',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Question ${_currentIndex + 1} of ${widget.questions.length}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
          onPressed: () {
            DebugLogger.info('INTERVIEW_UI', 'CLOSE_BUTTON_CLICKED');
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined,
                    size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  '~${(widget.questions.length - _currentIndex) * 3} min left',
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sleek Progress Bar
          Container(
            height: 4,
            width: double.infinity,
            color: const Color(0xFFF1F5F9), // Slate 100
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        // Previous Conversation History
                        ..._chatHistory.map((item) => Column(
                              children: [
                                _buildInterviewerBubble(item['q']!,
                                    isPast: true),
                                const SizedBox(height: 16),
                                _buildUserBubble(item['a']!),
                                const SizedBox(height: 16),
                                if (item['f']!.isNotEmpty)
                                  _buildFeedbackBubble(item['f']!,
                                      isPast: true),
                                const SizedBox(height: 24),
                              ],
                            )),

                        // Current Question
                        _buildInterviewerBubble(currentQuestion.question),

                        if (_isAnalyzing) ...[
                          const SizedBox(height: 24),
                          _buildThinkingIndicator(),
                        ],

                        const SizedBox(height: 40),

                        // Answer Section
                        if (!_showFeedback)
                          currentQuestion.type == InterviewType.mcq
                              ? _buildMcqInput(currentQuestion)
                              : _buildAnswerInput()
                        else
                          _buildFeedbackBubble(_currentFeedback?.summary ?? ""),

                        const SizedBox(height: 40),

                        // Navigation Dots
                        _buildNavigationDots(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildUserBubble(String answer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9), // Slate 100
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child:
                Icon(Icons.person_rounded, color: Color(0xFF64748B), size: 16),
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildThinkingIndicator() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEEEFFA),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.smart_toy_outlined,
                color: Color(0xFF4F46E5), size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FF),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedDot(0),
              _buildAnimatedDot(1),
              _buildAnimatedDot(2),
            ],
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildAnimatedDot(int index) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        color: Color(0xFF818CF8),
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .moveY(
            begin: 0,
            end: -4,
            duration: 400.ms,
            delay: (index * 150).ms,
            curve: Curves.easeInOut)
        .then()
        .moveY(begin: -4, end: 0, duration: 400.ms, curve: Curves.easeInOut);
  }

  Widget _buildNavigationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.questions.length, (index) {
        final isActive = index == _currentIndex;
        final isCompleted = index < _currentIndex;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF4F46E5)
                : (isCompleted
                    ? const Color(0xFFC7D2FE)
                    : const Color(0xFFE2E8F0)),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildInterviewerBubble(String question, {bool isPast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isPast ? 32 : 40,
          height: isPast ? 32 : 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEEEFFA),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.smart_toy_outlined,
                color: const Color(0xFF4F46E5), size: isPast ? 16 : 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(isPast ? 16 : 20),
            decoration: BoxDecoration(
              color: isPast ? const Color(0xFFF8FAFC) : const Color(0xFFF5F7FF),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border:
                  isPast ? Border.all(color: const Color(0xFFF1F5F9)) : null,
            ),
            child: Text(
              question,
              style: TextStyle(
                fontSize: isPast ? 14 : 16,
                color:
                    isPast ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                height: 1.6,
                fontWeight: isPast ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ).animate().fadeIn().slideX(begin: isPast ? 0 : -0.1, end: 0),
        ),
      ],
    );
  }

  Widget _buildAnswerInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.speaker_notes_rounded,
                size: 16, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text(
              'Your Answer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            key: const ValueKey('interview_answer_field'),
            controller: _answerController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style:
                const TextStyle(fontSize: 15, color: Colors.black, height: 1.5),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Type or speak your answer here...',
              hintStyle: TextStyle(color: Color(0xFF94A3B8)),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMcqInput(InterviewQuestion question) {
    return Column(
      children: question.options!.map((option) {
        final isSelected = _selectedMcqOption == option;
        return GestureDetector(
          onTap: () => setState(() => _selectedMcqOption = option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackBubble(String feedback, {bool isPast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFF0FDF4),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.tips_and_updates_rounded,
                color: Color(0xFF16A34A), size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suggestion',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feedback,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF166534),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              key: const ValueKey('submit_answer_button'),
              onPressed: _isAnalyzing
                  ? null
                  : (_showFeedback ? _nextQuestion : _submitAnswer),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isAnalyzing
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
                        Text('Processing...',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showFeedback
                              ? (_currentIndex < widget.questions.length - 1
                                  ? 'Next Question'
                                  : 'Finish Interview')
                              : 'Submit Answer',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                            _showFeedback
                                ? Icons.arrow_forward_rounded
                                : Icons.send_rounded,
                            size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
