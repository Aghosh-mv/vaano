import 'dart:async';
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
  bool _isExporting = false;
  double _progress = 0;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _ctx;
  html.MediaRecorder? _recorder;
  List<html.Blob> _chunks = [];

  final List<double> _presets = [0.25, 0.5, 1.0, 1.5, 2.0, 4.0];

  void _pickVideo() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _video = html.VideoElement()..src = url..controls = false..autoplay = false..muted = true;
        _videoName = file.name ?? 'video.mp4';
        _video!.onLoadedMetadata.listen((_) { setState(() { _duration = _video!.duration.toDouble(); _hasVideo = true; }); });
      }
    });
  }

  void _setSpeed(double speed) { if (_video != null) { _video!.playbackRate = speed; setState(() => _speed = speed); } }

  void _playAtSpeed() { if (_video != null) { _video!.playbackRate = _speed; _video!.play(); } }

  Future<void> _exportSpeed() async {
    if (_video == null) return;
    setState(() { _isExporting = true; _progress = 0; _chunks = []; });

    final w = _video!.videoWidth;
    final h = _video!.videoHeight;
    _canvas = html.CanvasElement(width: w, height: h);
    _ctx = _canvas!.context2D;
    final stream = _canvas!.captureStream(30) as html.MediaStream;
    _recorder = html.MediaRecorder(stream, {});
    final completer = Completer<void>();

    _recorder!.addEventListener('dataavailable', (e) {
      final be = e as html.BlobEvent;
      if (be.data != null && be.data!.size > 0) _chunks.add(be.data!);
    });
    _recorder!.addEventListener('stop', (_) {
      final blob = html.Blob(_chunks, 'video/webm');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final a = html.AnchorElement(href: url)..setAttribute('download', 'speed_${_speed}x_${_videoName.replaceAll(RegExp(r'\.[^.]+$'), '')}.webm')..style.display = 'none';
      html.document.body!.children.add(a); a.click(); a.remove(); html.Url.revokeObjectUrl(url);
      _isExporting = false;
      completer.complete();
    });

    _recorder!.start(100);
    final outputDuration = _duration / _speed;
    final totalFrames = (outputDuration * 30).round();
    final frameStep = _duration / totalFrames;
    _video!.muted = true;

    for (int i = 0; i < totalFrames && _isExporting; i++) {
      final t = i * frameStep;
      _video!.currentTime = t % _duration;
      await Future.delayed(const Duration(milliseconds: 16));
      _ctx!.drawImage(_video!, 0, 0);
      _progress = i / totalFrames;
      if (mounted && i % 30 == 0) setState(() {});
    }

    _recorder!.stop();
    await completer.future;
    if (mounted) setState(() {});
  }

  @override
  void dispose() { _recorder?.stop(); _video?.pause(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Speed Control'), backgroundColor: AppColors.surface),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_hasVideo)
            SizedBox(
              height: 200,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _pickVideo, icon: const Icon(Icons.video_file), label: const Text('Select Video'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                ),
              ),
            )
          else
            Container(
              height: 100,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.cardDark),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_videoName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  Text('Duration: ${_duration.toStringAsFixed(1)}s', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ),
            ),
          if (_hasVideo) ...[
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(8)),
                child: Text('${_speed}x', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _speed, min: 0.25, max: 4.0, divisions: 15,
              activeColor: AppColors.primary, inactiveColor: AppColors.cardLight,
              label: '${_speed.toStringAsFixed(2)}x',
              onChanged: (val) { if (_video != null) _video!.playbackRate = val; setState(() => _speed = val); },
            ),
            const SizedBox(height: 16),
            Text('Presets', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _presets.map((p) => ChoiceChip(
                label: Text('${p}x'),
                selected: _speed == p,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.cardDark,
                labelStyle: TextStyle(color: _speed == p ? Colors.white : AppColors.textSecondary),
                onSelected: (val) => _setSpeed(p),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _playAtSpeed,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('Play at ${_speed}x'),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isExporting ? null : _exportSpeed,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(_isExporting ? '...' : 'Export'),
                ),
              )),
            ]),
            if (_isExporting) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
              const SizedBox(height: 4),
              Text('Exporting... ${(_progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ],
        ],
      ),
    );
  }
}
