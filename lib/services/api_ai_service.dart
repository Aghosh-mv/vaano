import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiAiService {
  static String? _geminiKey;

  static void setGeminiKey(String key) {
    _geminiKey = key;
  }

  static Future<String?> generateCaptions(String prompt) async {
    if (_geminiKey == null) return 'AI Captions: [Set Gemini API key]';
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': 'Generate captions for: $prompt'}]
          }]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No captions generated';
      }
      return 'API Error: ${response.statusCode}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<String?> translateText(String text, String targetLanguage) async {
    if (_geminiKey == null) return '[Set Gemini API key] $text';
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': 'Translate to $targetLanguage: $text'}]
          }]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? text;
      }
      return text;
    } catch (e) {
      return text;
    }
  }

  static Future<Uint8List?> generateImage(String prompt) async {
    if (_geminiKey == null) return null;
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': prompt}]
          }],
          'generationConfig': {'responseModalities': ['Text', 'Image']}
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;
        if (parts != null) {
          for (final part in parts) {
            if (part['inlineData'] != null) {
              final b64 = part['inlineData']['data'] as String;
              return base64Decode(b64);
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Gemini image gen error: $e');
      return null;
    }
  }
}
