class RoadmapStep {
  final String title;
  final String description;
  final String resources;
  final String duration;

  RoadmapStep({
    required this.title,
    required this.description,
    required this.resources,
    required this.duration,
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      resources: json['resources'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'resources': resources,
    'duration': duration,
  };
}

class CareerRoadmap {
  final String currentRole;
  final String targetRole;
  final List<RoadmapStep> steps;

  CareerRoadmap({
    required this.currentRole,
    required this.targetRole,
    required this.steps,
  });

  factory CareerRoadmap.fromJson(Map<String, dynamic> json) {
    return CareerRoadmap(
      currentRole: json['current_role'] ?? '',
      targetRole: json['target_role'] ?? '',
      steps: (json['steps'] as List?)
              ?.map((e) => RoadmapStep.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'current_role': currentRole,
    'target_role': targetRole,
    'steps': steps.map((e) => e.toJson()).toList(),
  };
}
