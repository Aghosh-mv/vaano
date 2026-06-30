import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GreenScreenScreen extends StatefulWidget {
  const GreenScreenScreen({super.key});

  @override
  State<GreenScreenScreen> createState() => _GreenScreenScreenState();
}

class _GreenScreenScreenState extends State<GreenScreenScreen> {
  html.VideoElement? _video;
  html.ImageElement? _bgImage;
  String _videoName = '', _bgName = '';
  bool _hasVideo = false, _hasBackground = false;
  Color _keyColor = Colors.green;
  double _similarity = 0.4;
  String? _processedImageData;
  int _duration = 0;

  final _colorOptions = [Colors.green, const Color(0xFF00FF00), Colors.blue, Colors.red, Colors.yellow, Colors.white, Colors.black];

  void _pickVideo() {
    final input = html.FileUploadInputElement()..accept = 'video/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _video = html.VideoElement()..src = url..controls = false..autoplay = false;
        _videoName = file.name ?? 'video.mp4';
        _video!.onLoadedMetadata.listen((_) => setState(() { _hasVideo = true; _duration = _video!.duration.round(); }));
      }
    });
  }

  void _pickBackground() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final url = html.Url.createObjectUrl(file);
        _bgImage = html.ImageElement()..src = url;
        _bgName = file.name ?? 'bg.jpg';
        _bgImage!.onLoad.listen((_) => setState(() => _hasBackground = true));
      }
    });
  }

  void _processFrame() {
    if (_video == null || _bgImage == null) return;
    final canvas = html.CanvasElement(width: 640, height: 360);
    final ctx = canvas.context2D;
    ctx.drawImage(_video!, 0, 0);
    final imageData = ctx.getImageData(0, 0, 640, 360);
    final data = imageData.data;
    final threshold = (_similarity * 255).round();
    ctx.drawImage(_bgImage!, 0, 0);
    for (int i = 0; i < data.length; i += 4) {
      if ((data[i] - _keyColor.red).abs() + (data[i + 1] - _keyColor.green).abs() + (data[i + 2] - _keyColor.blue).abs() < threshold) {
        data[i] = data[i + 1] = data[i + 2] = 0; data[i + 3] = 0;
      }
    }
    ctx.putImageData(imageData, 0, 0);
    setState(() => _processedImageData = canvas.toDataUrl('image/png'));
  }

  void _pickColor() async {
    final color = await showDialog<Color>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Key Color', style: TextStyle(color: AppColors.textPrimary)),
        children: _colorOptions.map((c) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, c),
          child: Row(children: [
            Container(width: 24, height: 24, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 8),
            Text('#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}', style: const TextStyle(color: AppColors.textPrimary)),
          ]),
        )).toList(),
      ),
    );
    if (color != null) setState(() => _keyColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Green Screen'), backgroundColor: AppColors.surface),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_hasVideo)
            ElevatedButton.icon(
              onPressed: _pickVideo, icon: const Icon(Icons.video_file), label: const Text('Select Video'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          if (_hasVideo && !_hasBackground) const SizedBox(height: 8),
          if (!_hasBackground)
            ElevatedButton.icon(
              onPressed: _pickBackground, icon: const Icon(Icons.image), label: const Text('Select Background'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardLight),
            ),
          if (_hasVideo && _hasBackground) ...[
            if (_processedImageData != null)
              Container(
                height: 200,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.cardDark),
                child: Image.network(_processedImageData!, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48, color: AppColors.textSecondary)),
              )
            else
              Container(
                height: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.cardDark),
                child: Center(child: Text('$_videoName + $_bgName', style: const TextStyle(color: AppColors.textSecondary))),
              ),
            const SizedBox(height: 16),
            Row(children: [
              Text('Key: ', style: TextStyle(color: AppColors.textSecondary)),
              GestureDetector(
                onTap: _pickColor,
                child: Container(width: 32, height: 32, decoration: BoxDecoration(color: _keyColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white24))),
              ),
              const SizedBox(width: 16),
              Text('#${_keyColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Similarity', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Text(_similarity.toStringAsFixed(2), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              ]),
              Slider(value: _similarity, min: 0, max: 1, divisions: 100, activeColor: AppColors.primary, inactiveColor: AppColors.cardLight,
                onChanged: (v) => setState(() => _similarity = v)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processFrame,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Process Frame'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text('PREMIUM', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
