import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SpeedControlScreen extends StatefulWidget {
  const SpeedControlScreen({super.key});

  @override
  State<SpeedControlScreen> createState() => _SpeedControlScreenState();
}

class _SpeedControlScreenState extends State<SpeedControlScreen> {
  html.VideoElement? _video;
  String _videoName = '';
  bool _hasVideo = false;
  double _speed = 1.0;
  double _duration = 0;

  final List<double> _presets = [0.25, 0.5, 1.0, 1.5, 2.0, 4.0];

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

  void _setSpeed(double speed) {
    if (_video != null) {
      _video!.playbackRate = speed;
      setState(() => _speed = speed);
    }
  }

  void _playAtSpeed() {
    if (_video != null) {
      _video!.playbackRate = _speed;
      _video!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Speed Control'),
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
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_speed}x',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _speed,
              min: 0.25,
              max: 4.0,
              divisions: 15,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.cardLight,
              label: '${_speed.toStringAsFixed(2)}x',
              onChanged: (val) {
                if (_video != null) _video!.playbackRate = val;
                setState(() => _speed = val);
              },
            ),
            const SizedBox(height: 16),
            Text('Presets', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) => ChoiceChip(
                label: Text('${p}x'),
                selected: _speed == p,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.cardDark,
                labelStyle: TextStyle(
                  color: _speed == p ? Colors.white : AppColors.textSecondary,
                ),
                onSelected: (val) => _setSpeed(p),
              )).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _playAtSpeed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Play at ${_speed}x'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
