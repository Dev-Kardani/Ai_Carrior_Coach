/// App-wide constants
class AppConstants {
  // App info
  static const String appName = 'AI Career Coach';
  static const String appVersion = '1.0.0';
  
  // Supabase storage
  static const String resumesBucket = 'resumes';
  static const int maxResumeFileSizeMB = 5;
  
  // Career roles for skill gap analysis
  static const List<String> careerRoles = [
    'Flutter Developer',
    'Data Analyst',
    'Backend Developer',
    'Frontend Developer',
    'Full Stack Developer',
    'Mobile Developer',
    'DevOps Engineer',
    'Data Scientist',
    'Machine Learning Engineer',
    'UI/UX Designer',
  ];
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // API limits (for free tier safety)
  static const int geminiMaxRequestsPerMinute = 60;
  static const int chatHistoryMaxMessages = 50;
  
  // Local storage keys
  static const String chatHistoryKey = 'chat_history';
  static const String themeKey = 'theme_mode';
}
