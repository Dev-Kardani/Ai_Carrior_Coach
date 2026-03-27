class JobApplicationModel {
  final String id;
  final String userId;
  final String companyName;
  final String roleTitle;
  final String status;
  final String? location;
  final String? salaryRange;
  final DateTime appliedAt;
  final String? notes;
  final String? jobUrl;
  final DateTime createdAt;

  JobApplicationModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.roleTitle,
    required this.status,
    this.location,
    this.salaryRange,
    required this.appliedAt,
    this.notes,
    this.jobUrl,
    required this.createdAt,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'],
      userId: json['user_id'],
      companyName: json['company_name'],
      roleTitle: json['role_title'],
      status: json['status'],
      location: json['location'],
      salaryRange: json['salary_range'],
      appliedAt: DateTime.parse(json['applied_at']),
      notes: json['notes'],
      jobUrl: json['job_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_name': companyName,
      'role_title': roleTitle,
      'status': status,
      'location': location,
      'salary_range': salaryRange,
      'applied_at': appliedAt.toIso8601String(),
      'notes': notes,
      'job_url': jobUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  JobApplicationModel copyWith({
    String? status,
    String? location,
    String? salaryRange,
    String? notes,
    String? jobUrl,
  }) {
    return JobApplicationModel(
      id: id,
      userId: userId,
      companyName: companyName,
      roleTitle: roleTitle,
      status: status ?? this.status,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      appliedAt: appliedAt,
      notes: notes ?? this.notes,
      jobUrl: jobUrl ?? this.jobUrl,
      createdAt: createdAt,
    );
  }
}
