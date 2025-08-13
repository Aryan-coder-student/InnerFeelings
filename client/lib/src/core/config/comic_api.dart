import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comic_response.dart';

class ComicApi {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String endpoint = '/genai_tool/text-to-image';
  static const String apiKey = 'AIzaSyA2RrtWIHCt_LXoRho_R4EAsCp7czJNXr8';

  Future<ComicResponse> generateComic(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $apiKey', // If required by API
      },
      body: {
        'text_description': prompt,
      },
    );

    if (response.statusCode == 200) {
      return ComicResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to generate comic: ${response.statusCode}');
    }
  }
}
