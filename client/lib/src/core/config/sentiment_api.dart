import 'dart:convert';
import 'package:http/http.dart' as http;
import '/src/core/models/sentiment_response.dart';

class SentimentApi {
  static const String baseUrl =
      'http://127.0.0.1:8000'; // Replace with actual API URL
  static const String endpoint = '/text/predict';
  static const String apiKey =
      'YOUR_API_KEY'; // Replace with your API key if required

  Future<SentimentResponse> analyzeSentiment(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey', // Add if API requires authentication
      },
      body: jsonEncode({
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      return SentimentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to analyze sentiment: ${response.statusCode}');
    }
  }
}
