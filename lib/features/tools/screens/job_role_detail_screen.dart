import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/insight_model.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:flutter/material.dart';

class JobRoleDetailScreen extends StatefulWidget {
  final String roleName;

  const JobRoleDetailScreen({super.key, required this.roleName});

  @override
  State<JobRoleDetailScreen> createState() => _JobRoleDetailScreenState();
}

class _JobRoleDetailScreenState extends State<JobRoleDetailScreen> {
  final _geminiService = GeminiService();
  bool _isLoading = true;
  JobRoleDetail? _detail;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final data = await _geminiService.getJobRoleDetails(widget.roleName);
      if (mounted) {
        setState(() {
          _detail = JobRoleDetail.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      DebugLogger.failed('JOB_DETAIL', 'FETCH', e.toString());
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load role details: $e')),
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
        title: Text(widget.roleName,
            style: const TextStyle(
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
          : _detail == null
              ? const Center(child: Text('No details available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRoleOverview(),
                          const SizedBox(height: 24),
                          _buildDemandAndGrowth(),
                          const SizedBox(height: 24),
                          _buildSalaryInsights(),
                          const SizedBox(height: 24),
                          _buildSkillsSection('Required Skills',
                              _detail!.requiredSkills, AppColors.primary),
                          const SizedBox(height: 16),
                          _buildSkillsSection('Recommended to Learn',
                              _detail!.recommendedSkills, AppColors.warning),
                          const SizedBox(height: 24),
                          _buildHiringCompanies(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildRoleOverview() {
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
          const Text('Role Overview',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate500,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(_detail!.overview,
              style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.slate800,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildDemandAndGrowth() {
    final demandColor = _detail!.demandLevel.toLowerCase() == 'high'
        ? const Color(0xFF16A34A)
        : _detail!.demandLevel.toLowerCase() == 'low'
            ? AppColors.error
            : AppColors.warning;

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Market Demand',
            _detail!.demandLevel,
            demandColor,
            Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            'Growth Rate',
            _detail!.growthPercentage,
            AppColors.primary,
            Icons.bar_chart_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.slate400),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSalaryInsights() {
    final stats = _detail!.salaryDistribution;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Salary Insights',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildSalaryItem(
                    'Min', stats['min'] ?? 'N/A', AppColors.slate500)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildSalaryItem(
                    'Avg', stats['avg'] ?? 'N/A', AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildSalaryItem(
                    'Max', stats['max'] ?? 'N/A', const Color(0xFF16A34A))),
          ],
        ),
      ],
    );
  }

  Widget _buildSalaryItem(String label, String value, Color color) {
    return Container(
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
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(String title, List<String> skills, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Text(
                skill,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHiringCompanies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Hiring Companies',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _detail!.topHiringCompanies.map((company) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business_rounded,
                        size: 16, color: AppColors.slate400),
                  ),
                  const SizedBox(width: 12),
                  Text(company,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate700)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
