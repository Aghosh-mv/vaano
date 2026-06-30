import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TransitionsScreen extends StatefulWidget {
  const TransitionsScreen({super.key});

  @override
  State<TransitionsScreen> createState() => _TransitionsScreenState();
}

class _TransitionsScreenState extends State<TransitionsScreen> {
  html.VideoElement? _video1, _video2;
  String _name1 = '', _name2 = '';
  bool _hasVideo1 = false, _hasVideo2 = false;
  String? _selectedTransition;
  double _duration = 1.0;
  bool _isPreviewing = false;
  Timer? _crossfadeTimer;

  final List<String> _transitions = ['Fade', 'Dissolve', 'Slide', 'Wipe', 'Zoom', 'Blur'];

  void _pickVideo1() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _video1 = html.VideoElement()..src = url..controls = false..autoplay = false;
        _name1 = file.name ?? 'video1.mp4';
        _video1!.onLoadedMetadata.listen((_) => setState(() => _hasVideo1 = true));
      }
    });
  }

  void _pickVideo2() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _video2 = html.VideoElement()..src = url..controls = false..autoplay = false;
        _name2 = file.name ?? 'video2.mp4';
        _video2!.onLoadedMetadata.listen((_) => setState(() => _hasVideo2 = true));
      }
    });
  }

  void _previewTransition() {
    if (_video1 == null || _video2 == null || _selectedTransition == null) return;
    setState(() => _isPreviewing = true);
    _video1!.currentTime = 0;
    _video2!.currentTime = 0;
    _video1!.play();
    _video2!.play();
    double elapsed = 0;
    _crossfadeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      elapsed += 0.05;
      if (elapsed >= _duration) {
        _video1!.pause();
        _video2!.play();
        _stopPreview();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Previewing $_selectedTransition transition...'), backgroundColor: AppColors.accent),
    );
  }

  void _stopPreview() {
    _crossfadeTimer?.cancel();
    _crossfadeTimer = null;
    setState(() => _isPreviewing = false);
  }

  @override
  void dispose() {
    _crossfadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transitions'), backgroundColor: AppColors.surface),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_hasVideo1 || !_hasVideo2) ...[
            if (!_hasVideo1)
              ElevatedButton.icon(
                onPressed: _pickVideo1,
                icon: const Icon(Icons.video_file),
                label: const Text('Select First Video'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            if (!_hasVideo2) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickVideo2,
                icon: const Icon(Icons.video_file),
                label: const Text('Select Second Video'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardLight),
              ),
            ],
          ],
          if (_hasVideo1 && _hasVideo2) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.cardDark),
              child: Row(
                children: [
                  Expanded(child: Column(children: [
                    const Icon(Icons.movie, color: AppColors.accent),
                    Text(_name1, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11), overflow: TextOverflow.ellipsis),
                  ])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: AppColors.primary),
                  ),
                  Expanded(child: Column(children: [
                    const Icon(Icons.movie, color: AppColors.warning),
                    Text(_name2, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11), overflow: TextOverflow.ellipsis),
                  ])),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Transition Effect', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _transitions.map((t) => ChoiceChip(
                label: Text(t),
                selected: _selectedTransition == t,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.cardDark,
                labelStyle: TextStyle(color: _selectedTransition == t ? Colors.white : AppColors.textSecondary),
                onSelected: (val) => setState(() => _selectedTransition = t),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text('Duration: ${_duration.toStringAsFixed(1)}s', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            Slider(
              value: _duration, min: 0.5, max: 3.0, divisions: 5,
              activeColor: AppColors.primary, inactiveColor: AppColors.cardLight,
              label: '${_duration.toStringAsFixed(1)}s',
              onChanged: (val) => setState(() => _duration = val),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTransition == null ? null : (_isPreviewing ? _stopPreview : _previewTransition),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPreviewing ? AppColors.error : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isPreviewing ? 'Stop Preview' : 'Preview $_selectedTransition'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
