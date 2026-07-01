import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ReelMakerScreen extends StatefulWidget {
  const ReelMakerScreen({super.key});

  @override
  State<ReelMakerScreen> createState() => _ReelMakerScreenState();
}

class _ReelMakerScreenState extends State<ReelMakerScreen> {
  html.VideoElement? _video;
  String _videoName = '';
  bool _hasVideo = false;
  double _duration = 0;
  bool _isExporting = false;
  double _progress = 0;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _ctx;
  html.MediaRecorder? _recorder;
  List<html.Blob> _chunks = [];

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

  Future<void> _exportReel() async {
    if (_video == null) return;
    setState(() { _isExporting = true; _progress = 0; _chunks = []; });

    final reelW = 720;
    final reelH = 1280;
    final vw = _video!.videoWidth;
    final vh = _video!.videoHeight;
    final scale = (reelW / vw) < (reelH / vh) ? reelW / vw : reelH / vh;
    final scaledW = (vw * scale).round();
    final scaledH = (vh * scale).round();
    final ox = (reelW - scaledW) ~/ 2;
    final oy = (reelH - scaledH) ~/ 2;

    _canvas = html.CanvasElement(width: reelW, height: reelH);
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
      final a = html.AnchorElement(href: url)..setAttribute('download', 'reel_${_videoName.replaceAll(RegExp(r'\.[^.]+$'), '')}.webm')..style.display = 'none';
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

    for (int i = 0; i < totalFrames && _isExporting; i++) {
      final t = i / fps;
      _video!.currentTime = t % _duration;
      await Future.delayed(const Duration(milliseconds: 16));
      _ctx!.fillStyle = 'black';
      _ctx!.fillRect(0, 0, reelW, reelH);
      _ctx!.save();
      _ctx!.translate(ox, oy);
      _ctx!.scale(scaledW / _video!.videoWidth, scaledH / _video!.videoHeight);
      _ctx!.drawImage(_video!, 0, 0);
      _ctx!.restore();
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
      appBar: AppBar(title: const Text('Reel Maker')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: const Color(0xFFE1306C), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.video_library, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('Create Instagram Reel', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('9:16 vertical video format', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 20),
                    if (!_hasVideo)
                      ElevatedButton.icon(
                        onPressed: _pickVideo, icon: const Icon(Icons.video_file), label: const Text('Select Video'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      )
                    else ...[
                      Text(_videoName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      Text('${_duration.toStringAsFixed(1)}s', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 16),
                      if (_isExporting) ...[
                        LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
                        const SizedBox(height: 8),
                        Text('Exporting... ${(_progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              children: [
                const Text('Templates', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: [
                  _templateCard('Trending', Icons.trending_up, const Color(0xFFFF6B6B)),
                  const SizedBox(width: 12),
                  _templateCard('Vlog', Icons.person, const Color(0xFF4ECDC4)),
                  const SizedBox(width: 12),
                  _templateCard('Music', Icons.music_note, const Color(0xFFFFA07A)),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasVideo && !_isExporting ? _exportReel : null,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE1306C), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(_isExporting ? 'Exporting...' : 'Create Reel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _templateCard(String name, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
