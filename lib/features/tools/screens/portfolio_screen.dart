import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _geminiService = GeminiService();
  final _supabaseService = SupabaseService();

  bool _isLoading = false;
  List<Map<String, dynamic>> _suggestions = [];
  final String _targetRole = 'Product Designer';

  final List<Map<String, dynamic>> _myProjects = [
    {
      'id': '1',
      'title': 'Payment Flow Redesign',
      'description':
          'Redesigned the checkout experience for a fintech platform, reducing cart abandonment by 25%.',
      'role': 'Lead Designer',
      'tags': ['UX Design', 'Fintech', 'User Research'],
      'impact': '25% reduction in cart abandonment',
    },
    {
      'id': '2',
      'title': 'Design System v2.0',
      'description':
          'Built a comprehensive design system with 200+ components used across 5 product teams.',
      'role': 'Design Systems Lead',
      'tags': ['Design Systems', 'Figma', 'Documentation'],
      'impact': '40% faster design-to-dev handoff',
    },
    {
      'id': '3',
      'title': 'Mobile App Onboarding',
      'description':
          'Created a personalized onboarding flow that improved user activation by 35%.',
      'role': 'Product Designer',
      'tags': ['Mobile', 'Onboarding', 'A/B Testing'],
      'impact': '35% increase in activation rate',
    },
  ];

  bool _showAddForm = false;
  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();
  final _impactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);
    DebugLogger.info('TOOLS_PORTFOLIO', 'GENERATE_SUGGESTIONS',
        'Generating project suggestions for $_targetRole');
    try {
      final resume = await _supabaseService.getLatestResume();
      if (resume == null) {
        DebugLogger.warning('TOOLS_PORTFOLIO', 'GENERATE_SUGGESTIONS',
            'No resume found for AI context');
        setState(() => _isLoading = false);
        return;
      }

      final suggestions = await _geminiService.generateProjectSuggestions(
        resumeText: resume.extractedText,
        targetRole: _targetRole,
      );
      DebugLogger.success('TOOLS_PORTFOLIO', 'GENERATE_SUGGESTIONS',
          'Generated ${suggestions.length} suggestions');

      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      DebugLogger.failed(
          'TOOLS_PORTFOLIO', 'GENERATE_SUGGESTIONS', e.toString(),
          error: e);
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to generate recommendations');
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
        title: const Text('Portfolio Architect',
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
                _buildAiBanner(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Portfolio Projects',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900)),
                        Text('Manage and showcase your best work.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.slate500)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          setState(() => _showAddForm = !_showAddForm),
                      icon: Icon(_showAddForm ? Icons.close : Icons.add_rounded,
                          size: 18),
                      label: Text(_showAddForm ? 'Cancel' : 'Add Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                if (_showAddForm) ...[
                  const SizedBox(height: 16),
                  _buildAddForm(),
                ],
                const SizedBox(height: 24),
                _buildMyProjectsList(),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Recommended Projects',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900)),
                        Text('Suggested projects based on your target role.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.slate500)),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _loadSuggestions,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Regenerate'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ))
                else if (_suggestions.isEmpty)
                  _buildEmptyState()
                else
                  _buildProjectList(),
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
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.palette_outlined,
              color: Color(0xFF9333EA), size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Portfolio Architect',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900)),
              Text(
                  'Strategically plan and improve your design portfolio with AI.',
                  style: TextStyle(fontSize: 14, color: AppColors.slate500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAF5FF), Color(0xFFEEF2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: Color(0xFF9333EA), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Recommendation',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B21A8))),
                const SizedBox(height: 4),
                Text(
                  'Based on your target role as $_targetRole, we recommend showcasing 3-5 projects that highlight technical depth, problem-solving, and measurable business impact.',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF7E22CE), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildProjectList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final project = _suggestions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.grid_view_rounded,
                    color: AppColors.slate400, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project['title'] ?? 'New Project Idea',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                                    project['difficulty'] ?? 'Intermediate')
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            project['difficulty'] ?? 'Intermediate',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(
                                    project['difficulty'] ?? 'Intermediate')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project['description'] ?? '',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.slate600, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          ((project['skills_demonstrated'] as List?) ?? [])
                              .map((skill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      skill.toString(),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))
                              .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.rocket_launch_rounded,
                            size: 14, color: Color(0xFF16A34A)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            project['impact'] ?? '',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildAddForm() {
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
          const Text('New Project',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _buildInput('Project Title', 'e.g. Stripe Redesign',
                      _titleController)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildInput(
                      'Your Role', 'e.g. Lead Designer', _roleController)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInput(
              'Description', 'Briefly describe your project', _descController,
              maxLines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildInput('Tags (comma separated)', 'UX, Figma, Web',
                      _tagsController)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildInput('Impact (Key Metric)',
                      'e.g. +20% conversion', _impactController)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _showAddForm = false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _handleAddProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Project'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.05, end: 0);
  }

  Widget _buildInput(
      String label, String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.slate900, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.slate400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.slate200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.slate200)),
          ),
        ),
      ],
    );
  }

  void _handleAddProject() {
    if (_titleController.text.trim().isEmpty) return;
    setState(() {
      _myProjects.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'role': _roleController.text.trim(),
        'tags': _tagsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'impact': _impactController.text.trim(),
      });
      _showAddForm = false;
      _titleController.clear();
      _descController.clear();
      _roleController.clear();
      _tagsController.clear();
      _impactController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project added successfully!')));
  }

  Widget _buildMyProjectsList() {
    if (_myProjects.isEmpty) {
      return const Center(
        child: Text('No projects added yet.',
            style: TextStyle(color: AppColors.slate400)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _myProjects.length,
      itemBuilder: (context, index) {
        final project = _myProjects[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_outlined,
                    color: AppColors.slate400, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(project['title'],
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slate900)),
                        ),
                        IconButton(
                          onPressed: () =>
                              setState(() => _myProjects.removeAt(index)),
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent, size: 18),
                        ),
                      ],
                    ),
                    Text(project['description'],
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.slate500,
                            height: 1.4)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (project['tags'] as List)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(tag,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF7C3AED),
                                        fontWeight: FontWeight.w500)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            project['role'],
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (project['impact'] != null &&
                            project['impact'].isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.circle,
                              size: 4, color: AppColors.slate300),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              project['impact'],
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String diff) {
    if (diff.toLowerCase().contains('beginner')) return Colors.blue;
    if (diff.toLowerCase().contains('advanced')) return Colors.orange;
    return AppColors.primary;
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 40),
          Icon(Icons.folder_open_rounded, size: 48, color: AppColors.slate300),
          SizedBox(height: 16),
          Text('No recommendations yet',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.slate500)),
          SizedBox(height: 8),
          Text('Upload your resume to get project ideas.',
              style: TextStyle(fontSize: 13, color: AppColors.slate400)),
        ],
      ),
    );
  }
}
