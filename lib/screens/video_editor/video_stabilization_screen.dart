import 'dart:async';
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
  bool _isExporting = false;
  double _progress = 0;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _ctx;
  html.MediaRecorder? _recorder;
  List<html.Blob> _chunks = [];

  final List<String> _levels = ['Low', 'Medium', 'High', 'Auto'];

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

  Future<void> _applyStabilization() async {
    if (_video == null) return;
    setState(() { _isExporting = true; _progress = 0; _chunks = []; });

    final w = _video!.videoWidth;
    final h = _video!.videoHeight;
    final intensity = (_level + 1) * 2.0;

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
      final a = html.AnchorElement(href: url)..setAttribute('download', 'stabilized_${_videoName.replaceAll(RegExp(r'\.[^.]+$'), '')}.webm')..style.display = 'none';
      html.document.body!.children.add(a); a.click(); a.remove(); html.Url.revokeObjectUrl(url);
      _isExporting = false;
      completer.complete();
    });

    _recorder!.start(100);
    final fps = 30;
    final totalFrames = (_duration * fps).round();
    _video!.muted = true;
    _video!.currentTime = 0;
    await _video!.play();

    double prevSx = 0, prevSy = 0;

    for (int i = 0; i < totalFrames && _isExporting; i++) {
      final t = i / fps;
      _video!.currentTime = t % _duration;
      await Future.delayed(const Duration(milliseconds: 16));

      final before = _ctx!.getImageData(0, 0, w, h);
      _ctx!.drawImage(_video!, 0, 0);
      final after = _ctx!.getImageData(0, 0, w, h);

      double dx = 0, dy = 0;
      if (i > 0 && before != null && after != null) {
        final step = 8;
        int matchCount = 0;
        for (int y = 0; y < h; y += step * 4) {
          for (int x = 0; x < w; x += step * 4) {
            final idx = (y * w + x) * 4;
            final diffX = (after.data[idx] as int) - (before.data[idx] as int);
            final diffY = (after.data[idx + 1] as int) - (before.data[idx + 1] as int);
            if (diffX.abs() < 30 && diffY.abs() < 30) {
              dx += (after.data[idx] as int) - (before.data[idx] as int);
              dy += (after.data[idx + 1] as int) - (before.data[idx + 1] as int);
              matchCount++;
            }
          }
        }
        if (matchCount > 0) { dx /= matchCount; dy /= matchCount; }
      }

      prevSx = prevSx * 0.7 + dx * 0.3;
      prevSy = prevSy * 0.7 + dy * 0.3;

      final offsetX = (prevSx / intensity).clamp(-w * 0.02, w * 0.02);
      final offsetY = (prevSy / intensity).clamp(-h * 0.02, h * 0.02);

      _ctx!.fillStyle = 'black';
      _ctx!.fillRect(0, 0, w, h);
      _ctx!.drawImage(_video!, offsetX.roundToDouble(), offsetY.roundToDouble());

      _progress = i / totalFrames;
      if (mounted && i % (fps * 2) == 0) setState(() {});
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
      appBar: AppBar(title: const Text('Video Stabilization'), backgroundColor: AppColors.surface),
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
            Text('Stabilization Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Slider(
              value: _level.toDouble(), min: 0, max: 3, divisions: 3,
              activeColor: AppColors.primary, inactiveColor: AppColors.cardLight,
              label: _levels[_level],
              onChanged: (val) => setState(() => _level = val.round()),
            ),
            const SizedBox(height: 24),
            if (_isExporting) ...[
              LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
              const SizedBox(height: 8),
              Text('Stabilizing... ${(_progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isExporting ? null : _applyStabilization,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isExporting ? 'Processing...' : 'Apply Stabilization'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
