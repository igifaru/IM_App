/// Smart Consultant data models for farmer choice validation and recommendations

class FarmerChoice {
  final String crop;
  final double confidenceScore;
  final String status; // "good", "moderate", "poor"
  final String statusColor; // "green", "yellow", "red"
  final String validationMessage;

  FarmerChoice({
    required this.crop,
    required this.confidenceScore,
    required this.status,
    required this.statusColor,
    required this.validationMessage,
  });

  factory FarmerChoice.fromJson(Map<String, dynamic> json) {
    return FarmerChoice(
      crop: json['crop'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      status: json['status'] as String,
      statusColor: json['status_color'] as String,
      validationMessage: json['validation_message'] as String,
    );
  }
}

class CropRecommendation {
  final int rank;
  final String crop;
  final double confidenceScore;
  final String reason;

  CropRecommendation({
    required this.rank,
    required this.crop,
    required this.confidenceScore,
    required this.reason,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      rank: json['rank'] as int,
      crop: json['crop'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      reason: json['reason'] as String,
    );
  }
}

class AIInterpretation {
  final String text;
  final String language;
  final DateTime generatedAt;

  AIInterpretation({
    required this.text,
    required this.language,
    required this.generatedAt,
  });

  factory AIInterpretation.fromJson(Map<String, dynamic> json) {
    return AIInterpretation(
      text: json['text'] as String,
      language: json['language'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}
