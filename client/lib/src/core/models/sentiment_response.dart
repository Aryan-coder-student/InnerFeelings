class SentimentResponse {
  final Map<String, double> scores;
  final String topLabel;
  final double topScore;

  SentimentResponse({
    required this.scores,
    required this.topLabel,
    required this.topScore,
  });

  factory SentimentResponse.fromJson(Map<String, dynamic> json) {
    return SentimentResponse(
      scores: Map<String, double>.from(json['scores']),
      topLabel: json['top_label'] as String,
      topScore: (json['top_score'] as num).toDouble(),
    );
  }
}