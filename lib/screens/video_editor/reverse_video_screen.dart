import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ReverseVideoScreen extends StatefulWidget {
  const ReverseVideoScreen({super.key});

  @override
  State<ReverseVideoScreen> createState() => _ReverseVideoScreenState();
}

class _ReverseVideoScreenState extends State<ReverseVideoScreen> {
  html.VideoElement? _video;
  String _videoName = '';
  bool _hasVideo = false;
  bool _isReversing = false;
  double _duration = 0;
  Timer? _reverseTimer;

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

  void _startReverse() {
    if (_video == null) return;
    _video!.currentTime = _video!.duration;
    _video!.play();
    setState(() => _isReversing = true);
    _reverseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_video == null || !_video!.controls) {
        _stopReverse();
        return;
      }
      final newTime = _video!.currentTime - 0.1;
      if (newTime <= 0) {
        _video!.pause();
        _stopReverse();
      } else {
        _video!.currentTime = newTime.clamp(0, _video!.duration);
      }
    });
  }

  void _stopReverse() {
    _reverseTimer?.cancel();
    _reverseTimer = null;
    if (_video != null) _video!.pause();
    setState(() => _isReversing = false);
  }

  @override
  void dispose() {
    _reverseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reverse Video'),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Reverse plays from end to start using frame-by-frame seeking.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isReversing ? _stopReverse : _startReverse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isReversing ? AppColors.error : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isReversing ? 'Stop Reverse' : 'Reverse Video'),
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
