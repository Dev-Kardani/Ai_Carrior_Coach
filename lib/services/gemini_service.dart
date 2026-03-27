import 'dart:convert';

import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/models/chat_message_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

/// Gemini AI Service leveraging official SDK for robust performance
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late GenerativeModel _model;
  late String _apiKey;

  // Rate limiting tracking
  DateTime _lastRequestTime = DateTime.now();
  int _requestCount = 0;
  static const int _maxRequestsPerMinute = 15;

  /// Initialize with Gemini API key and setup the model
  void initialize(String apiKey) {
    _apiKey = apiKey;
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: _apiKey,
      httpClient:
          http.Client(), // We could wrap this to add common headers if needed
    );
  }

  /// Internal helper that uses the SDK to generate content with rate limiting and retries
  Future<String> _callApi(String prompt, {int retryCount = 0}) async {
    DebugLogger.info('GEMINI', 'API_CALL',
        'Calling Gemini API (retry $retryCount) Prompt length: ${prompt.length}');
    try {
      await _checkRateLimit();

      final content = [Content.text(prompt)];

      // Use a timeout to prevent infinite hangs or sudden aborts
      final response = await _model
          .generateContent(content)
          .timeout(const Duration(seconds: 90));

      final text = response.text;
      if (text != null && text.isNotEmpty) {
        DebugLogger.success(
            'GEMINI', 'API_CALL', 'Received response length: ${text.length}');
        return text;
      }

      DebugLogger.failed('GEMINI', 'API_CALL', 'Empty response from AI');
      throw Exception('Empty response from AI.');
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      // Handle Rate Limit Exceeded (429)
      if (errorString.contains('429') ||
          errorString.contains('too many requests')) {
        if (retryCount < 3) {
          final delayInSeconds = (retryCount + 1) * 30;
          // Rate limit hit. Retrying...
          DebugLogger.warning('GEMINI', 'API_CALL',
              'Rate limit hit, retrying in $delayInSeconds seconds...');
          await Future.delayed(Duration(seconds: delayInSeconds));
          return _callApi(prompt, retryCount: retryCount + 1);
        }
        DebugLogger.failed(
            'GEMINI', 'API_CALL', 'Rate limit exceeded after retries');
        throw Exception(
            'Rate limit exceeded. Please wait a minute before trying again.');
      }

      // Handle Quota Exceeded (403)
      if (errorString.contains('403') ||
          errorString.contains('quota exceeded')) {
        DebugLogger.failed('GEMINI', 'API_CALL', 'Quota exceeded');
        throw Exception(
            'API Quota exceeded for today. Please try again tomorrow or use a different API key.');
      }

      // General error handling
      if (retryCount < 2 && !errorString.contains('403')) {
        // Subtle retry for intermittent networking issues
        DebugLogger.warning(
            'GEMINI', 'API_CALL', 'Intermittent error, subtle retry...');
        await Future.delayed(const Duration(seconds: 2));
        return _callApi(prompt, retryCount: retryCount + 1);
      }

      DebugLogger.failed(
          'GEMINI', 'API_CALL', 'Gemini Error: ${ErrorHandler.formatError(e)}',
          error: e);
      throw Exception('Gemini Error: ${ErrorHandler.formatError(e)}');
    }
  }

  /// Check and enforced rate limits
  Future<void> _checkRateLimit() async {
    final now = DateTime.now();
    final difference = now.difference(_lastRequestTime);

    if (difference.inMinutes >= 1) {
      _lastRequestTime = now;
      _requestCount = 1;
    } else {
      if (_requestCount >= _maxRequestsPerMinute) {
        final waitSeconds = 60 - difference.inSeconds;
        throw Exception(
            'Rate limit reached. Please wait $waitSeconds seconds.');
      }
      _requestCount++;
    }
  }

  // ==================== FEATURES ====================

  /// Analyze resume and return structured feedback
  Future<Map<String, dynamic>> analyzeResume(String resumeText) async {
    final prompt = '''
Analyze the following resume and provide detailed feedback.
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

Resume:
$resumeText

JSON Structure:
{
  "score": <integer 0-100>,
  "strengths": ["string", "string", "string"],
  "weaknesses": ["string", "string", "string"],
  "ats_compatibility": "brief evaluation string",
  "ats_tips": "CONCISE technical tips to improve ATS ranking (keywords, formatting, etc.)",
  "suggestions": ["specific improvement 1", "specific improvement 2", ...]
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }

  /// Analyze skill gap for a specific role
  Future<Map<String, dynamic>> analyzeSkillGap({
    required String role,
    required String resumeText,
  }) async {
    final prompt = '''
Compare this resume to the requirements for a $role position.
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

Resume:
$resumeText

JSON Structure:
{
  "competency_scores": [
    {"skill": "Skill Name", "current": 0-100, "target": 0-100},
    ...
  ],
  "missing_skills": [
    {"name": "skill name", "priority": "High/Medium/Low", "timeframe": "e.g. 2 weeks"},
    ...
  ],
  "learning_roadmap": [
    {
      "phase": "Phase Name (e.g. Phase 1: Foundations)",
      "items": [
        {"title": "course or project title", "type": "Course/Project", "duration": "e.g. 5h"}
      ]
    }
  ]
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }

  /// Send chat message and get AI response
  Future<String> sendChatMessage({
    required String message,
    List<ChatMessage>? history,
    String? resumeText,
  }) async {
    String context =
        'You are an expert career coach. Provide helpful, concise, and actionable career advice. ';

    if (resumeText != null && resumeText.isNotEmpty) {
      context += '\nThe user background (from resume) is: $resumeText\n';
    }

    if (history != null && history.isNotEmpty) {
      context += 'Previous conversation:\n';
      for (var msg in history.reversed.take(5).toList().reversed) {
        context += '${msg.isUser ? "User" : "Assistant"}: ${msg.text}\n';
      }
    }

    context += '\nUser: $message\nAssistant:';

    return await _callApi(context);
  }

  /// Generate career suggestions based on resume
  Future<List<String>> generateCareerSuggestions(String resumeText) async {
    final prompt = '''
Suggest 5 potential career paths based on this resume.
YOU MUST RESPOND WITH ONLY A VALID JSON ARRAY OF STRINGS.

Resume:
$resumeText

Example: ["Software Engineer", "Data Analyst", ...]
''';

    final responseText = await _callApi(prompt);
    final result = _extractJson(responseText);

    if (result is List) return result.map((e) => e.toString()).toList();
    return [];
  }

  /// NEW: Generate mock interview questions
  Future<List<Map<String, dynamic>>> generateInterviewQuestions({
    required String role,
    required String resumeText,
    String format = 'descriptive',
    bool useResume = false,
  }) async {
    final contextPrompt = useResume && resumeText.isNotEmpty
        ? 'Generate questions based on the candidate\'s resume provided below.'
        : 'Generate general technical and behavioral questions for this role. DO NOT reference any specific resume details.';

    final formatPrompt = format == 'mcq'
        ? 'Generate multiple choice questions (MCQs) with 4 options each.'
        : 'Generate descriptive questions.';

    final jsonSpec = format == 'mcq'
        ? '''
[
  {
    "question": "string",
    "options": ["option1", "option2", "option3", "option4"],
    "expected_answer": "the correct option string",
    "tip": "brief explanation why this is correct",
    "type": "mcq"
  }
]'''
        : '''
[
  {
    "question": "string",
    "expected_answer": "detailed sample answer",
    "tip": "brief tip on how to answer this",
    "type": "descriptive"
  }
]''';

    final prompt = '''
Generate 5 technical and behavioral interview questions for a $role position.
$contextPrompt
$formatPrompt
YOU MUST RESPOND WITH ONLY A VALID JSON ARRAY OF OBJECTS. NO MARKDOWN.

${useResume ? "Resume:\n$resumeText" : ""}

JSON Structure:
$jsonSpec
''';

    final responseText = await _callApi(prompt);
    final result = _extractJson(responseText);
    if (result is List) return List<Map<String, dynamic>>.from(result);
    return [];
  }

  /// NEW: Analyze interview response
  Future<Map<String, dynamic>> analyzeInterviewResponse({
    required String question,
    required String answer,
  }) async {
    final prompt = '''
Analyze the following interview response and provide feedback.
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

Question: $question
Answer: $answer

JSON Structure:
{
  "overall_score": <integer 0-100>,
  "strengths": ["string", "string"],
  "improvements": ["string", "string"],
  "summary": "brief summary string",
  "skill_scores": {
    "Communication": <0-100>,
    "Technical Depth": <0-100>,
    "Problem Solving": <0-100>,
    "Confidence": <0-100>,
    "Structure": <0-100>
  }
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }

  /// NEW: Generate career roadmap
  Future<Map<String, dynamic>> generateCareerRoadmap({
    required String currentRole,
    required String targetRole,
    required String resumeText,
  }) async {
    final prompt = '''
Create a step-by-step career roadmap from $currentRole to $targetRole based on the candidate's current background.
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

Candidate Background (Resume):
$resumeText

JSON Structure:
{
  "current_role": "$currentRole",
  "target_role": "$targetRole",
  "steps": [
    {
      "title": "step title",
      "description": "what to do based on their current experience",
      "resources": "learning resources",
      "duration": "estimated time"
    }
  ]
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }

  /// NEW: Get industry insights
  Future<Map<String, dynamic>> getIndustryInsights({
    required String role,
    required String resumeText,
  }) async {
    final prompt = '''
Provide current industry insights for the role of $role based on the candidate's background.
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

Candidate Background (Resume):
$resumeText

JSON Structure:
{
  "role": "$role",
  "demand": "High/Medium/Low",
  "growth_rate": "percentage string (e.g. +12%)",
  "salary_stats": {
    "min": "string (e.g. ₹5 LPA)",
    "max": "string (e.g. ₹15 LPA)",
    "avg": "string (e.g. ₹10 LPA)"
  },
  "top_companies": ["company 1", "company 2"],
  "key_trends": ["trend 1", "trend 2"],
  "trending_skills": [
    {"name": "Skill Name", "growth": "growth percentage string (e.g. ↑ 15%)"}
  ],
  "top_roles": ["Role 1", "Role 2", "Role 3"],
  "user_match": {
    "alreadyHas": ["skill 1", "skill 2"],
    "shouldLearn": ["skill 3", "skill 4"]
  }
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }

  /// NEW: Match resume to job description
  Future<Map<String, dynamic>> matchJob({
    required String resumeText,
    required String jobDescription,
  }) async {
    final prompt = '''
Match this resume to the job description and provide a compatibility score.
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

Resume: $resumeText
Job Description: $jobDescription

JSON Structure:
{
  "match_score": <integer 0-100>,
  "matching_skills": ["skill 1", "skill 2"],
  "missing_skills": ["skill 1", "skill 2"],
  "verdict": "brief explanation"
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }

  /// NEW: Generate Cover Letter
  Future<String> generateCoverLetter({
    required String resumeText,
    required String jobDescription,
  }) async {
    final prompt = '''
Write a professional, persuasive cover letter based on the following resume and job description.
The letter should be tailored to the role and highlight matching skills from the resume using the STAR method where appropriate.
Keep it concise (3-4 paragraphs) and high-impact.

Candidate Resume:
$resumeText

Target Job Description:
$jobDescription

Format: Return ONLY the text of the cover letter. No preamble or markdown.
''';

    return await _callApi(prompt);
  }

  /// NEW: Generate Networking Message
  Future<String> generateNetworkingMessage({
    required String resumeText,
    required String targetRole,
    required String intent,
  }) async {
    final prompt = '''
Write a highly personalized professional networking message (LinkedIn or Email style) based on the candidate's resume and their networking intent.
The message should be professional yet conversational, and highlight a specific relevant achievement or skill from the resume.

Candidate Resume:
$resumeText

Recipient Target Role:
$targetRole

Networking Intent:
$intent

Format: Return ONLY the text of the message. No subject line, preamble, or markdown.
''';

    return await _callApi(prompt);
  }

  /// NEW: Generate Portfolio Project Suggestions
  Future<List<Map<String, dynamic>>> generateProjectSuggestions({
    required String resumeText,
    required String targetRole,
  }) async {
    final prompt = '''
Suggest 3 high-impact portfolio project ideas for a candidate targeting the role of $targetRole.
The projects should specifically address skill gaps or reinforce strengths seen in the resume.
YOU MUST RESPOND WITH ONLY A VALID JSON ARRAY OF OBJECTS. NO MARKDOWN.

Candidate Resume:
$resumeText

Target Role:
$targetRole

JSON Structure:
[
  {
    "title": "project title",
    "description": "brief overview of what to build",
    "skills_demonstrated": ["skill 1", "skill 2"],
    "difficulty": "Beginner/Intermediate/Advanced",
    "impact": "why this project matters for your portfolio"
  }
]
''';

    final responseText = await _callApi(prompt);
    final result = _extractJson(responseText);
    if (result is List) return List<Map<String, dynamic>>.from(result);
    return [];
  }

  /// NEW: Generate Salary Negotiation Script
  Future<Map<String, dynamic>> generateNegotiationScript({
    required String targetRole,
    required String offerDetails,
    required String resumeText,
  }) async {
    final prompt = '''
Provide a salary negotiation strategy and scripts for a $targetRole position.
Use the candidate's resume to identify leverage points (unique skills, experience).
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

Candidate Resume:
$resumeText

Offer Details:
$offerDetails

JSON Structure:
{
  "strategy": "overall approach summary",
  "leverage_points": ["point 1", "point 2"],
  "scripts": [
    {
      "scenario": "Initial counter-offer",
      "script": "what to say..."
    },
    {
      "scenario": "Handling 'we dont have budget'",
      "script": "what to say..."
    }
  ],
  "tips": ["tip 1", "tip 2"]
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }

  /// NEW: Generate Interview Follow-Up Message
  Future<String> generateFollowUpMessage({
    required String targetRole,
    required String keyPoints,
    required String resumeText,
  }) async {
    final prompt = '''
Write a professional thank-you and follow-up email/message after an interview.
Include a specific reference to the $targetRole role and incorporate key points discussed during the interview to make it personalized.
Highlight a matching skill from the candidate's resume that was emphasized.

Candidate Resume:
$resumeText

Interview Role:
$targetRole

Key Discussion Points / Highlights:
$keyPoints

Format: Return ONLY the text of the message. No subject line, preamble, or markdown.
''';

    return await _callApi(prompt);
  }

  // ==================== HELPERS ====================

  dynamic _extractJson(String text) {
    try {
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.replaceFirst(RegExp(r'^```\w*\n?'), '');
        cleanedText = cleanedText.replaceFirst(RegExp(r'\n?```$'), '');
      }
      cleanedText = cleanedText.trim();
      final firstBrace = cleanedText.indexOf(RegExp(r'\{|\['));
      final lastBrace = cleanedText.lastIndexOf(RegExp(r'\}|\]'));
      if (firstBrace == -1 || lastBrace == -1) {
        return json.decode(cleanedText);
      }
      final cleanJson = cleanedText.substring(firstBrace, lastBrace + 1);
      return json.decode(cleanJson);
    } catch (e) {
      throw Exception('AI Response Format Error: Please try again.');
    }
  }

  /// NEW: Generate Follow-Up message for Job Tracker
  Future<String> generateJobFollowUp({
    required String companyName,
    required String roleTitle,
    String? notes,
    required String resumeText,
  }) async {
    final prompt = '''
Write a professional and compelling follow-up message for a job application.
The message should be tailored to the company and role, and can mention specific points from the notes if provided.
Highlight a relevant skill or experience from the candidate's resume that makes them a great fit.

Candidate Resume:
$resumeText

Company: $companyName
Role: $roleTitle
${notes != null ? "Additional Notes / Context: $notes" : ""}

Format: Return ONLY the text of the message (LinkedIn or Email style). No subject line, preamble, or markdown.
''';

    return await _callApi(prompt);
  }

  /// NEW: Extract job details from a URL snippet or description
  Future<Map<String, dynamic>> extractJobFromUrl(String text) async {
    final prompt = '''
Extract the company name, role title, location, salary range, and key requirements from the following job description or text snippet.
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

Job Text:
$text

JSON Structure:
{
  "company_name": "String or null",
  "role_title": "String or null",
  "location": "String or null",
  "salary_range": "String or null",
  "notes": "Short summary of key requirements"
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }

  /// NEW: Generate application tips for a specific job
  Future<List<String>> generateJobApplicationTips({
    required String companyName,
    required String roleTitle,
    required String resumeText,
  }) async {
    final prompt = '''
Provide 5 concise, high-impact application tips for a $roleTitle position at $companyName.
Tailor the tips based on the candidate's background provided in the resume.
YOU MUST RESPOND WITH ONLY A VALID JSON ARRAY OF STRINGS.

Candidate Resume:
$resumeText

JSON Structure:
["tip 1", "tip 2", "tip 3", "tip 4", "tip 5"]
''';

    final responseText = await _callApi(prompt);
    final result = _extractJson(responseText);
    if (result is List) return result.map((e) => e.toString()).toList();
    return [];
  }

  /// NEW: Get detailed insights for a specific job role
  Future<Map<String, dynamic>> getJobRoleDetails(String roleName) async {
    final prompt = '''
Provide deep market insights for the specific job role: $roleName.
YOU MUST RESPOND WITH ONLY A VALID JSON OBJECT. NO MARKDOWN.

JSON Structure:
{
  "role_name": "$roleName",
  "overview": "2-3 sentence description of the role and its primary responsibilities",
  "demand_level": "High/Medium/Low",
  "growth_percentage": "e.g. +15% over last year",
  "salary_distribution": {
    "min": "e.g. ₹6 LPA",
    "avg": "e.g. ₹12 LPA",
    "max": "e.g. ₹25 LPA"
  },
  "required_skills": ["Technical Skill 1", "Technical Skill 2", "Soft Skill 1"],
  "recommended_skills": ["Niche Skill 1", "Emerging Tool 1"],
  "top_hiring_companies": ["Company A", "Company B", "Company C"]
}
''';

    final responseText = await _callApi(prompt);
    return _extractJson(responseText);
  }
}
