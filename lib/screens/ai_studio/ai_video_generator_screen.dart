import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/api_ai_service.dart';
import '../../theme/app_colors.dart';

class AiVideoGeneratorScreen extends StatefulWidget {
  const AiVideoGeneratorScreen({super.key});

  @override
  State<AiVideoGeneratorScreen> createState() => _AiVideoGeneratorScreenState();
}

class _AiVideoGeneratorScreenState extends State<AiVideoGeneratorScreen> {
  final _promptController = TextEditingController();
  String _selectedStyle = 'Cinematic';
  String _selectedDuration = '30s';
  bool _isLoading = false;
  Uint8List? _generatedFrame;

  final _styles = ['Cinematic', 'Anime', 'Realistic', 'Cartoon'];
  final _durations = ['15s', '30s', '60s'];

  Future<void> _generateVideo() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) { _showSnack('Enter a video description'); return; }
    setState(() => _isLoading = true);
    final image = await ApiAiService.generateImage('$_selectedStyle style video: $prompt');
    if (!mounted) return;
    setState(() { _isLoading = false; _generatedFrame = image; });
    if (image == null) _showSnack('Image generation failed');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Video Generator'),
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
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
              child: _generatedFrame != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_generatedFrame!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 8, left: 8, right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Single frame preview', textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              SizedBox(height: 16),
                              Text('Generating video frame...', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_call, size: 64, color: AppColors.accent),
                            SizedBox(height: 16),
                            Text('Generate Video with AI', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            Text('Text-to-video generation', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the video you want to create...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.auto_awesome, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            const Text('Style', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _styles.map((style) {
                final isSelected = _selectedStyle == style;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStyle = style),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardLight),
                    ),
                    child: Text(style, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Duration', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _durations.map((d) {
                final isSelected = _selectedDuration == d;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDuration = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.accent : AppColors.cardLight),
                    ),
                    child: Text(d, style: TextStyle(color: isSelected ? AppColors.accent : AppColors.textPrimary, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateVideo,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Generating...' : 'Generate Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
