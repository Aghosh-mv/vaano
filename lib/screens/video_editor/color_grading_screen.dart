import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ColorGradingScreen extends StatefulWidget {
  const ColorGradingScreen({super.key});

  @override
  State<ColorGradingScreen> createState() => _ColorGradingScreenState();
}

class _ColorGradingScreenState extends State<ColorGradingScreen> {
  html.VideoElement? _video;
  String _videoName = '';
  bool _hasVideo = false;
  double _brightness = 1.0, _contrast = 1.0, _saturation = 1.0, _hueRotate = 0;
  double _duration = 0;

  final List<Map<String, dynamic>> _presets = [
    {'name': 'Normal', 'b': 1.0, 'c': 1.0, 's': 1.0, 'h': 0.0},
    {'name': 'Warm', 'b': 1.1, 'c': 1.2, 's': 1.3, 'h': 15.0},
    {'name': 'Cool', 'b': 1.0, 'c': 1.1, 's': 1.1, 'h': 200.0},
    {'name': 'Vintage', 'b': 0.9, 'c': 0.8, 's': 0.6, 'h': 30.0},
    {'name': 'Noir', 'b': 0.8, 'c': 1.5, 's': 0.0, 'h': 0.0},
    {'name': 'Vibrant', 'b': 1.1, 'c': 1.4, 's': 2.0, 'h': 0.0},
  ];

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

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _brightness = preset['b'];
      _contrast = preset['c'];
      _saturation = preset['s'];
      _hueRotate = preset['h'];
    });
    _applyFilter();
  }

  void _applyFilter() {
    if (_video != null) {
      _video!.style.filter = 'brightness($_brightness) contrast($_contrast) saturate($_saturation) hue-rotate(${_hueRotate}deg)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Color Grading'), backgroundColor: AppColors.surface),
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                ),
              ),
            )
          else
            Container(
              height: 80,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.cardDark),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_videoName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    Text('Duration: ${_duration.toStringAsFixed(1)}s', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ),
          if (_hasVideo) ...[
            const SizedBox(height: 16),
            Text('Presets', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _presets.map((p) => GestureDetector(
                onTap: () => _applyPreset(p),
                child: Container(
                  width: 95, padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _brightness == p['b'] && _contrast == p['c'] && _saturation == p['s'] ? AppColors.primary.withValues(alpha: 0.3) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _brightness == p['b'] && _contrast == p['c'] && _saturation == p['s'] ? AppColors.primary : Colors.transparent),
                  ),
                  child: Column(children: [
                    Icon(Icons.color_lens, color: p['name'] == 'Normal' ? Colors.white : AppColors.accent, size: 24),
                    const SizedBox(height: 4),
                    Text(p['name'], style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                  ]),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            _buildSlider('Brightness', _brightness, 0.5, 2.0, (v) { _brightness = v; _applyFilter(); setState(() {}); }),
            _buildSlider('Contrast', _contrast, 0.5, 2.0, (v) { _contrast = v; _applyFilter(); setState(() {}); }),
            _buildSlider('Saturation', _saturation, 0, 3.0, (v) { _saturation = v; _applyFilter(); setState(() {}); }),
            _buildSlider('Hue Rotate', _hueRotate, 0, 360, (v) { _hueRotate = v; _applyFilter(); setState(() {}); }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Apply Filter'),
              ),
            ),
          ],
          const SizedBox(height: 12),
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

  Widget _buildSlider(String label, double val, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            Text(val.toStringAsFixed(2), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ]),
          Slider(value: val, min: min, max: max, divisions: 100, activeColor: AppColors.primary, inactiveColor: AppColors.cardLight, onChanged: onChanged),
        ],
      ),
    );
  }
}
