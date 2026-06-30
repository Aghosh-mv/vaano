import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_ai_service.dart';
import '../../theme/app_colors.dart';

class AiAutoCaptionsScreen extends StatefulWidget {
  const AiAutoCaptionsScreen({super.key});

  @override
  State<AiAutoCaptionsScreen> createState() => _AiAutoCaptionsScreenState();
}

class _AiAutoCaptionsScreenState extends State<AiAutoCaptionsScreen> {
  final _descriptionController = TextEditingController();
  String _selectedLanguage = 'English';
  bool _isLoading = false;
  String? _result;
  bool _isCopied = false;

  final _languages = ['English', 'Malayalam', 'Hindi', 'Tamil'];

  Future<void> _generateCaptions() async {
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty) {
      _showSnack('Please describe the video/audio content first');
      return;
    }
    setState(() => _isLoading = true);
    final captions = await ApiAiService.generateCaptions(desc);
    if (!mounted) return;
    setState(() { _isLoading = false; _result = captions; });
    if (captions == null || captions.startsWith('Error') || captions.startsWith('API Error')) {
      _showSnack(captions ?? 'Failed to generate captions');
    }
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
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Auto Captions'), backgroundColor: AppColors.surface),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe the video or audio content...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        dropdownColor: AppColors.cardDark,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: _languages.map((l) => DropdownMenuItem(
                          value: l, child: Row(children: [
                            const Icon(Icons.language, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(l),
                          ]),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedLanguage = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateCaptions,
                      icon: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.closed_caption),
                      label: Text(_isLoading ? 'Generating...' : 'Generate Captions'),
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
                              const Icon(Icons.closed_caption, color: AppColors.accent, size: 20),
                              const SizedBox(width: 8),
                              const Text('Captions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
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
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Text('Free tier: 5 videos/day | Premium: Unlimited',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
