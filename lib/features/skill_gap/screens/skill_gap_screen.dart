import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkillGapScreen extends StatefulWidget {
  const SkillGapScreen({super.key});

  @override
  State<SkillGapScreen> createState() => _SkillGapScreenState();
}

class _SkillGapScreenState extends State<SkillGapScreen>
    with SingleTickerProviderStateMixin {
  final _supabaseService = SupabaseService();
  final _geminiService = GeminiService();
  final _targetRoleController = TextEditingController(text: 'Product Designer');

  late TabController _tabController;
  bool _isAnalyzing = false;

  List<Map<String, dynamic>> _skillsData = [];
  List<Map<String, dynamic>> _missingSkills = [];
  List<Map<String, dynamic>> _roadmap = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _targetRoleController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    DebugLogger.info('SKILL_GAP', 'LOAD_ANALYSIS', 'Starting _loadAnalysis');
    setState(() => _isAnalyzing = true);
    try {
      DebugLogger.info('SKILL_GAP', 'FETCH_RESUME', 'Fetching latest resume');
      final resume = await _supabaseService.getLatestResume();

      if (resume != null) {
        DebugLogger.success('SKILL_GAP', 'RESUME_FOUND',
            'Latest resume found: ${resume.fileName}');
        await _runAnalysis(resume.extractedText);
      } else {
        DebugLogger.warning(
            'SKILL_GAP', 'NO_RESUME_FOUND', 'No resume found for analysis');
        if (mounted) {
          ErrorHandler.showError(
              context, 'No resume found. Please upload a resume first.');
        }
        setState(() {
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      DebugLogger.failed('SKILL_GAP', 'LOAD_ANALYSIS_FAILED', e.toString(),
          error: e);
      if (mounted) {
        ErrorHandler.showError(context, ErrorHandler.formatError(e));
      }
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _runAnalysis(String resumeText) async {
    final role = _targetRoleController.text.trim();
    DebugLogger.info(
        'SKILL_GAP', 'RUN_ANALYSIS', 'Starting _runAnalysis for role: $role');
    if (role.isEmpty) {
      DebugLogger.warning(
          'SKILL_GAP', 'ROLE_EMPTY', 'Role is empty, skipping.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      DebugLogger.info(
          'SKILL_GAP', 'CALL_GEMINI', 'Calling Gemini for skill gap analysis');
      final result = await _geminiService.analyzeSkillGap(
        role: role,
        resumeText: resumeText,
      );

      DebugLogger.success('SKILL_GAP', 'GEMINI_ANALYSIS_RECEIVED',
          'Gemini analysis received. Parsing data...');

      setState(() {
        // Robust parsing for competency_scores
        _skillsData = [];
        final rawScores = result['competency_scores'];
        if (rawScores is List) {
          for (var e in rawScores) {
            if (e is Map) {
              _skillsData.add({
                'name': e['skill']?.toString() ?? 'Unknown Skill',
                'current': (e['current'] as num?)?.toInt() ?? 0,
                'target': (e['target'] as num?)?.toInt() ?? 100,
              });
            }
          }
        }
        DebugLogger.info(
            'SKILL_GAP', 'PARSING', 'Parsed ${_skillsData.length} skills');

        // Robust parsing for missing_skills
        _missingSkills = [];
        final rawMissing = result['missing_skills'];
        if (rawMissing is List) {
          for (var e in rawMissing) {
            if (e is Map) {
              _missingSkills.add({
                'name': e['name']?.toString() ??
                    e['skill']?.toString() ??
                    'Unnamed Skill',
                'priority': e['priority']?.toString() ?? 'Medium',
                'timeframe': e['timeframe']?.toString() ?? 'TBD',
              });
            }
          }
        }
        DebugLogger.info('SKILL_GAP', 'PARSING',
            'Parsed ${_missingSkills.length} missing skills');

        // Robust parsing for learning_roadmap
        _roadmap = [];
        final rawRoadmap = result['learning_roadmap'];
        if (rawRoadmap is List) {
          for (var phase in rawRoadmap) {
            if (phase is Map) {
              final rawItems = phase['items'];
              final items = <Map<String, String>>[];
              if (rawItems is List) {
                for (var item in rawItems) {
                  if (item is Map) {
                    items.add({
                      'title': item['title']?.toString() ?? 'Lesson',
                      'type': item['type']?.toString() ?? 'Course',
                      'duration': item['duration']?.toString() ?? 'N/A',
                    });
                  }
                }
              }
              _roadmap.add({
                'phase': phase['phase']?.toString() ?? 'Next Steps',
                'items': items,
              });
            }
          }
        }
        DebugLogger.info(
            'SKILL_GAP', 'PARSING', 'Parsed ${_roadmap.length} roadmap phases');
        _isAnalyzing = false;
      });
    } catch (e) {
      DebugLogger.failed('SKILL_GAP', 'RUN_ANALYSIS_FAILED', e.toString(),
          error: e);
      if (mounted) {
        ErrorHandler.showError(context, ErrorHandler.formatError(e));
      }
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _handleUpdate() async {
    final resume = await _supabaseService.getLatestResume();
    if (resume == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload a resume first.")),
        );
      }
      return;
    }
    await _runAnalysis(resume.extractedText);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Skill Gap Analysis',
          style: TextStyle(
            color: Color(0xFF0F172A), // Slate 900
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                // Role Analysis Input
                _buildRoleInputCard()
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),

                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildSkillChart()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildTabPanel()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildSkillChart(),
                      const SizedBox(height: 24),
                      _buildTabPanel(),
                    ],
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleInputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Role Analysis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569), // Slate 700
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 450;
            final inputSection = [
              Expanded(
                flex: isSmall ? 0 : 1,
                child: TextField(
                  controller: _targetRoleController,
                  style:
                      const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. Senior Frontend Developer',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 0 : 12, height: isSmall ? 12 : 0),
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Analyze',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
              ),
            ];

            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: inputSection,
              );
            }

            return Row(
              children: inputSection,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSkillChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current vs Target Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildLegend(const Color(0xFF4F46E5), 'Your Level'),
              const SizedBox(width: 16),
              _buildLegend(const Color(0xFFE2E8F0), 'Target Level'),
            ],
          ),
          const SizedBox(height: 24),
          if (_skillsData.isEmpty && !_isAnalyzing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Enter a target role and analyze to see results',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
            ),
          ..._skillsData.asMap().entries.map((entry) {
            final idx = entry.key;
            final skill = entry.value;
            final current = skill['current'] as int;
            final target = skill['target'] as int;
            final name = skill['name'] as String;
            return _buildSkillRow(name, current, target)
                .animate()
                .fadeIn(delay: (idx * 50).ms)
                .slideX(begin: -0.1, end: 0);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate500,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSkillRow(String name, int current, int target) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate700)),
              Text('$current%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: target / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.slate50,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.slate200),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: current / 100,
                  minHeight: 8,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: const Color(0xFF94A3B8),
              indicatorColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Missing Skills'),
                Tab(text: 'Learning Roadmap'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMissingSkillsTab(),
                _buildRoadmapTab(),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.open_in_new_rounded, size: 14),
            label: const Text('Generate Detailed Study Plan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildMissingSkillsTab() {
    if (_missingSkills.isEmpty && !_isAnalyzing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No gaps identified for this role.',
              style: TextStyle(color: AppColors.slate400, fontSize: 13)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: _missingSkills.map((skill) {
        final isHigh = skill['priority'] == 'High';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate100),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isHigh
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.priority_high_rounded,
                  size: 20,
                  color: isHigh ? AppColors.error : AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(skill['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.slate900)),
                    const SizedBox(height: 4),
                    Text('Priority: ${skill['priority']}',
                        style: TextStyle(
                            fontSize: 12,
                            color: isHigh ? AppColors.error : AppColors.warning,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ETA',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.slate400,
                          fontWeight: FontWeight.bold)),
                  Text(skill['timeframe']!,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate700)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoadmapTab() {
    if (_roadmap.isEmpty && !_isAnalyzing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('Analysis required to generate roadmap.',
              style: TextStyle(color: AppColors.slate400, fontSize: 13)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: _roadmap.asMap().entries.map((entry) {
        final phase = entry.value;
        final items = phase['items'] as List<Map<String, String>>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(phase['phase'] as String,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 12),
            ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          item['type'] == 'Course'
                              ? Icons.play_circle_outline_rounded
                              : Icons.code_rounded,
                          size: 18,
                          color: AppColors.slate400),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(item['title']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.slate700,
                                  fontWeight: FontWeight.w500))),
                      Text(item['duration']!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.slate400,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
            if (entry.key < _roadmap.length - 1) const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}
