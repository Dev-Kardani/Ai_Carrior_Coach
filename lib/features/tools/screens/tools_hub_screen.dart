import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // Slate 50
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (MediaQuery.of(context).size.width > 768) ...[
                  const Text(
                    'Career Tools',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  const Text(
                    'AI-powered generators and utilities to accelerate your job search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 32),
                ],

                // Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -40,
                        top: -40,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'AI-Powered Career Toolkit',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Each tool uses AI to generate professional content tailored to your profile and target roles. Save hours of manual work and stand out from the competition.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Tools Grid
                LayoutBuilder(builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 600;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isSmall ? 1 : 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: isSmall
                        ? 1.6 // More height for mobile cards
                        : 1.3,
                    children: [
                      _buildToolCard(
                        context,
                        title: 'Cover Letter Generator',
                        description:
                            'Create tailored cover letters from job descriptions with AI.',
                        icon: Icons.description_rounded,
                        bgColor: const Color(0xFFDBEAFE),
                        iconColor: const Color(0xFF2563EB),
                        route: '/app/tools/cover-letter',
                        index: 0,
                      ),
                      _buildToolCard(
                        context,
                        title: 'Networking Message',
                        description:
                            'Draft professional LinkedIn messages for cold outreach.',
                        icon: Icons.people_rounded,
                        bgColor: const Color(0xFFDCFCE7),
                        iconColor: const Color(0xFF16A34A),
                        route: '/app/tools/networking',
                        index: 1,
                      ),
                      _buildToolCard(
                        context,
                        title: 'Portfolio Architect',
                        description:
                            'Organize and showcase your best projects strategically.',
                        icon: Icons.palette_rounded,
                        bgColor: const Color(0xFFF3E8FF),
                        iconColor: const Color(0xFF9333EA),
                        route: '/app/tools/portfolio',
                        index: 2,
                      ),
                      _buildToolCard(
                        context,
                        title: 'Salary Negotiator',
                        description:
                            'Get market data and negotiation scripts for your role.',
                        icon: Icons.payments_rounded,
                        bgColor: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                        route: '/app/tools/salary',
                        index: 3,
                      ),
                      _buildToolCard(
                        context,
                        title: 'Market Insights',
                        description:
                            'Explore real-time trends, demand, and hiring activity.',
                        icon: Icons.trending_up_rounded,
                        bgColor: const Color(0xFFE0E7FF),
                        iconColor: const Color(0xFF4F46E5),
                        route: '/app/tools/market-insights',
                        index: 4,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String route,
    required int index,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          DebugLogger.info('TOOLS_HUB_UI', 'ROUTING', 'Navigating to $route');
          Navigator.of(context, rootNavigator: true).pushNamed(route);
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8), size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (400 + index * 80).ms).slideY(begin: 0.1, end: 0);
  }
}
