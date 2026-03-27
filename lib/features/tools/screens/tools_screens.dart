import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

export 'cover_letter_screen.dart';
export 'industry_insights_screen.dart';
export 'networking_screen.dart';
export 'portfolio_screen.dart';
export 'salary_negotiation_screen.dart';
export 'tools_hub_screen.dart';

/// Generic coming-soon stub used for genuinely unimplemented features.
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ComingSoonScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

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
        title: Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.slate100),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900)),
              const SizedBox(height: 8),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.slate500)),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Coming Soon',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobMatcherScreen extends StatelessWidget {
  const JobMatcherScreen({super.key});
  @override
  Widget build(BuildContext context) => const _ComingSoonScreen(
        title: 'Job Matcher',
        subtitle: 'Instantly check how well your resume matches any JD.',
        icon: Icons.fact_check_outlined,
      );
}

class FollowUpSetupScreen extends StatelessWidget {
  const FollowUpSetupScreen({super.key});
  @override
  Widget build(BuildContext context) => const _ComingSoonScreen(
        title: 'Follow-up Email',
        subtitle: 'Perfect follow-up messages for after your interview.',
        icon: Icons.mark_email_read_outlined,
      );
}

class RoadmapSetupScreen extends StatelessWidget {
  const RoadmapSetupScreen({super.key});
  @override
  Widget build(BuildContext context) => const _ComingSoonScreen(
        title: 'Career Roadmap',
        subtitle: 'Map your path forward with AI-curated career milestones.',
        icon: Icons.map_outlined,
      );
}
