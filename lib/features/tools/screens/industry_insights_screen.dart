import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/insight_model.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';

class IndustryInsightsScreen extends StatefulWidget {
  const IndustryInsightsScreen({super.key});

  @override
  State<IndustryInsightsScreen> createState() => _IndustryInsightsScreenState();
}

class _IndustryInsightsScreenState extends State<IndustryInsightsScreen> {
  final _supabaseService = SupabaseService();
  final _geminiService = GeminiService();
  bool _isLoading = true;
  IndustryInsight? _insight;
  String _targetRole = 'Software Engineer';
  final _roleController = TextEditingController(text: 'Software Engineer');

  final List<String> _suggestedRoles = [
    'Software Engineer',
    'Data Scientist',
    'Product Manager',
    'AI Engineer',
    'UX Designer',
    'Cloud Architect'
  ];

  @override
  void initState() {
    super.initState();
    DebugLogger.info('INDUSTRY_INSIGHTS', 'INITIALIZED',
        'New IndustryInsightsScreen is active');
    _fetchInsights();
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _fetchInsights() async {
    setState(() => _isLoading = true);
    try {
      final resume = await _supabaseService.getLatestResume();
      final resumeText = resume?.extractedText ?? '';

      final data = await _geminiService.getIndustryInsights(
        role: _targetRole,
        resumeText: resumeText,
      );

      if (mounted) {
        setState(() {
          _insight = IndustryInsight.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load insights: $e')),
        );
      }
    }
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
        title: const Text('Market Insights',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.slate100),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildTrendingSkills(),
                      const SizedBox(height: 24),
                      _buildTopRoles(),
                      const SizedBox(height: 24),
                      _buildSalaryInsights(),
                      const SizedBox(height: 24),
                      _buildSkillGapAnalysis(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Industry Context',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _roleController,
                  style: const TextStyle(
                      color: AppColors.slate900,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Enter role (e.g. Flutter Dev)',
                    hintStyle: const TextStyle(color: AppColors.slate400),
                    filled: true,
                    fillColor: AppColors.slate50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate200),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  _targetRole = _roleController.text.trim();
                  if (_targetRole.isNotEmpty) {
                    _fetchInsights();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Quick Research',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate400,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedRoles.map((role) {
              final isSelected = _targetRole == role;
              return InkWell(
                onTap: () {
                  setState(() {
                    _targetRole = role;
                    _roleController.text = role;
                  });
                  _fetchInsights();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.slate200,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.slate600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSkills() {
    if (_insight == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trending Skills',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _insight!.trendingSkills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(skill['name'] as String,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate800)),
                  const SizedBox(width: 8),
                  Text(skill['growth'] as String,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A))),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopRoles() {
    if (_insight == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Job Roles',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900)),
        const SizedBox(height: 16),
        ..._insight!.topRoles.expand((role) => [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/app/tools/market-insights/detail',
                    arguments: role,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.work_outline_rounded,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(role,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate900)),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.slate400),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ]),
      ],
    );
  }

  Widget _buildSalaryInsights() {
    if (_insight == null) return const SizedBox();
    final stats = _insight!.salaryStats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Salary Insights',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900)),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 450;
          if (isSmall) {
            return Column(
              children: [
                _buildSalaryCard(
                    'Min', stats['min'] ?? 'N/A', AppColors.slate500),
                const SizedBox(height: 12),
                _buildSalaryCard(
                    'Avg', stats['avg'] ?? 'N/A', AppColors.primary),
                const SizedBox(height: 12),
                _buildSalaryCard(
                    'Max', stats['max'] ?? 'N/A', const Color(0xFF16A34A)),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                  child: _buildSalaryCard(
                      'Min', stats['min'] ?? 'N/A', AppColors.slate500)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildSalaryCard(
                      'Avg', stats['avg'] ?? 'N/A', AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildSalaryCard(
                      'Max', stats['max'] ?? 'N/A', const Color(0xFF16A34A))),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSalaryCard(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500)),
          const SizedBox(height: 8),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSkillGapAnalysis() {
    if (_insight == null) return const SizedBox();
    final match = _insight!.userMatch;
    final alreadyHas = List<String>.from(match['alreadyHas'] ?? []);
    final shouldLearn = List<String>.from(match['shouldLearn'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Skill Gap Analysis',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkillSection('Skills You Have', alreadyHas,
                  const Color(0xFF16A34A), Icons.check_circle_outline_rounded),
              const SizedBox(height: 24),
              const Divider(color: AppColors.slate100),
              const SizedBox(height: 24),
              _buildSkillSection('Skills to Learn', shouldLearn,
                  AppColors.warning, Icons.lightbulb_outline_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillSection(
      String title, List<String> skills, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 16),
        if (skills.isEmpty)
          const Text('No skills identified yet.',
              style: TextStyle(color: AppColors.slate400, fontSize: 13))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(skill,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: color)),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
