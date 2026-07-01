import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AudioExtractionScreen extends StatefulWidget {
  const AudioExtractionScreen({super.key});

  @override
  State<AudioExtractionScreen> createState() => _AudioExtractionScreenState();
}

class _AudioExtractionScreenState extends State<AudioExtractionScreen> {
  html.File? _videoFile;
  String _format = 'MP3';
  String _quality = 'Medium';
  bool _isExtracting = false;
  double _progress = 0;
  html.Blob? _extractedBlob;
  html.VideoElement? _video;
  html.MediaRecorder? _recorder;
  List<html.Blob> _chunks = [];
  StreamSubscription? _timeSub;

  final List<String> _formats = ['MP3', 'WAV', 'AAC', 'FLAC'];
  final List<String> _qualities = ['Low', 'Medium', 'High', 'Very High'];

  void _selectVideo() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        setState(() { _videoFile = input.files![0]; _extractedBlob = null; _progress = 0; });
      }
    });
  }

  Future<void> _extract() async {
    if (_isExtracting || _videoFile == null) return;
    setState(() { _isExtracting = true; _progress = 0; _extractedBlob = null; _chunks = []; });

    final url = html.Url.createObjectUrl(_videoFile!);
    _video = html.VideoElement()..src = url..preload = 'auto'..muted = true;
    await _video!.onLoadedMetadata.first;
    await _video!.play();

    final stream = _video!.captureStream();
    final audioTracks = stream.getAudioTracks();
    if (audioTracks.isEmpty) {
      setState(() => _isExtracting = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No audio track found')));
      return;
    }
    final audioStream = html.MediaStream([audioTracks.first]);
    final mimeType = _format == 'MP3' ? 'audio/webm;codecs=opus' : _format == 'WAV' ? 'audio/wav' : _format == 'AAC' ? 'audio/aac' : 'audio/flac';
    _recorder = html.MediaRecorder(audioStream, {'mimeType': mimeType});

    final completer = Completer<void>();
    _recorder!.addEventListener('dataavailable', (e) {
      final be = e as html.BlobEvent;
      if (be.data != null && be.data!.size > 0) _chunks.add(be.data!);
    });
    _recorder!.addEventListener('stop', (_) {
      _extractedBlob = html.Blob(_chunks, mimeType);
      setState(() { _isExtracting = false; _progress = 1; });
      completer.complete();
    });

    _recorder!.start(100);
    final totalMs = (_video!.duration * 1000).round();
    final stepMs = totalMs ~/ 50;
    for (int i = 0; i < 50 && _isExtracting; i++) {
      await Future.delayed(Duration(milliseconds: stepMs));
      if (!mounted) return;
      setState(() => _progress = (i + 1) / 50);
    }
    _recorder!.stop();
    _video!.pause();
    await completer.future;
  }

  void _download() {
    if (_extractedBlob == null) return;
    final url = html.Url.createObjectUrlFromBlob(_extractedBlob!);
    final a = html.AnchorElement(href: url)..setAttribute('download', 'extracted_audio.${_format.toLowerCase()}')..style.display = 'none';
    html.document.body!.children.add(a); a.click(); a.remove(); html.Url.revokeObjectUrl(url);
  }

  @override
  void dispose() { _timeSub?.cancel(); _recorder?.stop(); _video?.pause(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Extraction'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(6)),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton.icon(
              onPressed: _selectVideo,
              icon: const Icon(Icons.videocam),
              label: Text(_videoFile?.name ?? 'Select Video'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardDark, foregroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          if (_videoFile != null) ...[
            const SizedBox(height: 8),
            Text('${_videoFile!.name} (${(_videoFile!.size / 1024 / 1024).toStringAsFixed(1)} MB)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          const Text('Format', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: _formats.map((f) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _format = f),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: _format == f ? AppColors.primary : AppColors.cardDark, borderRadius: BorderRadius.circular(8)),
                child: Text(f, textAlign: TextAlign.center, style: TextStyle(color: _format == f ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12)),
              ),
            ),
          ))).toList()),
          const SizedBox(height: 20),
          const Text('Quality', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: _qualities.map((q) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _quality = q),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: _quality == q ? AppColors.accent : AppColors.cardDark, borderRadius: BorderRadius.circular(8)),
                child: Text(q, textAlign: TextAlign.center, style: TextStyle(color: _quality == q ? Colors.black : AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 11)),
              ),
            ),
          ))).toList()),
          const SizedBox(height: 24),
          if (_isExtracting) ...[
            LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
            const SizedBox(height: 8),
            Text('Extracting... ${(_progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton.icon(
              onPressed: _videoFile == null ? null : (_isExtracting ? null : _extract),
              icon: _isExtracting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.transform),
              label: Text(_isExtracting ? 'Extracting...' : 'Extract Audio'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, disabledBackgroundColor: AppColors.cardDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          if (_extractedBlob != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Extracted as $_format ($_quality quality) — ${(_extractedBlob!.size / 1024).toStringAsFixed(1)} KB', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              onPressed: _download,
              icon: const Icon(Icons.file_download),
              label: Text('Download .${_format.toLowerCase()}'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ],
        ]),
      ),
    );
  }
}
