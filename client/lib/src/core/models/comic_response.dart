class ComicResponse {
  final String status;
  final String imagePath;
  final String prompt;
  final String model;

  ComicResponse({
    required this.status,
    required this.imagePath,
    required this.prompt,
    required this.model,
  });

  factory ComicResponse.fromJson(Map<String, dynamic> json) {
    return ComicResponse(
      status: json['status'] as String,
      imagePath: json['image_path'] as String,
      prompt: json['prompt'] as String,
      model: json['model'] as String,
    );
  }
}