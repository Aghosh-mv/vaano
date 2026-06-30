import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/video_processor.dart';

class TrimCutSplitScreen extends StatefulWidget {
  const TrimCutSplitScreen({super.key});

  @override
  State<TrimCutSplitScreen> createState() => _TrimCutSplitScreenState();
}

class _TrimCutSplitScreenState extends State<TrimCutSplitScreen> {
  final VideoProcessor _processor = VideoProcessor();
  html.VideoElement? _video;
  String _videoName = '';
  bool _hasVideo = false;
  RangeValues _trimRange = const RangeValues(0, 0);
  String _mode = 'Trim';
  double _maxDuration = 0;
  bool _isProcessing = false;
  double _progress = 0;

  final List<String> _modes = ['Trim', 'Cut', 'Split'];

  @override
  void initState() {
    super.initState();
    _processor.onProgress = () {
      if (mounted) setState(() => _progress = _processor.progress);
    };
  }

  @override
  void dispose() {
    _processor.dispose();
    super.dispose();
  }

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
          ..autoplay = false
          ..muted = true;
        _videoName = file.name ?? 'video.mp4';
        _video!.onLoadedMetadata.listen((_) {
          setState(() {
            _maxDuration = _video!.duration.toDouble();
            _trimRange = RangeValues(0, _maxDuration);
            _hasVideo = true;
          });
        });
      }
    });
  }

  Future<void> _previewTrim() async {
    if (_video == null) return;
    _video!.currentTime = _trimRange.start;
    _video!.play();
    final duration = (_trimRange.end - _trimRange.start).toInt();
    final delay = duration > 30 ? const Duration(seconds: 30) : Duration(seconds: duration);
    Future.delayed(delay, () {
      _video!.pause();
    });
  }

  Future<void> _processVideo() async {
    if (_video == null) return;
    setState(() => _isProcessing = true);

    try {
      switch (_mode) {
        case 'Trim':
          await _processor.trimVideo(
            video: _video!,
            startTime: _trimRange.start,
            endTime: _trimRange.end,
            outputFileName: _videoName,
          );
          break;
        case 'Cut':
          await _processor.trimVideo(
            video: _video!,
            startTime: _trimRange.start,
            endTime: _trimRange.end,
            outputFileName: '${_videoName}_cut',
          );
          break;
        case 'Split':
          await _processor.trimVideo(
            video: _video!,
            startTime: _trimRange.start,
            endTime: _trimRange.end,
            outputFileName: '${_videoName}_split',
          );
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_mode complete — video downloaded'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trim / Cut / Split'),
        backgroundColor: AppColors.surface,
      ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.cardDark,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.movie, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text(_videoName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                        Text('Duration: ${_maxDuration.toStringAsFixed(1)}s',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 8, top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => setState(() {
                        _hasVideo = false;
                        _video?.pause();
                      }),
                    ),
                  ),
                ],
              ),
            ),
          if (_hasVideo) ...[
            const SizedBox(height: 16),
            Text('$_mode Range: ${_trimRange.start.toStringAsFixed(1)}s - ${_trimRange.end.toStringAsFixed(1)}s',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
            RangeSlider(
              values: _trimRange,
              min: 0,
              max: _maxDuration,
              divisions: (_maxDuration * 2).toInt().clamp(1, 1000),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.cardLight,
              labels: RangeLabels(
                '${_trimRange.start.toStringAsFixed(1)}s',
                '${_trimRange.end.toStringAsFixed(1)}s',
              ),
              onChanged: _isProcessing ? null : (values) => setState(() => _trimRange = values),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _progress, backgroundColor: AppColors.cardLight, color: AppColors.primary),
              const SizedBox(height: 4),
              Text('Processing... ${(_progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _previewTrim,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processVideo,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text(_isProcessing ? 'Processing...' : 'Export $_mode'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Mode', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _modes.map((mode) => ChoiceChip(
                label: Text(mode),
                selected: _mode == mode,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.cardDark,
                labelStyle: TextStyle(
                  color: _mode == mode ? Colors.white : AppColors.textSecondary,
                ),
                onSelected: _isProcessing ? null : (val) => setState(() => _mode = mode),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
