import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    DebugLogger.info('AUTH_UI', 'SPLASH_INITIALIZED');

    // Minimum splash duration
    final splashTimer = Future.delayed(const Duration(milliseconds: 2500));

    // Check auth status
    final supabaseService = SupabaseService();
    final bool isAuthenticated = supabaseService.isAuthenticated;

    await splashTimer;

    if (mounted) {
      if (isAuthenticated) {
        final profile = await supabaseService.getUserProfile();
        if (mounted) {
          if (profile != null && profile.onboardingCompleted) {
            DebugLogger.success('AUTH_UI', 'ROUTING',
                'User authenticated and onboarded, navigating to app');
            Navigator.of(context).pushReplacementNamed('/app');
          } else {
            DebugLogger.success('AUTH_UI', 'ROUTING',
                'User authenticated but needs onboarding, navigating to setup');
            Navigator.of(context).pushReplacementNamed('/auth/setup');
          }
        }
      } else {
        DebugLogger.success('AUTH_UI', 'ROUTING',
            'User not authenticated, navigating to login');
        Navigator.of(context).pushReplacementNamed('/auth/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5), // Indigo 600
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: CustomPaint(
                painter: DotPatternPainter(),
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.work_rounded,
                      size: 48,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                    )
                    .fadeIn(duration: 800.ms),

                const SizedBox(height: 24),

                // Title
                Text(
                  'CareerAI',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate(delay: 300.ms)
                    .moveY(
                        begin: 20,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOut)
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Your personal career co-pilot',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: const Color(0xFFC7D2FE), // Indigo 200
                  ),
                )
                    .animate(delay: 500.ms)
                    .moveY(
                        begin: 20,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOut)
                    .fadeIn(duration: 500.ms),
              ],
            ),
          ),

          // Progress Bar at Bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ).animate().custom(
                          duration: 2000.ms,
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Container(
                              width: 48 * value,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ).animate(delay: 1000.ms).fadeIn(duration: 1000.ms),
          ),
        ],
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
