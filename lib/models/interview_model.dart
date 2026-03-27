enum InterviewType { mcq, descriptive }

class InterviewQuestion {
  final String question;
  final String expectedAnswer;
  final String tip;
  final InterviewType type;
  final List<String>? options;

  InterviewQuestion({
    required this.question,
    required this.expectedAnswer,
    required this.tip,
    this.type = InterviewType.descriptive,
    this.options,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      question: json['question'] ?? '',
      expectedAnswer: json['expected_answer'] ?? '',
      tip: json['tip'] ?? '',
      type:
          json['type'] == 'mcq' ? InterviewType.mcq : InterviewType.descriptive,
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'expected_answer': expectedAnswer,
        'tip': tip,
        'type': type == InterviewType.mcq ? 'mcq' : 'descriptive',
        'options': options,
      };
}

class InterviewFeedback {
  final int overallScore;
  final List<String> strengths;
  final List<String> improvements;
  final String summary;
  final Map<String, int> skillScores;

  InterviewFeedback({
    required this.overallScore,
    required this.strengths,
    required this.improvements,
    required this.summary,
    required this.skillScores,
  });

  factory InterviewFeedback.fromJson(Map<String, dynamic> json) {
    return InterviewFeedback(
      overallScore: json['overall_score'] ?? 0,
      strengths: List<String>.from(json['strengths'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      summary: json['summary'] ?? '',
      skillScores: Map<String, int>.from(json['skill_scores'] ??
          {
            'Communication': 0,
            'Technical Depth': 0,
            'Problem Solving': 0,
            'Confidence': 0,
            'Structure': 0,
          }),
    );
  }

  Map<String, dynamic> toJson() => {
        'overall_score': overallScore,
        'strengths': strengths,
        'improvements': improvements,
        'summary': summary,
        'skill_scores': skillScores,
      };
}
