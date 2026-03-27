/// AI analysis result model
class AnalysisModel {
  final String id;
  final String resumeId;
  final String userId;
  final int score;
  final List<String> strengths;
  final List<String> weaknesses;
  final String atsCompatibility;
  final String? atsTips;
  final List<String> suggestions;
  final DateTime createdAt;

  AnalysisModel({
    required this.id,
    required this.resumeId,
    required this.userId,
    required this.score,
    required this.strengths,
    required this.weaknesses,
    required this.atsCompatibility,
    this.atsTips,
    required this.suggestions,
    required this.createdAt,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      id: json['id'] as String,
      resumeId: json['resume_id'] as String,
      userId: json['user_id'] as String,
      score: json['score'] as int,
      strengths: List<String>.from(json['strengths'] as List),
      weaknesses: List<String>.from(json['weaknesses'] as List),
      atsCompatibility: json['ats_compatibility'] as String,
      atsTips: json['ats_tips'] as String?,
      suggestions: List<String>.from(json['suggestions'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resume_id': resumeId,
      'user_id': userId,
      'score': score,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'ats_compatibility': atsCompatibility,
      'ats_tips': atsTips,
      'suggestions': suggestions,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
