class IndustryInsight {
  final String role;
  final String demand;
  final String growthRate;
  final Map<String, dynamic> salaryStats;
  final List<String> topCompanies;
  final List<String> keyTrends;
  final List<Map<String, dynamic>>
      trendingSkills; // {name: String, growth: String}
  final List<String> topRoles;
  final Map<String, dynamic> userMatch; // {alreadyHas: List, shouldLearn: List}

  IndustryInsight({
    required this.role,
    required this.demand,
    required this.growthRate,
    required this.salaryStats,
    required this.topCompanies,
    required this.keyTrends,
    required this.trendingSkills,
    required this.topRoles,
    required this.userMatch,
  });

  factory IndustryInsight.fromJson(Map<String, dynamic> json) {
    return IndustryInsight(
      role: json['role'] ?? '',
      demand: json['demand'] ?? '',
      growthRate: json['growth_rate'] ?? '',
      salaryStats: json['salary_stats'] ?? {},
      topCompanies: List<String>.from(json['top_companies'] ?? []),
      keyTrends: List<String>.from(json['key_trends'] ?? []),
      trendingSkills:
          List<Map<String, dynamic>>.from(json['trending_skills'] ?? []),
      topRoles: List<String>.from(json['top_roles'] ?? []),
      userMatch: json['user_match'] ?? {'alreadyHas': [], 'shouldLearn': []},
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'demand': demand,
        'growth_rate': growthRate,
        'salary_stats': salaryStats,
        'top_companies': topCompanies,
        'key_trends': keyTrends,
        'trending_skills': trendingSkills,
        'top_roles': topRoles,
        'user_match': userMatch,
      };
}

class JobRoleDetail {
  final String roleName;
  final String overview;
  final String demandLevel; // High, Medium, Low
  final String growthPercentage;
  final Map<String, String> salaryDistribution; // {min, avg, max}
  final List<String> requiredSkills;
  final List<String> recommendedSkills;
  final List<String> topHiringCompanies;

  JobRoleDetail({
    required this.roleName,
    required this.overview,
    required this.demandLevel,
    required this.growthPercentage,
    required this.salaryDistribution,
    required this.requiredSkills,
    required this.recommendedSkills,
    required this.topHiringCompanies,
  });

  factory JobRoleDetail.fromJson(Map<String, dynamic> json) {
    return JobRoleDetail(
      roleName: json['role_name'] ?? '',
      overview: json['overview'] ?? '',
      demandLevel: json['demand_level'] ?? 'Medium',
      growthPercentage: json['growth_percentage'] ?? '0%',
      salaryDistribution:
          Map<String, String>.from(json['salary_distribution'] ?? {}),
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      recommendedSkills: List<String>.from(json['recommended_skills'] ?? []),
      topHiringCompanies: List<String>.from(json['top_hiring_companies'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'role_name': roleName,
        'overview': overview,
        'demand_level': demandLevel,
        'growth_percentage': growthPercentage,
        'salary_distribution': salaryDistribution,
        'required_skills': requiredSkills,
        'recommended_skills': recommendedSkills,
        'top_hiring_companies': topHiringCompanies,
      };
}
