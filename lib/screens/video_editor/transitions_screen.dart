import 'dart:async';
import 'dart:html' as html;
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
  bool _isExporting = false;
  double _progress = 0;
  html.CanvasElement? _canvas;
  html.CanvasRenderingContext2D? _ctx;
  html.MediaRecorder? _recorder;
  List<html.Blob> _chunks = [];

  final List<String> _transitions = ['Fade', 'Dissolve', 'Slide', 'Wipe', 'Zoom', 'Blur'];

  void _pickVideo1() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _video1 = html.VideoElement()..src = url..controls = false..autoplay = false..muted = true;
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
        _video2 = html.VideoElement()..src = url..controls = false..autoplay = false..muted = true;
        _name2 = file.name ?? 'video2.mp4';
        _video2!.onLoadedMetadata.listen((_) => setState(() => _hasVideo2 = true));
      }
    });
  }

  Future<void> _exportTransition() async {
    if (_video1 == null || _video2 == null || _selectedTransition == null) return;
    setState(() { _isExporting = true; _progress = 0; _chunks = []; });

    final w = (_video1!.videoWidth > _video2!.videoWidth ? _video1!.videoWidth : _video2!.videoWidth);
    final h = (_video1!.videoHeight > _video2!.videoHeight ? _video1!.videoHeight : _video2!.videoHeight);
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
      final a = html.AnchorElement(href: url)..setAttribute('download', 'transition_$_selectedTransition.webm')..style.display = 'none';
      html.document.body!.children.add(a); a.click(); a.remove(); html.Url.revokeObjectUrl(url);
      _isExporting = false;
      completer.complete();
    });

    _recorder!.start(100);
    final totalFrames = (_duration * 30).round();
    _video1!.currentTime = _video1!.duration - _duration;
    _video2!.currentTime = 0;
    _video1!.muted = true;
    _video2!.muted = true;
    await _video1!.play();
    await _video2!.play();

    for (int i = 0; i <= totalFrames; i++) {
      if (!_isExporting) break;
      final t = i / totalFrames;
      _ctx!.drawImage(_video1!, 0, 0);

      if (_selectedTransition == 'Fade') {
        _ctx!.globalAlpha = t;
        _ctx!.drawImage(_video2!, 0, 0);
        _ctx!.globalAlpha = 1;
      } else if (_selectedTransition == 'Dissolve') {
        _ctx!.globalAlpha = t.clamp(0.0, 1.0);
        _ctx!.drawImage(_video2!, 0, 0);
        _ctx!.globalAlpha = 1;
      } else if (_selectedTransition == 'Slide') {
        final dx = w * (1 - t);
        _ctx!.drawImage(_video1!, -dx, 0);
        _ctx!.drawImage(_video2!, w - dx, 0);
      } else if (_selectedTransition == 'Wipe') {
        _ctx!.save();
        _ctx!.beginPath();
        _ctx!.rect(0, 0, w * t, h);
        _ctx!.closePath();
        _ctx!.clip();
        _ctx!.drawImage(_video2!, 0, 0);
        _ctx!.restore();
      } else if (_selectedTransition == 'Zoom') {
        final scale = 1 + t * 0.5;
        _ctx!.save();
        _ctx!.translate(w / 2, h / 2);
        _ctx!.scale(scale, scale);
        _ctx!.translate(-w / 2, -h / 2);
        _ctx!.drawImage(_video1!, 0, 0);
        _ctx!.restore();
        _ctx!.globalAlpha = t;
        _ctx!.drawImage(_video2!, 0, 0);
        _ctx!.globalAlpha = 1;
      } else {
        _ctx!.globalAlpha = t;
        _ctx!.drawImage(_video2!, 0, 0);
        _ctx!.globalAlpha = 1;
      }

      _progress = i / totalFrames;
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 33));
    }

    _recorder!.stop();
    await completer.future;
  }

  @override
  void dispose() { _recorder?.stop(); _video1?.pause(); _video2?.pause(); super.dispose(); }

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
                onPressed: _pickVideo1, icon: const Icon(Icons.video_file), label: const Text('Select First Video'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            if (!_hasVideo2) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickVideo2, icon: const Icon(Icons.video_file), label: const Text('Select Second Video'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardLight),
              ),
            ],
          ],
          if (_hasVideo1 && _hasVideo2) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.cardDark),
              child: Row(children: [
                Expanded(child: Column(children: [
                  const Icon(Icons.movie, color: AppColors.accent),
                  Text(_name1, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11), overflow: TextOverflow.ellipsis),
                ])),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: AppColors.primary)),
                Expanded(child: Column(children: [
                  const Icon(Icons.movie, color: AppColors.warning),
                  Text(_name2, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11), overflow: TextOverflow.ellipsis),
                ])),
              ]),
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
            if (_isExporting) ...[
              LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
              const SizedBox(height: 8),
              Text('Exporting... ${(_progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTransition == null || _isExporting ? null : _exportTransition,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isExporting ? 'Exporting...' : 'Export $_selectedTransition'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
