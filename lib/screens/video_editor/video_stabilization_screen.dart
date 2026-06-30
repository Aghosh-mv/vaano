import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class VideoStabilizationScreen extends StatefulWidget {
  const VideoStabilizationScreen({super.key});

  @override
  State<VideoStabilizationScreen> createState() => _VideoStabilizationScreenState();
}

class _VideoStabilizationScreenState extends State<VideoStabilizationScreen> {
  html.VideoElement? _video;
  String _videoName = '';
  bool _hasVideo = false;
  int _level = 2;
  double _duration = 0;

  final List<String> _levels = ['Low', 'Medium', 'High', 'Auto'];

  void _pickVideo() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _video = html.VideoElement()
          ..src = url
          ..controls = false
          ..autoplay = false;
        _videoName = file.name ?? 'video.mp4';
        _video!.onLoadedMetadata.listen((_) {
          setState(() {
            _duration = _video!.duration.toDouble();
            _hasVideo = true;
          });
        });
      }
    });
  }

  void _applyStabilization() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stabilization queued at ${_levels[_level]} level for "$_videoName" (${_duration.toStringAsFixed(1)}s)'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Video Stabilization'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_hasVideo)
            SizedBox(
              height: 200,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.video_file),
                  label: const Text('Select Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.cardDark,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_videoName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    Text('Duration: ${_duration.toStringAsFixed(1)}s',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ),
          if (_hasVideo) ...[
            const SizedBox(height: 24),
            Text('Stabilization Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Slider(
              value: _level.toDouble(),
              min: 0,
              max: 3,
              divisions: 3,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.cardLight,
              label: _levels[_level],
              onChanged: (val) => setState(() => _level = val.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _levels.asMap().entries.map((e) => Text(
                e.value,
                style: TextStyle(
                  color: _level == e.key ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: _level == e.key ? FontWeight.bold : FontWeight.normal,
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyStabilization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Stabilization'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text('PREMIUM', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
