/// Resume model
class ResumeModel {
  final String id;
  final String userId;
  final String fileName;
  final String filePath;
  final String extractedText;
  final DateTime uploadedAt;
  
  ResumeModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.filePath,
    required this.extractedText,
    required this.uploadedAt,
  });
  
  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      extractedText: json['extracted_text'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'file_name': fileName,
      'file_path': filePath,
      'extracted_text': extractedText,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
