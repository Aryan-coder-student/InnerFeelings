import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:9696/api';

  // Sentiment Analysis
  static Future<Map<String, dynamic>> analyzeSentiment(String text, String date) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sentiment-analysis'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze sentiment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get journal entry for a specific date
  static Future<Map<String, dynamic>?> getJournalEntry(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/journal/$date'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] ? data : null;
      } else {
        throw Exception('Failed to get journal entry: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all journal entries for calendar
  static Future<Map<String, dynamic>> getAllJournalEntries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/journal'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get journal entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Health check
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
