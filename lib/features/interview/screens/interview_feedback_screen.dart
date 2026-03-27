import 'dart:math' as math;

import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/interview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class InterviewFeedbackScreen extends StatelessWidget {
  final String role;
  final List<InterviewQuestion> questions;
  final List<InterviewFeedback> feedbacks;

  const InterviewFeedbackScreen({
    super.key,
    required this.role,
    required this.questions,
    required this.feedbacks,
  });

  @override
  Widget build(BuildContext context) {
    final averageScore = feedbacks.isEmpty
        ? 0
        : feedbacks.map((f) => f.overallScore).reduce((a, b) => a + b) ~/
            feedbacks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          'Interview Feedback',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
          onPressed: () {
            DebugLogger.info('INTERVIEW_FEEDBACK_UI', 'ROUTING',
                'Closed feedback screen via header');
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interview Feedback',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                const SizedBox(height: 8),
                const Text(
                  "Here's how you performed across all questions.",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),

                // Score Hero Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 500) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 3, child: _buildScoreCard(averageScore)),
                          const SizedBox(width: 24),
                          Expanded(flex: 7, child: _buildSkillBreakdown()),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildScoreCard(averageScore),
                          const SizedBox(height: 24),
                          _buildSkillBreakdown(),
                        ],
                      );
                    }
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 48),

                // Question by Question Review
                const Row(
                  children: [
                    Icon(Icons.message_outlined,
                        size: 20, color: Color(0xFF4F46E5)),
                    SizedBox(width: 12),
                    Text(
                      'Question-by-Question Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 20),
                ...List.generate(
                  questions.length,
                  (index) => _buildQuestionFeedbackCard(index)
                      .animate()
                      .fadeIn(delay: (500 + index * 100).ms)
                      .slideY(begin: 0.1, end: 0),
                ),

                const SizedBox(height: 48),
                _buildActionButtons(context).animate().fadeIn(delay: 1000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _ScoreDonutPainter(score: score.toDouble()),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined,
                  size: 16, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text(
                'Overall Score',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Above average for this role',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBreakdown() {
    final Map<String, int> aggregateScores = {
      'Communication': 0,
      'Technical Depth': 0,
      'Problem Solving': 0,
      'Confidence': 0,
      'Structure': 0,
    };

    if (feedbacks.isNotEmpty) {
      for (var f in feedbacks) {
        f.skillScores.forEach((key, value) {
          if (aggregateScores.containsKey(key)) {
            aggregateScores[key] = aggregateScores[key]! + value;
          }
        });
      }
      aggregateScores.updateAll((key, value) => value ~/ feedbacks.length);
    }

    final categories = [
      {
        'label': 'Communication',
        'score': aggregateScores['Communication'] ?? 0,
        'color': const Color(0xFF22C55E)
      },
      {
        'label': 'Technical Depth',
        'score': aggregateScores['Technical Depth'] ?? 0,
        'color': const Color(0xFFEAB308)
      },
      {
        'label': 'Problem Solving',
        'score': aggregateScores['Problem Solving'] ?? 0,
        'color': const Color(0xFF3B82F6)
      },
      {
        'label': 'Confidence',
        'score': aggregateScores['Confidence'] ?? 0,
        'color': const Color(0xFFA855F7)
      },
      {
        'label': 'Structure',
        'score': aggregateScores['Structure'] ?? 0,
        'color': const Color(0xFFF97316)
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 18, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text(
                'Skill Breakdown',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cat['label'] as String,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569)),
                        ),
                        Text(
                          '${cat['score']}%',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 8,
                        width: double.infinity,
                        color: const Color(0xFFF1F5F9),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (cat['score'] as int) / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: cat['color'] as Color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildQuestionFeedbackCard(int index) {
    final feedback = feedbacks[index];
    final question = questions[index];
    final isGood = feedback.overallScore >= 80;
    final isAverage = feedback.overallScore >= 60 && feedback.overallScore < 80;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isGood
                      ? const Color(0xFFDCFCE7)
                      : (isAverage
                          ? const Color(0xFFFEF9C3)
                          : const Color(0xFFFEE2E2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isGood
                      ? Icons.thumb_up_outlined
                      : (isAverage
                          ? Icons.bar_chart_rounded
                          : Icons.thumb_down_outlined),
                  size: 16,
                  color: isGood
                      ? const Color(0xFF16A34A)
                      : (isAverage
                          ? const Color(0xFFCA8A04)
                          : const Color(0xFFDC2626)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q${index + 1}: ${question.question}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback.summary,
                      style: const TextStyle(
                          color: Color(0xFF475569), fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.only(left: 48),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 14, color: Color(0xFF4F46E5)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feedback.improvements.isNotEmpty
                        ? feedback.improvements.first
                        : "Keep doing what you're doing!",
                    style: const TextStyle(
                        color: Color(0xFF3730A3), fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 400;
      final buttons = [
        Expanded(
          flex: isSmall ? 0 : 1,
          child: OutlinedButton(
            onPressed: () {
              DebugLogger.info('INTERVIEW_FEEDBACK_UI', 'ROUTING',
                  'Try Again clicked, going back');
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: const Color(0xFF4F46E5),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rotate_left_rounded, size: 18),
                SizedBox(width: 8),
                Text('Try Again',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SizedBox(width: isSmall ? 0 : 16, height: isSmall ? 12 : 0),
        Expanded(
          flex: isSmall ? 0 : 1,
          child: ElevatedButton(
            onPressed: () {
              DebugLogger.info('INTERVIEW_FEEDBACK_UI', 'ROUTING',
                  'Done clicked, resetting to dashboard');
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ];

      if (isSmall) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buttons,
        );
      }

      return Row(
        children: buttons,
      );
    });
  }
}

class _ScoreDonutPainter extends CustomPainter {
  final double score;

  _ScoreDonutPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 20.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final scorePaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double sweepAngle = (score / 100) * 360;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle * (math.pi / 180),
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
