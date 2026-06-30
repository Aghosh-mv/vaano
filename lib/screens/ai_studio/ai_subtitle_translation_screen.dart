import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_ai_service.dart';
import '../../theme/app_colors.dart';

class AiSubtitleTranslationScreen extends StatefulWidget {
  const AiSubtitleTranslationScreen({super.key});

  @override
  State<AiSubtitleTranslationScreen> createState() => _AiSubtitleTranslationScreenState();
}

class _AiSubtitleTranslationScreenState extends State<AiSubtitleTranslationScreen> {
  final _subtitleController = TextEditingController();
  String _fromLanguage = 'English';
  String _toLanguage = 'Malayalam';
  bool _isLoading = false;
  String? _result;
  bool _isCopied = false;

  final _languages = ['English', 'Malayalam', 'Hindi', 'Tamil', 'Spanish', 'Arabic', 'French', 'German'];

  Future<void> _translate() async {
    final text = _subtitleController.text.trim();
    if (text.isEmpty) {
      _showSnack('Enter subtitles to translate');
      return;
    }
    setState(() => _isLoading = true);
    final translated = await ApiAiService.translateText(text, _toLanguage);
    if (!mounted) return;
    setState(() { _isLoading = false; _result = translated; });
    if (translated == null) _showSnack('Translation failed');
  }

  void _copy() {
    if (_result == null) return;
    Clipboard.setData(ClipboardData(text: _result!));
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  void dispose() {
    _subtitleController.dispose();
    super.dispose();
  }

  Widget _languageDropdown(String value, void Function(String?) onChanged, {Color iconColor = AppColors.primary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.cardDark,
          style: const TextStyle(color: AppColors.textPrimary),
          items: _languages.map((l) => DropdownMenuItem(
            value: l, child: Row(children: [
              Icon(Icons.language, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(l),
            ]),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Subtitle Translation'),
        backgroundColor: AppColors.surface,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(6)),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _subtitleController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter subtitles to translate...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            const Text('From', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            _languageDropdown(_fromLanguage, (v) => setState(() => _fromLanguage = v!), iconColor: AppColors.primary),
            const SizedBox(height: 16),
            const Text('To', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            _languageDropdown(_toLanguage, (v) => setState(() => _toLanguage = v!), iconColor: AppColors.accent),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _translate,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.translate),
                label: Text(_isLoading ? 'Translating...' : 'Translate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.translate, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text('Translated ($_toLanguage)', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                        const Spacer(),
                        GestureDetector(
                          onTap: _copy,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isCopied ? AppColors.success : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isCopied ? 'Copied!' : 'Copy',
                              style: TextStyle(color: _isCopied ? Colors.white : AppColors.textPrimary, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(_result!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
