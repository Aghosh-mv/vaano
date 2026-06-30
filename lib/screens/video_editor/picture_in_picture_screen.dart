import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PictureInPictureScreen extends StatefulWidget {
  const PictureInPictureScreen({super.key});

  @override
  State<PictureInPictureScreen> createState() => _PictureInPictureScreenState();
}

class _PictureInPictureScreenState extends State<PictureInPictureScreen> {
  html.VideoElement? _mainVideo, _overlayVideo;
  String _mainName = '', _overlayName = '';
  bool _hasMain = false, _hasOverlay = false;
  String _position = 'Bottom-Right';
  int _sizeIndex = 1;
  double _mainDuration = 0;

  final List<String> _positions = ['Top-Right', 'Top-Left', 'Bottom-Right', 'Bottom-Left'];
  final List<String> _sizeLabels = ['Small', 'Medium', 'Large'];

  void _pickMain() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _mainVideo = html.VideoElement()..src = url..controls = false..autoplay = false;
        _mainName = file.name ?? 'main.mp4';
        _mainVideo!.onLoadedMetadata.listen((_) {
          setState(() {
            _mainDuration = _mainVideo!.duration.toDouble();
            _hasMain = true;
          });
        });
      }
    });
  }

  void _pickOverlay() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _overlayVideo = html.VideoElement()..src = url..controls = false..autoplay = false;
        _overlayName = file.name ?? 'overlay.mp4';
        _overlayVideo!.onLoadedMetadata.listen((_) => setState(() => _hasOverlay = true));
      }
    });
  }

  void _startPip() {
    if (_mainVideo != null) {
      _mainVideo!.play();
      html.window.alert('Picture-in-Picture mode activated. Check browser controls.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Picture in Picture'), backgroundColor: AppColors.surface),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_hasMain)
            ElevatedButton.icon(
              onPressed: _pickMain,
              icon: const Icon(Icons.video_file),
              label: const Text('Select Main Video'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          if (_hasMain && !_hasOverlay) const SizedBox(height: 8),
          if (!_hasOverlay)
            ElevatedButton.icon(
              onPressed: _pickOverlay,
              icon: const Icon(Icons.picture_in_picture),
              label: const Text('Select Overlay Video'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardLight),
            ),
          if (_hasMain && _hasOverlay) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.cardDark),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.videocam, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_mainName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)),
                ]),
                const Divider(color: AppColors.cardLight, height: 16),
                Row(children: [
                  const Icon(Icons.picture_in_picture_alt, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_overlayName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            Text('Position', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _positions.map((p) => ChoiceChip(
                label: Text(p),
                selected: _position == p,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.cardDark,
                labelStyle: TextStyle(color: _position == p ? Colors.white : AppColors.textSecondary),
                onSelected: (val) => setState(() => _position = p),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text('Overlay Size: ${_sizeLabels[_sizeIndex]}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            Slider(
              value: _sizeIndex.toDouble(), min: 0, max: 2, divisions: 2,
              activeColor: AppColors.primary, inactiveColor: AppColors.cardLight,
              label: _sizeLabels[_sizeIndex],
              onChanged: (val) => setState(() => _sizeIndex = val.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _sizeLabels.asMap().entries.map((e) => Text(
                e.value,
                style: TextStyle(color: _sizeIndex == e.key ? AppColors.primary : AppColors.textSecondary, fontSize: 12),
              )).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startPip,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Start PiP'),
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
}
