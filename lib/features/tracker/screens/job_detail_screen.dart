import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/job_application_model.dart';
import 'package:ai_career_coach/models/resume_model.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class JobDetailScreen extends StatefulWidget {
  final JobApplicationModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _supabaseService = SupabaseService();
  final _geminiService = GeminiService();

  late JobApplicationModel _job;
  ResumeModel? _latestResume;
  bool isGeneratingAI = false;
  String? aiMessage;
  String? aiCoverLetter;
  String? aiOutreach;
  List<String>? aiTips;
  String _activeTool =
      'follow-up'; // 'follow-up', 'cover-letter', 'outreach', 'tips'

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _loadResume();
  }

  Future<void> _loadResume() async {
    try {
      DebugLogger.info('JOB_DETAIL', 'FETCH_RESUME',
          'Fetching latest resume for AI generate_follow_up context');
      final resume = await _supabaseService.getLatestResume();
      if (resume != null) {
        DebugLogger.success(
            'JOB_DETAIL', 'FETCH_RESUME', 'Found resume context');
      } else {
        DebugLogger.warning(
            'JOB_DETAIL', 'FETCH_RESUME', 'No resume found for context');
      }
      if (mounted) setState(() => _latestResume = resume);
    } catch (e) {
      DebugLogger.failed('JOB_DETAIL', 'FETCH_RESUME', e.toString(), error: e);
    }
  }

  Future<void> _deleteJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title:
            const Text('Delete?', style: TextStyle(color: AppColors.slate900)),
        content: const Text('Remove this application?',
            style: TextStyle(color: AppColors.slate600)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      DebugLogger.info('JOB_DETAIL_SCREEN', 'DELETE_START', 'ID: ${_job.id}');
      try {
        setState(() => isGeneratingAI = true);
        DebugLogger.info('JOB_DETAIL', 'DELETE_JOB',
            'Initiated delete for ${_job.companyName}');
        await _supabaseService.deleteJobApplication(_job.id);
        DebugLogger.success('JOB_DETAIL', 'DELETE_JOB');
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        DebugLogger.failed('JOB_DETAIL', 'DELETE_JOB', e.toString());
        if (mounted) {
          setState(() => isGeneratingAI = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slate600),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Job Details',
            style: TextStyle(
                color: AppColors.slate900,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 600;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.business_rounded,
                                      color: AppColors.primary, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_job.roleTitle,
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.slate900)),
                                      const SizedBox(height: 4),
                                      Text(_job.companyName,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.slate600)),
                                    ],
                                  ),
                                ),
                                if (!isSmall) _buildStatusBadge(_job.status),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (isSmall) ...[
                              _buildStatusBadge(_job.status),
                              const SizedBox(height: 16),
                            ],
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildMetaBadge(Icons.location_on_outlined,
                                    _job.location ?? 'Remote'),
                                _buildMetaBadge(Icons.attach_money_rounded,
                                    _job.salaryRange ?? 'Not specified'),
                                _buildMetaBadge(
                                    Icons.calendar_today_rounded,
                                    DateFormat('MMMM dd, yyyy')
                                        .format(_job.appliedAt)),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.slate100),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            label: 'Edit',
                            color: const Color(0xFFEEF2FF),
                            textColor: AppColors.primary,
                            onTap: () async {
                              DebugLogger.info(
                                  'JOB_DETAIL_UI',
                                  'EDIT_JOB_CLICKED',
                                  'Editing ${_job.companyName}');
                              final updated = await Navigator.pushNamed(
                                context,
                                '/app/jobs/${_job.id}/edit',
                                arguments: _job,
                              ) as bool?;
                              if (updated == true && mounted) {
                                final refreshJobs =
                                    await _supabaseService.getJobApplications();
                                setState(() {
                                  _job = refreshJobs
                                      .firstWhere((j) => j.id == _job.id);
                                });
                              }
                            },
                          ),
                          if (_job.jobUrl != null && _job.jobUrl!.isNotEmpty)
                            _buildActionButton(
                              icon: Icons.open_in_new_rounded,
                              label: 'View Posting',
                              color: const Color(0xFFF8FAFC),
                              textColor: AppColors.slate700,
                              onTap: () {
                                DebugLogger.info(
                                    'JOB_DETAIL_UI',
                                    'VIEW_POSTING_CLICKED',
                                    'Opening ${_job.jobUrl}');
                              },
                            ),
                          _buildActionButton(
                            icon: Icons.delete_outline_rounded,
                            label: 'Remove',
                            color: const Color(0xFFFEF2F2),
                            textColor: AppColors.error,
                            onTap: _deleteJob,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms),

                const SizedBox(height: 24),

                LayoutBuilder(builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 600;
                  final content = [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.message_outlined,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Notes',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate900)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                              _job.notes?.isNotEmpty == true
                                  ? _job.notes!
                                  : 'No notes added.',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors
                                      .black, // Set to black for better visibility
                                  height: 1.5)),
                        ],
                      ),
                    ),
                    if (!isSmall)
                      const SizedBox(width: 24)
                    else
                      const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Activity Timeline',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate900)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTimelineItem(
                            date: DateFormat('MMM dd').format(_job.appliedAt),
                            event: 'Application submitted',
                            isAction: true,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ];

                  if (isSmall) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: content,
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: content[0]),
                      content[1],
                      Expanded(child: content[2]),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFFAF5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E7FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.auto_awesome_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AI Career Tools',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.slate900)),
                                Text(
                                    'Professional tools to boost your application.',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.slate500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Tool Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildToolTab('follow-up', 'Follow-Up',
                                Icons.mail_outline_rounded),
                            _buildToolTab('cover-letter', 'Cover Letter',
                                Icons.description_outlined),
                            _buildToolTab('outreach', 'LinkedIn Message',
                                Icons.person_add_outlined),
                            _buildToolTab('tips', 'App Tips',
                                Icons.lightbulb_outline_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (isGeneratingAI)
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator()))
                      else
                        _buildActiveToolContent(),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.slate400),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(fontSize: 15, color: AppColors.slate600)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    switch (status) {
      case 'Wishlist':
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF334155);
        break;
      case 'Applied':
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1E40AF);
        break;
      case 'Interview':
        bg = const Color(0xFFFEF9C3);
        text = const Color(0xFF854D0E);
        break;
      case 'Offer':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF166534);
        break;
      case 'Rejected':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFF991B1B);
        break;
      default:
        bg = AppColors.slate100;
        text = AppColors.slate700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              color: text, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required Color textColor,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      {required String date,
      required String event,
      required bool isAction,
      bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: isAction ? AppColors.primary : AppColors.slate300,
                  shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(width: 2, height: 30, color: AppColors.slate200),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900)),
              Text(date,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.slate400)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _generateFollowUp() async {
    if (_latestResume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a resume first.')));
      return;
    }
    setState(() => isGeneratingAI = true);
    try {
      final msg = await _geminiService.generateJobFollowUp(
        companyName: _job.companyName,
        roleTitle: _job.roleTitle,
        notes: _job.notes,
        resumeText: _latestResume!.extractedText,
      );
      if (mounted) {
        setState(() {
          aiMessage = msg;
          isGeneratingAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isGeneratingAI = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _generateCoverLetter() async {
    if (_latestResume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a resume first.')));
      return;
    }
    setState(() => isGeneratingAI = true);
    try {
      final letter = await _geminiService.generateCoverLetter(
        resumeText: _latestResume!.extractedText,
        jobDescription:
            'Role: ${_job.roleTitle} at ${_job.companyName}. Notes: ${_job.notes ?? "N/A"}',
      );
      if (mounted) {
        setState(() {
          aiCoverLetter = letter;
          isGeneratingAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isGeneratingAI = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _generateOutreach() async {
    if (_latestResume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a resume first.')));
      return;
    }
    setState(() => isGeneratingAI = true);
    try {
      final msg = await _geminiService.generateNetworkingMessage(
        resumeText: _latestResume!.extractedText,
        targetRole: _job.roleTitle,
        intent: 'Inquiring about my application at ${_job.companyName}',
      );
      if (mounted) {
        setState(() {
          aiOutreach = msg;
          isGeneratingAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isGeneratingAI = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _generateTips() async {
    if (_latestResume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a resume first.')));
      return;
    }
    setState(() => isGeneratingAI = true);
    try {
      final tips = await _geminiService.generateJobApplicationTips(
        companyName: _job.companyName,
        roleTitle: _job.roleTitle,
        resumeText: _latestResume!.extractedText,
      );
      if (mounted) {
        setState(() {
          aiTips = tips;
          isGeneratingAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isGeneratingAI = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildToolTab(String id, String label, IconData icon) {
    final isActive = _activeTool == id;
    return GestureDetector(
      onTap: () => setState(() => _activeTool = id),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.slate200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16, color: isActive ? Colors.white : AppColors.slate500),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.slate600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveToolContent() {
    String? content;
    List<String>? listContent;
    VoidCallback? onGenerate;
    String buttonLabel = '';

    switch (_activeTool) {
      case 'follow-up':
        content = aiMessage;
        onGenerate = _generateFollowUp;
        buttonLabel = 'Generate Follow-Up Email';
        break;
      case 'cover-letter':
        content = aiCoverLetter;
        onGenerate = _generateCoverLetter;
        buttonLabel = 'Generate Cover Letter';
        break;
      case 'outreach':
        content = aiOutreach;
        onGenerate = _generateOutreach;
        buttonLabel = 'Generate Outreach Message';
        break;
      case 'tips':
        listContent = aiTips;
        onGenerate = _generateTips;
        buttonLabel = 'Get Application Tips';
        break;
    }

    if (content == null && listContent == null) {
      return Center(
        child: ElevatedButton(
          onPressed: onGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(buttonLabel,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content != null)
          _buildResultCard(content)
        else if (listContent != null)
          ...listContent.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(tip,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.slate800,
                                height: 1.5))),
                  ],
                ),
              )),
        const SizedBox(height: 20),
        if (content != null || listContent != null)
          Center(
            child: TextButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Regenerate'),
              style: TextButton.styleFrom(foregroundColor: AppColors.slate500),
            ),
          ),
      ],
    );
  }

  Widget _buildResultCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(content,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.slate800,
                  height: 1.6,
                  fontFamily: 'monospace')),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              flutter_services.Clipboard.setData(
                  flutter_services.ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard!')));
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy to Clipboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
