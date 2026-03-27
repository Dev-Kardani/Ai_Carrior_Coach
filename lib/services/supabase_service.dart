import 'dart:typed_data';

import 'package:ai_career_coach/core/constants/app_constants.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/models/analysis_model.dart';
import 'package:ai_career_coach/models/chat_message_model.dart';
import 'package:ai_career_coach/models/job_application_model.dart';
import 'package:ai_career_coach/models/resume_model.dart';
import 'package:ai_career_coach/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Supabase service for authentication, database, and storage operations
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  final _uuid = const Uuid();

  /// Initialize Supabase client
  Future<void> initialize(
    String url,
    String anonKey, {
    bool disableAutoRefresh = false,
  }) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: disableAutoRefresh
            ? const FlutterAuthClientOptions(autoRefreshToken: false)
            : const FlutterAuthClientOptions(),
      );
    } catch (e) {
      // Handle non-critical initialization errors like expired sessions
      DebugLogger.warning(
          'SUPABASE', 'INITIALIZE', 'Supabase initialization warning: $e');
    }
    _client = Supabase.instance.client;
  }

  /// Get current Supabase client
  SupabaseClient get client => _client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current user ID
  String? get userId => currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Setup authentication state listener
  void setupAuthListener(
      Function(AuthChangeEvent event, Session? session) onEvent) {
    _client.auth.onAuthStateChange.listen((data) {
      onEvent(data.event, data.session);
    });
  }

  // ==================== AUTHENTICATION ====================

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      DebugLogger.info('SUPABASE', 'signUp', 'Initializing sign up for email');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      // Create user profile in database
      if (response.user != null) {
        await _client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      DebugLogger.success('SUPABASE', 'signUp');
      return response;
    } catch (e) {
      DebugLogger.failed('SUPABASE', 'signUp', e.toString(), error: e);
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      DebugLogger.info('SUPABASE', 'signIn', 'Initializing sign in for email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      DebugLogger.success('SUPABASE', 'signIn');
      return response;
    } catch (e) {
      DebugLogger.failed('SUPABASE', 'signIn', e.toString(), error: e);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      DebugLogger.failed('SUPABASE', 'Could not sign out', e.toString());
      throw 'Failed to sign out. Please try again.';
    }
  }

  /// Send password reset email
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'ai-career-coach://reset-password',
      );
    } on AuthException catch (e) {
      DebugLogger.failed(
          'SUPABASE', 'Auth Exception (reset_password)', e.message);
      throw e.message;
    } catch (e) {
      DebugLogger.failed(
          'SUPABASE', 'Could not send reset password email', e.toString());
      throw 'Failed to send reset email. Please try again.';
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      DebugLogger.failed(
          'SUPABASE', 'Auth Exception (update_password)', e.message);
      throw e.message;
    } catch (e) {
      DebugLogger.failed('SUPABASE', 'Could not update password', e.toString());
      throw 'Failed to update password. Please try again.';
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return null;

      final response =
          await _client.from('users').select().eq('id', userId).single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? targetRole,
    String? experienceLevel,
    int? yearsExperience,
    String? bio,
    String? careerGoals,
    List<String>? preferredCountries,
    bool? onboardingCompleted,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (targetRole != null) data['target_role'] = targetRole;
      if (experienceLevel != null) data['experience_level'] = experienceLevel;
      if (yearsExperience != null) data['years_experience'] = yearsExperience;
      if (bio != null) data['bio'] = bio;
      if (careerGoals != null) data['career_goals'] = careerGoals;
      if (preferredCountries != null) {
        data['preferred_countries'] = preferredCountries;
      }
      if (onboardingCompleted != null) {
        data['onboarding_completed'] = onboardingCompleted;
      }

      if (data.isEmpty) return;

      data['id'] = userId;
      data['email'] =
          currentUser?.email; // Include email for upsert not-null constraint
      await _client.from('users').upsert(data);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== RESUME OPERATIONS ====================

  /// Upload resume PDF bytes to storage
  Future<String> uploadResume(Uint8List bytes, String fileName) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Create unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$userId/$timestamp-$fileName';

      // Upload to Supabase storage
      DebugLogger.info(
          'SUPABASE', 'uploadResume', 'Uploading resume to storage: $filePath');
      await _client.storage
          .from(AppConstants.resumesBucket)
          .uploadBinary(filePath, bytes);
      DebugLogger.success(
          'SUPABASE', 'uploadResume', 'Resume upload to storage successful');

      return filePath;
    } catch (e) {
      DebugLogger.failed('SUPABASE', 'uploadResume', e.toString(), error: e);
      rethrow;
    }
  }

  /// Save resume metadata to database
  Future<ResumeModel> saveResumeData({
    required String fileName,
    required String filePath,
    required String extractedText,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final resumeId = _uuid.v4();
      final data = {
        'id': resumeId,
        'user_id': userId,
        'file_name': fileName,
        'file_path': filePath,
        'extracted_text': extractedText,
        'uploaded_at': DateTime.now().toIso8601String(),
      };

      DebugLogger.info('SUPABASE', 'saveResumeData',
          'Saving resume metadata to database: $fileName');
      await _client.from('resumes').insert(data);
      DebugLogger.success(
          'SUPABASE', 'saveResumeData', 'Resume metadata saved successfully');

      return ResumeModel.fromJson(data);
    } catch (e) {
      DebugLogger.failed(
          'SUPABASE', 'saveResumeData', 'Failed to save resume metadata: $e',
          error: e);
      rethrow;
    }
  }

  /// Get user's resumes
  Future<List<ResumeModel>> getUserResumes() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('resumes')
          .select()
          .eq('user_id', userId)
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((json) => ResumeModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get latest resume
  Future<ResumeModel?> getLatestResume() async {
    try {
      final resumes = await getUserResumes();
      return resumes.isNotEmpty ? resumes.first : null;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ANALYSIS OPERATIONS ====================

  /// Save AI analysis result
  Future<AnalysisModel> saveAnalysisResult({
    required String resumeId,
    required int score,
    required List<String> strengths,
    required List<String> weaknesses,
    required String atsCompatibility,
    String? atsTips,
    required List<String> suggestions,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final analysisId = _uuid.v4();
      final data = {
        'id': analysisId,
        'resume_id': resumeId,
        'user_id': userId,
        'score': score,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'ats_compatibility': atsCompatibility,
        'ats_tips': atsTips,
        'suggestions': suggestions,
        'created_at': DateTime.now().toIso8601String(),
      };

      DebugLogger.info('SUPABASE', 'saveAnalysisResult',
          'Saving AI analysis result for resume: $resumeId');
      await _client.from('ai_results').insert(data);
      DebugLogger.success('SUPABASE', 'saveAnalysisResult',
          'AI analysis result saved successfully');

      return AnalysisModel.fromJson(data);
    } catch (e) {
      DebugLogger.failed('SUPABASE', 'saveAnalysisResult',
          'Failed to save AI analysis result: $e',
          error: e);
      rethrow;
    }
  }

  /// Get latest analysis
  Future<AnalysisModel?> getLatestAnalysis() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('ai_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      return AnalysisModel.fromJson(response.first);
    } catch (e) {
      rethrow;
    }
  }

  /// Get analysis by resume ID
  Future<AnalysisModel?> getAnalysisByResumeId(String resumeId) async {
    try {
      final response = await _client
          .from('ai_results')
          .select()
          .eq('resume_id', resumeId)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      return AnalysisModel.fromJson(response.first);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== JOB TRACKER OPERATIONS ====================

  /// Get user's job applications
  Future<List<JobApplicationModel>> getJobApplications() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('job_applications')
          .select()
          .eq('user_id', userId)
          .order('applied_at', ascending: false);

      return (response as List)
          .map((json) => JobApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Add a new job application
  Future<JobApplicationModel> addJobApplication({
    required String companyName,
    required String roleTitle,
    String status = 'Applied',
    String? location,
    String? salaryRange,
    String? notes,
    String? jobUrl,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final data = {
        'id': _uuid.v4(),
        'user_id': userId,
        'company_name': companyName,
        'role_title': roleTitle,
        'status': status,
        'location': location,
        'salary_range': salaryRange,
        'applied_at': DateTime.now().toIso8601String(),
        'notes': notes,
        'job_url': jobUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client.from('job_applications').insert(data);

      return JobApplicationModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update job application status
  Future<void> updateJobApplicationStatus(String id, String newStatus) async {
    try {
      await _client
          .from('job_applications')
          .update({'status': newStatus}).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  /// Update job application details
  Future<void> updateJobApplication({
    required String id,
    String? companyName,
    String? roleTitle,
    String? status,
    String? location,
    String? salaryRange,
    String? notes,
    String? jobUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (companyName != null) data['company_name'] = companyName;
      if (roleTitle != null) data['role_title'] = roleTitle;
      if (status != null) data['status'] = status;
      if (location != null) data['location'] = location;
      if (salaryRange != null) data['salary_range'] = salaryRange;
      if (notes != null) data['notes'] = notes;
      if (jobUrl != null) data['job_url'] = jobUrl;

      if (data.isEmpty) return;

      await _client.from('job_applications').update(data).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete job application
  Future<void> deleteJobApplication(String id) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('job_applications')
          .delete()
          .eq('id', id)
          .eq('user_id', userId)
          .select();

      if (response.isEmpty) {
        DebugLogger.failed('SUPABASE_SERVICE', 'DELETE_JOB_FAIL',
            'No rows deleted. Check RLS policies.');
      } else {
        DebugLogger.success('SUPABASE_SERVICE', 'DELETE_JOB_SUCCESS',
            'Deleted ${response.length} rows');
      }
    } catch (e) {
      DebugLogger.failed(
          'SUPABASE_SERVICE', 'DELETE_JOB_EXCEPTION', e.toString());
      rethrow;
    }
  }

  // ==================== CHAT OPERATIONS ====================

  /// Get user's chat topics
  Future<List<Map<String, dynamic>>> getChatTopics() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      return await _client
          .from('chat_topics')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
    } catch (e) {
      return [];
    }
  }

  /// Create a new chat topic
  Future<Map<String, dynamic>> createChatTopic(String title) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final data = {
        'id': _uuid.v4(),
        'user_id': userId,
        'title': title,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client.from('chat_topics').insert(data);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a chat topic
  Future<void> deleteChatTopic(String topicId) async {
    try {
      await _client.from('chat_topics').delete().eq('id', topicId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get messages for a topic
  Future<List<ChatMessage>> getChatMessages(String topicId) async {
    try {
      final response = await _client
          .from('chat_messages')
          .select()
          .eq('topic_id', topicId)
          .order('timestamp', ascending: true);

      return (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save a chat message
  Future<ChatMessage> saveChatMessage({
    required String topicId,
    required String text,
    required bool isUser,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final data = {
        'id': _uuid.v4(),
        'topic_id': topicId,
        'user_id': userId,
        'text': text,
        'is_user': isUser,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _client.from('chat_messages').insert(data);
      return ChatMessage.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
