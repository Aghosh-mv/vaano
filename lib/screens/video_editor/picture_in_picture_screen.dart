import 'dart:async';
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
  bool _isExporting = false;
  double _progress = 0;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _ctx;
  html.MediaRecorder? _recorder;
  List<html.Blob> _chunks = [];

  final List<String> _positions = ['Top-Right', 'Top-Left', 'Bottom-Right', 'Bottom-Left'];
  final List<String> _sizeLabels = ['Small', 'Medium', 'Large'];

  void _pickMain() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _mainVideo = html.VideoElement()..src = url..controls = false..autoplay = false..muted = true;
        _mainName = file.name ?? 'main.mp4';
        _mainVideo!.onLoadedMetadata.listen((_) { setState(() { _mainDuration = _mainVideo!.duration.toDouble(); _hasMain = true; }); });
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
        _overlayVideo = html.VideoElement()..src = url..controls = false..autoplay = false..muted = true;
        _overlayName = file.name ?? 'overlay.mp4';
        _overlayVideo!.onLoadedMetadata.listen((_) => setState(() => _hasOverlay = true));
      }
    });
  }

  Future<void> _exportPip() async {
    if (_mainVideo == null || _overlayVideo == null) return;
    setState(() { _isExporting = true; _progress = 0; _chunks = []; });

    final w = _mainVideo!.videoWidth;
    final h = _mainVideo!.videoHeight;
    final overlayW = _mainVideo!.videoWidth ~/ (_sizeIndex == 0 ? 4 : _sizeIndex == 1 ? 3 : 2);
    final overlayH = _mainVideo!.videoHeight ~/ (_sizeIndex == 0 ? 4 : _sizeIndex == 1 ? 3 : 2);

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
      final a = html.AnchorElement(href: url)..setAttribute('download', 'pip_${_mainName.replaceAll(RegExp(r'\.[^.]+$'), '')}.webm')..style.display = 'none';
      html.document.body!.children.add(a); a.click(); a.remove(); html.Url.revokeObjectUrl(url);
      _isExporting = false;
      completer.complete();
    });

    _recorder!.start(100);
    final fps = 30;
    final totalFrames = (_mainDuration * fps).round();
    _mainVideo!.muted = true;
    _overlayVideo!.muted = true;
    _mainVideo!.currentTime = 0;
    _overlayVideo!.currentTime = 0;
    await Future.wait([_mainVideo!.play(), _overlayVideo!.play()]);

    int ox, oy;
    if (_position == 'Top-Right') { ox = w - overlayW - 16; oy = 16; }
    else if (_position == 'Top-Left') { ox = 16; oy = 16; }
    else if (_position == 'Bottom-Left') { ox = 16; oy = h - overlayH - 16; }
    else { ox = w - overlayW - 16; oy = h - overlayH - 16; }

    for (int i = 0; i < totalFrames && _isExporting; i++) {
      final t = i / fps;
      _mainVideo!.currentTime = t % _mainDuration;
      _overlayVideo!.currentTime = t % _mainDuration;
      await Future.delayed(const Duration(milliseconds: 16));
      _ctx!.drawImage(_mainVideo!, 0, 0);
      _ctx!.save();
      _ctx!.translate(ox, oy);
      _ctx!.scale(overlayW / _overlayVideo!.videoWidth, overlayH / _overlayVideo!.videoHeight);
      _ctx!.drawImage(_overlayVideo!, 0, 0);
      _ctx!.restore();
      _progress = i / totalFrames;
      if (mounted && i % fps == 0) setState(() {});
    }

    _recorder!.stop();
    await completer.future;
    if (mounted) setState(() {});
  }

  @override
  void dispose() { _recorder?.stop(); _mainVideo?.pause(); _overlayVideo?.pause(); super.dispose(); }

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
              onPressed: _pickMain, icon: const Icon(Icons.video_file), label: const Text('Select Main Video'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          if (_hasMain && !_hasOverlay) const SizedBox(height: 8),
          if (!_hasOverlay)
            ElevatedButton.icon(
              onPressed: _pickOverlay, icon: const Icon(Icons.picture_in_picture), label: const Text('Select Overlay Video'),
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
            const SizedBox(height: 16),
            if (_isExporting) ...[
              LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
              const SizedBox(height: 8),
              Text('Exporting... ${(_progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isExporting ? null : _exportPip,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isExporting ? 'Exporting...' : 'Export PiP Video'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
