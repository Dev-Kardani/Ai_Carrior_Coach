import 'package:ai_career_coach/core/theme/app_theme.dart';
import 'package:ai_career_coach/features/auth/screens/forgot_password_screen.dart';
import 'package:ai_career_coach/features/auth/screens/login_screen.dart';
import 'package:ai_career_coach/features/auth/screens/signup_screen.dart';
import 'package:ai_career_coach/features/auth/screens/splash_screen.dart';
import 'package:ai_career_coach/features/auth/screens/update_password_screen.dart';
import 'package:ai_career_coach/features/chat/screens/chat_screen.dart';
import 'package:ai_career_coach/features/dashboard/screens/dashboard_screen.dart';
import 'package:ai_career_coach/features/interview/screens/interview_feedback_screen.dart';
import 'package:ai_career_coach/features/interview/screens/interview_setup_screen.dart';
import 'package:ai_career_coach/features/interview/screens/mock_interview_screen.dart';
import 'package:ai_career_coach/features/onboarding/screens/profile_setup_screen.dart';
import 'package:ai_career_coach/features/resume/screens/resume_upload_screen.dart';
import 'package:ai_career_coach/features/skill_gap/screens/skill_gap_screen.dart';
import 'package:ai_career_coach/features/tools/screens/job_role_detail_screen.dart';
import 'package:ai_career_coach/features/tools/screens/tools_screens.dart';
import 'package:ai_career_coach/features/tracker/screens/job_detail_screen.dart';
import 'package:ai_career_coach/features/tracker/screens/job_entry_screen.dart';
import 'package:ai_career_coach/features/tracker/screens/job_tracker_screen.dart';
import 'package:ai_career_coach/models/interview_model.dart';
import 'package:ai_career_coach/models/job_application_model.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/storage_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize services
  final supabaseService = SupabaseService();
  final geminiService = GeminiService();
  final storageService = StorageService();

  // Initialize Supabase with auto-refresh disabled
  await supabaseService.initialize(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_ANON_KEY']!,
    disableAutoRefresh: true,
  );

  geminiService.initialize(dotenv.env['GEMINI_API_KEY'] ?? '');
  await storageService.initialize();

  // Setup global auth listener
  supabaseService.setupAuthListener((event, session) {
    if (event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/auth/login', (route) => false);
    } else if (event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/auth/update-password', (route) => false);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = StorageService().getThemeMode();

    return MaterialApp(
      title: 'AI Career Coach',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/app/interview/active') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MockInterviewScreen(
              role: args['role'] as String,
              questions: args['questions'] as List<InterviewQuestion>,
            ),
          );
        }
        if (settings.name == '/app/interview/feedback') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => InterviewFeedbackScreen(
              role: args['role'] as String,
              questions: args['questions'] as List<InterviewQuestion>,
              feedbacks: args['feedbacks'] as List<InterviewFeedback>,
            ),
          );
        }

        // Dynamic Job Routes
        if (settings.name != null && settings.name!.startsWith('/app/jobs/')) {
          if (settings.name == '/app/jobs/new') {
            return MaterialPageRoute(
              builder: (context) => const JobEntryScreen(),
            );
          }
          final segments = settings.name!.split('/');
          if (segments.length >= 4) {
            final job = settings.arguments as JobApplicationModel?;

            if (segments.length == 5 && segments[4] == 'edit') {
              // /app/jobs/:id/edit
              return MaterialPageRoute(
                builder: (context) => JobEntryScreen(job: job),
              );
            }
            if (segments.length == 4) {
              // /app/jobs/:id
              return MaterialPageRoute(
                builder: (context) => JobDetailScreen(job: job!),
              );
            }
          }
        }

        // Dynamic Chat Routes
        if (settings.name != null && settings.name!.startsWith('/app/chat/')) {
          final segments = settings.name!.split('/');
          if (segments.length == 4) {
            final topicId = segments[3] == 'new' ? null : segments[3];
            return MaterialPageRoute(
              builder: (context) => ChatScreen(initialTopicId: topicId),
            );
          }
        }

        // Market Insight Detail
        if (settings.name == '/app/tools/market-insights/detail') {
          final roleName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => JobRoleDetailScreen(roleName: roleName),
          );
        }

        return null;
      },
      routes: {
        // Module 1: Auth
        '/': (context) => const SplashScreen(),
        '/auth/login': (context) => const LoginScreen(),
        '/auth/signup': (context) => const SignupScreen(),
        '/auth/forgot-password': (context) => const ForgotPasswordScreen(),
        '/auth/update-password': (context) => const UpdatePasswordScreen(),
        '/auth/setup': (context) => const ProfileSetupScreen(),

        // Module 2: Dashboard Layout
        '/app': (context) => const DashboardScreen(),

        // Module 3: Resume Pipeline
        '/app/resume/upload': (context) => const ResumeUploadScreen(),
        '/app/resume/skills': (context) => const SkillGapScreen(),

        // Module 4: Interview System
        '/app/interview/setup': (context) => const InterviewSetupScreen(),
        // '/app/interview/active' & '/app/interview/feedback' handled in onGenerateRoute

        // Module 5: Jobs Tracker
        '/app/jobs': (context) => const JobTrackerScreen(),
        // '/app/jobs/new' handled in onGenerateRoute

        // Module 6: Chat
        '/app/chat': (context) => const ChatScreen(),

        // Module 7: Tools
        '/app/tools': (context) => const ToolsHubScreen(),
        '/app/tools/cover-letter': (context) => const CoverLetterScreen(),
        '/app/tools/networking': (context) => const NetworkingScreen(),
        '/app/tools/portfolio': (context) => const PortfolioScreen(),
        '/app/tools/salary': (context) => const SalaryNegotiationScreen(),
        '/app/tools/market-insights': (context) =>
            const IndustryInsightsScreen(),
        '/app/tools/job-matcher': (context) => const JobMatcherScreen(),
        '/app/tools/follow-up': (context) => const FollowUpSetupScreen(),
      },
    );
  }
}
