import 'dart:math' as math;
import 'dart:ui';

import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/features/chat/screens/chat_screen.dart';
import 'package:ai_career_coach/features/interview/screens/interview_setup_screen.dart';
import 'package:ai_career_coach/features/resume/screens/resume_analysis_screen.dart';
import 'package:ai_career_coach/features/resume/screens/resume_upload_screen.dart';
import 'package:ai_career_coach/features/skill_gap/screens/skill_gap_screen.dart';
import 'package:ai_career_coach/features/tools/screens/tools_hub_screen.dart';
import 'package:ai_career_coach/features/tools/screens/tools_screens.dart';
import 'package:ai_career_coach/features/tracker/screens/job_tracker_screen.dart';
import 'package:ai_career_coach/models/analysis_model.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabaseService = SupabaseService();
  AnalysisModel? _latestAnalysis;
  int _selectedIndex = 0;
  bool _isMobileSidebarOpen = false;
  int _activeApplicationsCount = 0;
  String _targetRole = 'Product Designer';

  // Global Keys for Nested Navigators
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Nav indices: 0=Dashboard, 1=Resume, 2=Jobs, 3=Interview, 4=Chat, 5=Tools
  static const _navItems = [
    {'label': 'Dashboard', 'icon': Icons.dashboard_rounded},
    {'label': 'Resume', 'icon': Icons.description_rounded},
    {'label': 'Jobs', 'icon': Icons.work_rounded},
    {'label': 'Interview', 'icon': Icons.videocam_rounded},
    {'label': 'Chat', 'icon': Icons.chat_bubble_rounded},
    {'label': 'Tools', 'icon': Icons.build_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadLatestAnalysis();
  }

  Future<void> _loadLatestAnalysis() async {
    try {
      final analysis = await _supabaseService.getLatestAnalysis();
      final jobs = await _supabaseService.getJobApplications();
      final resume = await _supabaseService.getLatestResume();

      DebugLogger.info(
          'ATS_DEBUG', 'LOAD', 'Analysis found: ${analysis != null}');
      if (analysis != null) {
        DebugLogger.info(
            'ATS_DEBUG', 'SCORE', 'Score from DB: ${analysis.score}');
      }

      if (mounted) {
        setState(() {
          _latestAnalysis = analysis;
          _activeApplicationsCount = jobs
              .where((j) => j.status == 'Applied' || j.status == 'Interviewing')
              .length;
          if (resume != null) {
            // Primitive extraction or just use a default
            _targetRole = resume.extractedText.length > 20
                ? 'Professional' // Placeholder logic
                : 'Product Designer';
          }
        });
      }
    } catch (e) {
      DebugLogger.failed('ATS_DEBUG', 'LOAD_ERROR', e.toString());
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign out?',
            style: TextStyle(
                color: AppColors.slate900, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.slate600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.slate600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      DebugLogger.info('DASHBOARD_UI', 'LOGOUT_CLICKED');
      await _supabaseService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          final isFirstRouteInCurrentTab =
              !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
          if (isFirstRouteInCurrentTab) {
            if (_selectedIndex != 0) {
              setState(() => _selectedIndex = 0);
            }
          }
        },
        child: Stack(
          children: [
            Row(
              children: [
                if (isWide) _buildSidebar(),
                Expanded(
                  child: _buildPageContent(),
                ),
              ],
            ),
            // Mobile sidebar overlay
            if (!isWide && _isMobileSidebarOpen)
              GestureDetector(
                onTap: () => setState(() => _isMobileSidebarOpen = false),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ).animate().fadeIn(),
            if (!isWide && _isMobileSidebarOpen)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _buildSidebar(),
              ).animate().slideX(
                  begin: -1, end: 0, duration: 300.ms, curve: Curves.easeInOut),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final userName = _supabaseService.currentUser?.userMetadata?['full_name'] ??
        'Alex Morgan';
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(right: BorderSide(color: Color(0xFFE2E8F0))), // Slate 200
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.work_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'CareerAI',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                if (MediaQuery.of(context).size.width <= 768)
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () =>
                        setState(() => _isMobileSidebarOpen = false),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)), // Slate 100

          // Nav Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _navItems.asMap().entries.map((e) {
                  final i = e.key;
                  final item = e.value;
                  return _buildNavItem(
                    i,
                    item['icon'] as IconData,
                    item['label'] as String,
                    key: ValueKey(
                        'nav_item_${item['label'].toString().toLowerCase()}'),
                  );
                }).toList(),
              ),
            ),
          ),

          // User Profile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9))), // Slate 100
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFFE2E8F0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF0F172A), // Slate 900
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Pro Plan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B), // Slate 500
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      size: 18, color: Color(0xFF94A3B8)),
                  onPressed: _handleLogout,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {Key? key}) {
    final isActive = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        key: key,
        onTap: () {
          DebugLogger.info(
              'DASHBOARD_UI', 'NAV_ITEM_CLICKED', 'Tapped on $label tab');
          if (_selectedIndex == index) {
            // Pop to first route if tapping the active tab again
            _navigatorKeys[index]
                .currentState
                ?.popUntil((route) => route.isFirst);
          } else {
            setState(() {
              _selectedIndex = index;
              _isMobileSidebarOpen = false;
            });
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: isActive ? AppColors.primary : AppColors.slate400),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isActive ? const Color(0xFF3730A3) : AppColors.slate600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    // Mobile top bar
    return Column(
      children: [
        if (MediaQuery.of(context).size.width <= 768)
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                8, MediaQuery.of(context).padding.top + 8, 16, 12),
            child: Row(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.menu_rounded, color: AppColors.slate600),
                  onPressed: () => setState(() => _isMobileSidebarOpen = true),
                ),
                Expanded(
                  child: Text(_navItems[_selectedIndex]['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900)),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: MediaQuery.of(context).size.width <= 768,
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildNavigator(0, _buildDashboardHome()),
                _buildNavigator(1, _buildResumeHub()),
                _buildNavigator(2, const JobTrackerScreen()),
                _buildNavigator(3, const InterviewSetupScreen()),
                _buildNavigator(4, const ChatScreen()),
                _buildNavigator(5, const ToolsHubScreen()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigator(int index, Widget initialChild) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => initialChild,
        );
      },
    );
  }

  // ─── Dashboard Home ───────────────────────────────────────────────────────

  Widget _buildDashboardHome() {
    final firstName = _supabaseService.currentUser?.userMetadata?['full_name']
            ?.split(' ')
            .first ??
        'Alex';

    final modules = [
      {
        'title': 'Resume Analysis',
        'icon': Icons.description_rounded,
        'color': const Color(0xFFEFF6FF), // blue-50
        'iconColor': const Color(0xFF2563EB), // blue-600
        'desc': 'Get AI feedback on your CV',
        'action': () {
          DebugLogger.info('DASHBOARD_UI', 'MODULE_CLICKED', 'Resume Analysis');
          setState(() => _selectedIndex = 1);
        },
      },
      {
        'title': 'Skill Gap',
        'icon': Icons.track_changes_rounded,
        'color': const Color(0xFFFAF5FF), // purple-50
        'iconColor': const Color(0xFF9333EA), // purple-600
        'desc': 'Identify missing skills',
        'action': () {
          DebugLogger.info('DASHBOARD_UI', 'MODULE_CLICKED', 'Skill Gap');
          setState(() => _selectedIndex = 1); // Resume Module
          _navigatorKeys[1].currentState?.popUntil((route) => route.isFirst);
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const SkillGapScreen()),
          );
        },
      },
      {
        'title': 'Mock Interview',
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFFF0FDF4), // green-50
        'iconColor': const Color(0xFF16A34A), // green-600
        'desc': 'Practice with AI avatar',
        'action': () {
          DebugLogger.info('DASHBOARD_UI', 'MODULE_CLICKED', 'Mock Interview');
          setState(() => _selectedIndex = 3);
        },
      },
      {
        'title': 'Job Tracker',
        'icon': Icons.work_rounded,
        'color': const Color(0xFFFFF7ED), // orange-50
        'iconColor': const Color(0xFFEA580C), // orange-600
        'desc': 'Manage your applications',
        'action': () {
          DebugLogger.info('DASHBOARD_UI', 'MODULE_CLICKED', 'Job Tracker');
          setState(() => _selectedIndex = 2);
        },
      },
      {
        'title': 'AI Career Chat',
        'icon': Icons.chat_bubble_rounded,
        'color': const Color(0xFFEEF2FF), // indigo-50
        'iconColor': const Color(0xFF4F46E5), // indigo-600
        'desc': 'Get instant career advice',
        'action': () {
          DebugLogger.info('DASHBOARD_UI', 'MODULE_CLICKED', 'AI Career Chat');
          setState(() => _selectedIndex = 4);
        },
      },
      {
        'title': 'Career Tools',
        'icon': Icons.build_rounded,
        'color': const Color(0xFFFFF1F2), // rose-50
        'iconColor': const Color(0xFFE11D48), // rose-600
        'desc': 'Generators & utilities',
        'action': () {
          DebugLogger.info('DASHBOARD_UI', 'MODULE_CLICKED', 'Career Tools');
          setState(() => _selectedIndex = 5);
        },
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Hello, $firstName! 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A), // Slate 900
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 4),
              const Text(
                'Ready to boost your career today?',
                style: TextStyle(
                  color: Color(0xFF64748B), // Slate 500
                  fontSize: 16,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),

              // ATS Score Hero
              _buildATSScoreCard()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Quick Stats
              LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 640;
                return Column(
                  children: [
                    if (isWide)
                      Row(
                        children: [
                          Expanded(
                            child: _buildAlertCard(
                              icon: Icons.error_outline_rounded,
                              iconColor: const Color(0xFFEA580C),
                              iconBg: const Color(0xFFFFEDD5),
                              bg: const Color(0xFFFFF7ED),
                              border: const Color(0xFFFED7AA),
                              title: 'Action Required',
                              titleColor: const Color(0xFF7C2D12),
                              subtitle: _activeApplicationsCount > 0
                                  ? '$_activeApplicationsCount active applications need follow-up.'
                                  : 'No active applications. Start applying!',
                              subtitleColor: const Color(0xFF94A3B8),
                              onTap: () {
                                DebugLogger.info('DASHBOARD_UI',
                                    'ALERT_CLICKED', 'Action Required');
                                setState(
                                    () => _selectedIndex = 2); // Jump to Jobs
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAlertCard(
                              icon: Icons.trending_up_rounded,
                              iconColor: const Color(0xFF16A34A),
                              iconBg: const Color(0xFFDCFCE7),
                              bg: const Color(0xFFF0FDF4),
                              border: const Color(0xFFBBF7D0),
                              title: 'Market Insight',
                              titleColor: const Color(0xFF14532D),
                              subtitle:
                                  '$_targetRole roles are in high demand this week.',
                              subtitleColor: const Color(0xFF166534),
                              onTap: () {
                                DebugLogger.info('DASHBOARD_UI',
                                    'ALERT_CLICKED', 'Market Insight');
                                Navigator.of(context, rootNavigator: true)
                                    .pushNamed('/app/tools/market-insights');
                              },
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildAlertCard(
                        icon: Icons.error_outline_rounded,
                        iconColor: const Color(0xFFEA580C),
                        iconBg: const Color(0xFFFFEDD5),
                        bg: const Color(0xFFFFF7ED),
                        border: const Color(0xFFFED7AA),
                        title: 'Action Required',
                        titleColor: const Color(0xFF7C2D12),
                        subtitle: _activeApplicationsCount > 0
                            ? '$_activeApplicationsCount active applications need follow-up.'
                            : 'No active applications. Start applying!',
                        subtitleColor: const Color(0xFF9A3412),
                        onTap: () {
                          DebugLogger.info('DASHBOARD_UI', 'ALERT_CLICKED',
                              'Action Required');
                          setState(() => _selectedIndex = 2); // Jump to Jobs
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAlertCard(
                        icon: Icons.trending_up_rounded,
                        iconColor: const Color(0xFF16A34A),
                        iconBg: const Color(0xFFDCFCE7),
                        bg: const Color(0xFFF0FDF4),
                        border: const Color(0xFFBBF7D0),
                        title: 'Market Insight',
                        titleColor: const Color(0xFF14532D),
                        subtitle:
                            '$_targetRole roles are in high demand this week.',
                        subtitleColor: const Color(0xFF166534),
                        onTap: () {
                          DebugLogger.info('DASHBOARD_UI', 'ALERT_CLICKED',
                              'Market Insight');
                          Navigator.of(context, rootNavigator: true)
                              .pushNamed('/app/tools/market-insights');
                        },
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 32),

              // Quick Access Grid
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A), // Slate 900
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 16),

              LayoutBuilder(builder: (context, constraints) {
                int cols = 2;
                double aspectRatio = 1.35;
                if (constraints.maxWidth > 900) {
                  cols = 3;
                } else if (constraints.maxWidth < 600) {
                  cols =
                      2; // Keep 2 columns on mobile if possible, but adjust ratio
                  aspectRatio = 0.9;
                }

                if (constraints.maxWidth < 400) {
                  cols = 1;
                  aspectRatio = 2.5;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: modules.length,
                  itemBuilder: (context, i) {
                    final m = modules[i];
                    return _buildModuleCard(
                      key: ValueKey(
                          'dash_card_${m['title'].toString().toLowerCase().replaceAll(' ', '_')}'),
                      icon: m['icon'] as IconData,
                      title: m['title'] as String,
                      desc: m['desc'] as String,
                      iconColor: m['iconColor'] as Color,
                      iconBg: m['color'] as Color,
                      onTap: m['action'] as VoidCallback,
                    )
                        .animate()
                        .fadeIn(delay: (450 + i * 50).ms)
                        .scale(begin: const Offset(0.95, 0.95));
                  },
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildATSScoreCard() {
    final hasAnalysis = _latestAnalysis != null;
    final score = hasAnalysis ? _latestAnalysis!.score : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 550) {
          return Row(
            children: [
              _buildDonutChart(score, hasAnalysis),
              const SizedBox(width: 32),
              Expanded(child: _buildATSCardContent(score, hasAnalysis)),
            ],
          );
        }
        return Column(
          children: [
            SizedBox(
              height: 140, // Reduced height for mobile
              width: 140,
              child: _buildDonutChart(score, hasAnalysis),
            ),
            const SizedBox(height: 24),
            _buildATSCardContent(score, hasAnalysis),
          ],
        );
      }),
    );
  }

  Widget _buildDonutChart(int score, bool hasAnalysis) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _DonutPainter(score: score),
          ),
          Text(
            hasAnalysis ? '$score' : '--',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: hasAnalysis ? const Color(0xFF4F46E5) : AppColors.slate400,
            ),
          ),
          const Positioned(
            bottom: 40,
            child: Text(
              'ATS Score',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildATSCardContent(int score, bool hasAnalysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasAnalysis ? 'Your Resume is Strong! 🚀' : 'Upload Your Resume 📄',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasAnalysis
              ? "You're in the top 20% of candidates. Improve your impact metrics to reach 85+."
              : 'Get AI-powered feedback and an ATS compatibility score in minutes.',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: hasAnalysis
                  ? () {
                      final analysis = _latestAnalysis;
                      if (analysis != null) {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(
                          builder: (_) =>
                              ResumeAnalysisScreen(analysis: analysis),
                        ));
                      }
                    }
                  : () => Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(
                        builder: (_) => const ResumeUploadScreen(),
                      )),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                hasAnalysis ? 'View Analysis' : 'Upload Resume',
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
            if (hasAnalysis)
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ResumeUploadScreen(),
                )),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  backgroundColor: const Color(0xFFEEF2FF),
                  side: BorderSide.none,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Update Resume',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color bg,
    required Color border,
    required String title,
    required Color titleColor,
    required String subtitle,
    required Color subtitleColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    Key? key,
    required IconData icon,
    required String title,
    required String desc,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Resume Hub ───────────────────────────────────────────────────────────

  Widget _buildResumeHub() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.of(context).size.width > 768) ...[
            const Text('Resume',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900)),
            const SizedBox(height: 4),
            const Text('Upload, analyze, and improve your resume.',
                style: TextStyle(color: AppColors.slate400, fontSize: 15)),
            const SizedBox(height: 24),
          ],

          // Cards
          _buildResumeHubCard(
            icon: Icons.upload_file_rounded,
            iconBg: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF2563EB),
            title: 'Upload & Analyze Resume',
            desc: 'Get AI-powered ATS score and detailed feedback on your CV.',
            buttonLabel: 'Upload Resume',
            buttonKey: const ValueKey('hub_upload_resume_btn'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (_) => const ResumeUploadScreen()))
                .then((_) => _loadLatestAnalysis()),
          ),
          const SizedBox(height: 16),

          _buildResumeHubCard(
            icon: Icons.bar_chart_rounded,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: AppColors.primary,
            title: 'View Analysis Results',
            desc:
                'See strengths, weaknesses, and ATS compatibility of your resume.',
            buttonLabel: 'View Analysis',
            buttonKey: const ValueKey('hub_view_analysis_btn'),
            onTap: _latestAnalysis == null
                ? null
                : () async {
                    final analysis = _latestAnalysis;
                    if (analysis != null && mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              ResumeAnalysisScreen(analysis: analysis)));
                    }
                  },
            disabled: _latestAnalysis == null,
            disabledHint: 'Upload a resume first to unlock analysis',
          ),
          const SizedBox(height: 16),

          _buildResumeHubCard(
            icon: Icons.track_changes_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF9333EA),
            title: 'Skill Gap Analysis',
            desc:
                'Compare your current skills to industry targets and find what to learn.',
            buttonLabel: 'Analyze Skills',
            buttonKey: const ValueKey('hub_analyze_skills_btn'),
            onTap: _latestAnalysis == null
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SkillGapScreen())),
            disabled: _latestAnalysis == null,
            disabledHint: 'Upload a resume first to unlock skill gap analysis',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResumeHubCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String desc,
    required String buttonLabel,
    Key? buttonKey,
    required VoidCallback? onTap,
    bool disabled = false,
    String? disabledHint,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.slate900)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.slate500,
              height: 1.5,
            ),
          ),
          if (disabled && disabledHint != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // Orange 50
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 14, color: Color(0xFFEA580C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      disabledHint,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFC2410C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: buttonKey,
              onPressed: disabled ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.slate100,
                disabledForegroundColor: AppColors.slate400,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Donut Chart Painter ──────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final int score;

  _DonutPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;

    final basePaint = Paint()
      ..color = const Color(0xFFF1F5F9) // Slate 100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = const Color(0xFF4F46E5) // Indigo 600
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, basePaint);

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.score != score;
}
