import 'dart:async';

import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProcessingStateScreen extends StatefulWidget {
  final Future<dynamic> processingFuture;
  final VoidCallback onComplete;

  const ProcessingStateScreen({
    super.key,
    required this.processingFuture,
    required this.onComplete,
  });

  @override
  State<ProcessingStateScreen> createState() => _ProcessingStateScreenState();
}

class _ProcessingStateScreenState extends State<ProcessingStateScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    "Extracting text...",
    "Parsing structure...",
    "AI Analysis in progress...",
    "Generating insights...",
  ];

  bool _isTaskCompleted = false;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    DebugLogger.info('RESUME_PROCESSING', 'PROCESSING_STARTED',
        'Started processing simulation UI');
    _startSimulatedProgress();
    _handleProcessing();
  }

  void _startSimulatedProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        _timer.cancel();
      }
    });
  }

  Future<void> _handleProcessing() async {
    try {
      await widget.processingFuture;
      if (mounted) {
        setState(() {
          _isTaskCompleted = true;
          _currentStep = _steps.length - 1;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        DebugLogger.success('RESUME_PROCESSING', 'PROCESSING_COMPLETED',
            'Processing future completed successfully');
        widget.onComplete();
      }
    } catch (e) {
      DebugLogger.failed('RESUME_PROCESSING', 'PROCESSING_FAILED', e.toString(),
          error: e);
      if (mounted) {
        Navigator.of(context).pop(e.toString());
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Progress Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: const Color(0xFFF1F5F9), // Slate 100
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 4,
                  width: MediaQuery.of(context).size.width * progress,
                  color: const Color(0xFF4F46E5), // Indigo 600
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF), // Indigo 50
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: !_isTaskCompleted
                            ? const CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Color(0xFF4F46E5),
                              )
                                .animate(
                                    onPlay: (controller) => controller.repeat())
                                .rotate(duration: 2.seconds)
                            : const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF22C55E),
                                size: 40,
                              ).animate().scale(
                                duration: 400.ms, curve: Curves.elasticOut),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Analyzing Resume',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please wait while we process your document',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Steps List
                    Column(
                      children: List.generate(_steps.length, (index) {
                        final isActive = index == _currentStep;
                        final isCompleted = index < _currentStep;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFEEF2FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFFE0E7FF)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? const Color(0xFFDCFCE7)
                                        : (isActive
                                            ? const Color(0xFFE0E7FF)
                                            : const Color(0xFFF1F5F9)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: isCompleted
                                        ? const Icon(Icons.check,
                                            size: 14, color: Color(0xFF16A34A))
                                        : Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isActive
                                                  ? const Color(0xFF4F46E5)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _steps[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isActive || isCompleted
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ).animate(target: isActive ? 1 : 0).scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.02, 1.02)),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
