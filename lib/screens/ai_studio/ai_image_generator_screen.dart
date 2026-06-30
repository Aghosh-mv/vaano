import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_ai_service.dart';

class AiImageGeneratorScreen extends StatefulWidget {
  const AiImageGeneratorScreen({super.key});

  @override
  State<AiImageGeneratorScreen> createState() => _AiImageGeneratorScreenState();
}

class _AiImageGeneratorScreenState extends State<AiImageGeneratorScreen> {
  final _controller = TextEditingController();
  ui.Image? _generatedImage;
  bool _isGenerating = false;
  String _style = 'Realistic';
  String _aspectRatio = '1:1';
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image Generator'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.premium,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('BETA', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isGenerating
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Generating with AI...',
                          style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    )
                  : _generatedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: RawImage(
                            image: _generatedImage!,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image, size: 64, color: AppColors.textSecondary),
                              const SizedBox(height: 16),
                              const Text('Describe what you want to see',
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                                ),
                              if (_generatedImage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: OutlinedButton.icon(
                                    onPressed: _downloadImage,
                                    icon: const Icon(Icons.download),
                                    label: const Text('Download'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'A beautiful sunset over mountains...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.auto_awesome, color: AppColors.primary),
                  ),
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _style,
                        items: ['Realistic', 'Artistic', 'Anime', '3D Render']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: AppColors.textPrimary))))
                            .toList(),
                        onChanged: (v) => setState(() => _style = v!),
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                        dropdownColor: AppColors.cardDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _aspectRatio,
                        items: ['1:1', '16:9', '9:16', '4:3']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: AppColors.textPrimary))))
                            .toList(),
                        onChanged: (v) => setState(() => _aspectRatio = v!),
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                        dropdownColor: AppColors.cardDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generate() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    final prompt = '${_style} style: ${_controller.text}';
    final bytes = await ApiAiService.generateImage(prompt);
    if (bytes != null && mounted) {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _generatedImage = frame.image;
        _isGenerating = false;
      });
    } else if (mounted) {
      setState(() {
        _isGenerating = false;
        _error = 'Generation failed. API may need auth. Try again.';
      });
    }
  }

  void _downloadImage() {
    if (_generatedImage == null) return;
    _generatedImage!.toByteData(format: ui.ImageByteFormat.png).then((data) {
      if (data != null) {
        final blob = html.Blob([data.buffer.asUint8List()], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'ai_generated.png')
          ..style.display = 'none';
        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      }
    });
  }
}
