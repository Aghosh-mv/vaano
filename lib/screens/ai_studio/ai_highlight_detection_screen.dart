import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_ai_service.dart';
import '../../theme/app_colors.dart';

class AiHighlightDetectionScreen extends StatefulWidget {
  const AiHighlightDetectionScreen({super.key});

  @override
  State<AiHighlightDetectionScreen> createState() => _AiHighlightDetectionScreenState();
}

class _AiHighlightDetectionScreenState extends State<AiHighlightDetectionScreen> {
  final _descController = TextEditingController();
  String? _videoFileName;
  double _duration = 30;
  bool _isAnalyzing = false;
  List<String> _highlights = [];

  Future<void> _selectVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.isNotEmpty) {
      setState(() { _videoFileName = result.files.first.name; _highlights = []; });
    }
  }

  Future<void> _detectHighlights() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) { _showSnack('Describe the video content first'); return; }
    setState(() => _isAnalyzing = true);
    final result = await ApiAiService.generateCaptions(
      '$desc. Analyze ${_duration.toInt()}s video, detect highlight moments. Return timestamps MM:SS with descriptions.',
    );
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    if (result != null && !result.startsWith('Error')) {
      final lines = result.split('\n').where((l) => l.trim().isNotEmpty).toList();
      setState(() => _highlights = lines.length > 8 ? lines.sublist(0, 8) : lines);
    } else {
      _showSnack(result ?? 'Highlight detection failed');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Highlight Detection'), backgroundColor: AppColors.surface,
        actions: [
          Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(6)),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              width: double.infinity, decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
              child: _highlights.isEmpty
                  ? (_isAnalyzing
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 12), Text('Analyzing video...', style: TextStyle(color: AppColors.textSecondary)),
                        ])
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.auto_awesome, size: 64, color: Colors.amber),
                          SizedBox(height: 12), Text('Auto-Detect Highlights', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6), Text('AI finds the best moments', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ]))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _highlights.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.cardLight, height: 1),
                      itemBuilder: (_, i) {
                        final ts = _highlights[i];
                        final isTs = RegExp(r'\d{1,2}:\d{2}').hasMatch(ts);
                        return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
                          Container(width: 32, height: 32, decoration: BoxDecoration(
                            color: isTs ? AppColors.accent.withOpacity(0.2) : AppColors.cardLight, borderRadius: BorderRadius.circular(8)),
                            child: Center(child: Text('${i + 1}', style: TextStyle(color: isTs ? AppColors.accent : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)))),
                          const SizedBox(width: 10),
                          Expanded(child: Text(ts, style: TextStyle(color: isTs ? AppColors.textPrimary : AppColors.textSecondary, fontSize: isTs ? 14 : 12, fontWeight: isTs ? FontWeight.w600 : FontWeight.normal))),
                          if (isTs) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Highlight', style: TextStyle(color: AppColors.primary, fontSize: 9))),
                        ]));
                      }),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Describe the video content...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.description, color: AppColors.primary),
              filled: true, fillColor: AppColors.cardDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.timer, color: AppColors.primary, size: 16), const SizedBox(width: 6),
                Text('Duration: ${_duration.toInt()}s', style: const TextStyle(color: AppColors.textPrimary)),
              ]),
              Slider(value: _duration, min: 5, max: 60, divisions: 11, activeColor: AppColors.primary, inactiveColor: AppColors.cardLight, onChanged: (v) => setState(() => _duration = v)),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _videoFileName == null ? _selectVideo : null,
            icon: const Icon(Icons.videocam), label: Text(_videoFileName ?? 'Select Video'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: _isAnalyzing || _videoFileName == null ? null : _detectHighlights,
            icon: _isAnalyzing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                : const Icon(Icons.auto_awesome),
            label: Text(_isAnalyzing ? 'Analyzing...' : 'Auto Detect Highlights'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: const BorderSide(color: AppColors.accent),
              padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        ]),
      ),
    );
  }
}
