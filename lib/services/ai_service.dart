import 'dart:convert';
import 'dart:typed_data';
import 'api_ai_service.dart';

class AiService {
  static const int _maxFreeUsage = 5;
  int _usageCount = 0;

  bool get hasFreeUsage => _usageCount < _maxFreeUsage;
  int get remainingUsage => _maxFreeUsage - _usageCount;

  Future<String?> generateImage(String prompt) async {
    _usageCount++;
    final imageBytes = await ApiAiService.generateImage(prompt);
    if (imageBytes != null) {
      return _bytesToDataUrl(imageBytes);
    }
    return null;
  }

  Future<String> removeBackground(String imagePath) async {
    _usageCount++;
    await Future.delayed(const Duration(seconds: 1));
    return imagePath;
  }

  Future<String?> generateCaptions(String text) async {
    _usageCount++;
    return await ApiAiService.generateCaptions(text);
  }

  Future<String> cloneVoice(String audioPath) async {
    _usageCount++;
    await Future.delayed(const Duration(seconds: 2));
    return audioPath;
  }

  Future<String?> translateText(String text, String targetLanguage) async {
    _usageCount++;
    return await ApiAiService.translateText(text, targetLanguage);
  }

  void resetUsage() {
    _usageCount = 0;
  }

  String _bytesToDataUrl(Uint8List bytes) {
    final base64 = base64Encode(bytes);
    return 'data:image/png;base64,$base64';
  }
}
