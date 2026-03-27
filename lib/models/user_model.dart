/// User model
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? targetRole;
  final String? experienceLevel;
  final int yearsExperience;
  final String? bio;
  final String? careerGoals;
  final List<String> preferredCountries;
  final bool onboardingCompleted;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.targetRole,
    this.experienceLevel,
    this.yearsExperience = 0,
    this.bio,
    this.careerGoals,
    this.preferredCountries = const [],
    this.onboardingCompleted = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      targetRole: json['target_role'] as String?,
      experienceLevel: json['experience_level'] as String?,
      yearsExperience: json['years_experience'] as int? ?? 0,
      bio: json['bio'] as String?,
      careerGoals: json['career_goals'] as String?,
      preferredCountries:
          (json['preferred_countries'] as List?)?.cast<String>() ?? [],
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'target_role': targetRole,
      'experience_level': experienceLevel,
      'years_experience': yearsExperience,
      'bio': bio,
      'career_goals': careerGoals,
      'preferred_countries': preferredCountries,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
