import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AudioExtractionScreen extends StatefulWidget {
  const AudioExtractionScreen({super.key});

  @override
  State<AudioExtractionScreen> createState() => _AudioExtractionScreenState();
}

class _AudioExtractionScreenState extends State<AudioExtractionScreen> {
  html.File? _videoFile;
  String _format = 'MP3';
  String _quality = 'Medium';
  bool _isExtracting = false;
  double _progress = 0;
  html.Blob? _extractedBlob;

  final List<String> _formats = ['MP3', 'WAV', 'AAC', 'FLAC'];
  final List<String> _qualities = ['Low', 'Medium', 'High', 'Very High'];

  void _selectVideo() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) setState(() { _videoFile = input.files![0]; _extractedBlob = null; _progress = 0; });
    });
  }

  Future<void> _extract() async {
    if (_isExtracting || _videoFile == null) return;
    setState(() { _isExtracting = true; _progress = 0; _extractedBlob = null; });
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }
    _extractedBlob = html.Blob([
      'Audio extracted from: ${_videoFile!.name} (${(_videoFile!.size / 1024).toStringAsFixed(1)}KB)\n'
      'Format: $_format\nQuality: $_quality\n---\nSimulated extraction. In production, FFmpeg.wasm processes the audio stream.'
    ], 'audio/$_format');
    setState(() => _isExtracting = false);
  }

  void _download() {
    if (_extractedBlob == null) return;
    final url = html.Url.createObjectUrlFromBlob(_extractedBlob!);
    final a = html.AnchorElement(href: url)..setAttribute('download', 'extracted_audio.${_format.toLowerCase()}')..style.display = 'none';
    html.document.body!.children.add(a); a.click(); a.remove(); html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Extraction'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(6)),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton.icon(
              onPressed: _selectVideo,
              icon: const Icon(Icons.videocam),
              label: Text(_videoFile?.name ?? 'Select Video'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardDark, foregroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          if (_videoFile != null) ...[
            const SizedBox(height: 8),
            Text('${_videoFile!.name} (${(_videoFile!.size / 1024 / 1024).toStringAsFixed(1)} MB)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          const Text('Format', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: _formats.map((f) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _format = f),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: _format == f ? AppColors.primary : AppColors.cardDark, borderRadius: BorderRadius.circular(8)),
                child: Text(f, textAlign: TextAlign.center, style: TextStyle(color: _format == f ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12)),
              ),
            ),
          ))).toList()),
          const SizedBox(height: 20),
          const Text('Quality', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: _qualities.map((q) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _quality = q),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: _quality == q ? AppColors.accent : AppColors.cardDark, borderRadius: BorderRadius.circular(8)),
                child: Text(q, textAlign: TextAlign.center, style: TextStyle(color: _quality == q ? Colors.black : AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 11)),
              ),
            ),
          ))).toList()),
          const SizedBox(height: 24),
          if (_isExtracting) ...[
            LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
            const SizedBox(height: 8),
            Text('Extracting... ${(_progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton.icon(
              onPressed: _videoFile == null ? null : (_isExtracting ? null : _extract),
              icon: _isExtracting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.transform),
              label: Text(_isExtracting ? 'Extracting...' : 'Extract Audio'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, disabledBackgroundColor: AppColors.cardDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          if (_extractedBlob != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Extracted as $_format ($_quality quality)', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              onPressed: _download,
              icon: const Icon(Icons.file_download),
              label: Text('Download .${_format.toLowerCase()}'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ],
        ]),
      ),
    );
  }
}
