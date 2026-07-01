import 'dart:async';
import 'dart:html' as html;
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
  bool _isExporting = false;
  double _progress = 0;
  double _duration = 0;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _ctx;
  html.MediaRecorder? _recorder;
  List<html.Blob> _chunks = [];
  StreamSubscription? _timeSub;

  void _pickVideo() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _video = html.VideoElement()..src = url..controls = false..autoplay = false..muted = true;
        _videoName = file.name ?? 'video.mp4';
        _video!.onLoadedMetadata.listen((_) {
          setState(() { _duration = _video!.duration.toDouble(); _hasVideo = true; });
        });
      }
    });
  }

  Future<void> _exportReverse() async {
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
      final a = html.AnchorElement(href: url)..setAttribute('download', 'reversed_${_videoName.replaceAll(RegExp(r'\.[^.]+$'), '')}.webm')..style.display = 'none';
      html.document.body!.children.add(a); a.click(); a.remove(); html.Url.revokeObjectUrl(url);
      _isExporting = false;
      completer.complete();
    });

    _recorder!.start(100);
    final totalFrames = (_duration * 30).round();
    _video!.muted = true;

    for (int frame = totalFrames - 1; frame >= 0; frame--) {
      if (!_isExporting) break;
      final time = frame / 30;
      _video!.currentTime = time;
      await Future.delayed(const Duration(milliseconds: 33));
      _ctx!.drawImage(_video!, 0, 0);
      _progress = (totalFrames - frame) / totalFrames;
    }

    _recorder!.stop();
    await completer.future;
    if (mounted) setState(() {});
  }

  @override
  void dispose() { _timeSub?.cancel(); _recorder?.stop(); _video?.pause(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reverse Video'), backgroundColor: AppColors.surface),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Reverse exports frames from end to start as a new WebM video.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 24),
            if (_isExporting) ...[
              LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
              const SizedBox(height: 8),
              Text('Exporting... ${(_progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isExporting ? null : _exportReverse,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isExporting ? 'Exporting...' : 'Export Reversed Video'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
