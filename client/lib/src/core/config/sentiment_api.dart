import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '/src/core/models/sentiment_response.dart';

class SentimentApi {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String endpoint = '/text/predict';
  static const String apiKey = 'AIzaSyA2RrtWIHCt_LXoRho_R4EAsCp7czJNXr8';

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/sentiment_results.json');
  }

  Future<SentimentResponse> analyzeSentiment(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);

      // Save input + output only if success
      await _saveToJsonFile(text, responseJson);

      return SentimentResponse.fromJson(responseJson);
    } else {
      throw Exception('Failed to analyze sentiment: ${response.statusCode}');
    }
  }

  Future<void> _saveToJsonFile(String inputText, Map<String, dynamic> responseJson) async {
    final file = await _getLocalFile();
    List<dynamic> data = [];

    if (await file.exists()) {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        data = jsonDecode(content);
      }
    }

    // Append new entry
    data.add({
      'text': inputText,
      'scores': responseJson['scores'],
      'top_label': responseJson['top_label'],
      'top_score': responseJson['top_score']
      // 'timestamp': DateTime.now().toIso8601String()
    });

    await file.writeAsString(jsonEncode(data), flush: true);
  }
}
