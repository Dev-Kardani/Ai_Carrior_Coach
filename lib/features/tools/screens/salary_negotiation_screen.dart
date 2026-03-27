import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SalaryNegotiationScreen extends StatefulWidget {
  const SalaryNegotiationScreen({super.key});

  @override
  State<SalaryNegotiationScreen> createState() =>
      _SalaryNegotiationScreenState();
}

class _SalaryNegotiationScreenState extends State<SalaryNegotiationScreen> {
  final _geminiService = GeminiService();
  final _supabaseService = SupabaseService();

  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _offerController = TextEditingController();
  String _experience = 'Mid (3-5 yrs)';
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;

  final List<Map<String, dynamic>> _salaryData = [
    {'percentile': '10th', 'salary': 95000},
    {'percentile': '25th', 'salary': 115000},
    {'percentile': '50th', 'salary': 140000},
    {'percentile': '75th', 'salary': 165000},
    {'percentile': '90th', 'salary': 195000},
  ];

  final List<String> _expLevels = [
    'Entry (0-2 yrs)',
    'Mid (3-5 yrs)',
    'Senior (6+ yrs)',
  ];

  @override
  void dispose() {
    _roleController.dispose();
    _locationController.dispose();
    _offerController.dispose();
    super.dispose();
  }

  Future<void> _handleAnalyze() async {
    final role = _roleController.text.trim();
    if (role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a target role')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    DebugLogger.info(
        'TOOLS_SALARY', 'ANALYZE', 'Analyzing market for $role ($_experience)');

    try {
      final resume = await _supabaseService.getLatestResume();
      if (resume == null) {
        throw Exception(
            'Please upload your resume first to personalize the negotiation script.');
      }

      final result = await _geminiService.generateNegotiationScript(
        targetRole: role,
        offerDetails: _offerController.text.trim().isEmpty
            ? 'Not provided yet - looking for general market range and script.'
            : _offerController.text.trim(),
        resumeText: resume.extractedText,
      );
      DebugLogger.success('TOOLS_SALARY', 'ANALYZE', 'Analysis complete');

      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      DebugLogger.failed('TOOLS_SALARY', 'ANALYZE', e.toString(), error: e);
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ErrorHandler.showError(context, e.toString());
      }
    }
  }

  Future<void> _handleCopy(String text) async {
    DebugLogger.info('TOOLS_SALARY_UI', 'COPY_SCRIPT');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Script copied!')),
      );
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
        title: const Text('Salary Negotiator',
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
                _buildInputForm(),
                if (_result != null) ...[
                  const SizedBox(height: 24),
                  _buildMarketData(),
                  const SizedBox(height: 24),
                  _buildScriptSection(),
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
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.attach_money_rounded,
              color: Color(0xFFEA580C), size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Salary Negotiator',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900)),
              Text(
                  'Get market data and personalized negotiation scripts based on your profile.',
                  style: TextStyle(fontSize: 14, color: AppColors.slate500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputForm() {
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
          _buildTextField(
              'Target Role', 'e.g. Senior Product Designer', _roleController,
              icon: Icons.work_outline_rounded),
          const SizedBox(height: 16),
          _buildTextField(
              'Location', 'e.g. San Francisco, CA', _locationController,
              icon: Icons.location_on_outlined),
          const SizedBox(height: 16),
          _buildTextField('Current Offer (Optional)', 'e.g. 120,000 USD base',
              _offerController,
              icon: Icons.payments_outlined),
          const SizedBox(height: 20),
          const Text('Experience Level',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate700)),
          const SizedBox(height: 12),
          Row(
            children: _expLevels.map((lvl) {
              final isSelected = _experience == lvl;
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: lvl != _expLevels.last ? 8 : 0),
                  child: InkWell(
                    onTap: () => setState(() => _experience = lvl),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.slate200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        lvl.split(' (').first,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.slate600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _handleAnalyze,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.show_chart_rounded, size: 18),
              label: Text(
                  _isAnalyzing
                      ? 'Analyzing Market...'
                      : 'Analyze & Generate Script',
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

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {IconData? icon, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.slate900, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: AppColors.slate400)
                : null,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketData() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Market Salary Insights',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900)),
          const SizedBox(height: 4),
          Text('Based on ${_roleController.text} research',
              style: const TextStyle(fontSize: 13, color: AppColors.slate500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('25th %', '\$115k', Colors.blue, 'Entry-level'),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Median', '\$140k', AppColors.primary, 'Market Avg'),
              const SizedBox(width: 12),
              _buildStatCard('75th %', '\$165k', Colors.purple, 'Top Tier'),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Market Visualizer',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate800)),
          const SizedBox(height: 16),
          _buildSalaryChart(),
          const SizedBox(height: 32),
          const Text('Leverage Points',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate800)),
          const SizedBox(height: 12),
          ...(_result?['leverage_points'] as List? ?? [])
              .map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: Color(0xFF16A34A)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(point.toString(),
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.slate600))),
                      ],
                    ),
                  )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String label, String value, Color color, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 20, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(sub,
                style: TextStyle(fontSize: 9, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryChart() {
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _salaryData.map((data) {
          final double heightFactor = (data['salary'] as int) / 200000;
          final bool isMedian = data['percentile'] == '50th';
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('\$${(data['salary'] as int) ~/ 1000}k',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isMedian ? FontWeight.bold : FontWeight.normal,
                        color: AppColors.slate500)),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 120 * heightFactor,
                  decoration: BoxDecoration(
                    color: isMedian
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ).animate().scaleY(
                    begin: 0, duration: 800.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 8),
                Text(data['percentile'].toString(),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.slate400)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScriptSection() {
    final scripts = _result?['scripts'] as List? ?? [];
    if (scripts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Negotiation Scripts',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900)),
        const SizedBox(height: 16),
        ...scripts.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s['scenario'] ?? 'Script',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate800)),
                      IconButton(
                        onPressed: () => _handleCopy(s['script'] ?? ''),
                        icon: const Icon(Icons.copy_rounded,
                            size: 18, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s['script'] ?? '',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.slate700, height: 1.6),
                  ),
                ],
              ),
            )),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
