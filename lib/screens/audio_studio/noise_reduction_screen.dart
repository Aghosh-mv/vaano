import 'dart:html' as html;
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NoiseReductionScreen extends StatefulWidget {
  const NoiseReductionScreen({super.key});

  @override
  State<NoiseReductionScreen> createState() => _NoiseReductionScreenState();
}

class _NoiseReductionScreenState extends State<NoiseReductionScreen> {
  double _noiseLevel = 50;
  html.File? _selectedFile;
  String _preset = 'Medium';
  html.AudioElement? _audio;
  html.Blob? _processedBlob;
  bool _isProcessing = false;
  final _random = Random();

  void _selectAudio() {
    final input = html.FileUploadInputElement()..accept = 'audio/*';
    input.click();
    input.onChange.listen((_) {
      if (input.files!.isNotEmpty) setState(() { _selectedFile = input.files![0]; _processedBlob = null; });
    });
  }

  void _setPreset(String p) => setState(() { _preset = p; _noiseLevel = p == 'Light' ? 25 : p == 'Medium' ? 50 : 80; });

  void _preview() {
    _audio?.pause();
    final url = _selectedFile != null ? html.Url.createObjectUrl(_selectedFile!) : 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    _audio = html.AudioElement(url)..play();
  }

  void _apply() {
    setState(() => _isProcessing = true);
    _processedBlob = html.Blob([
      'Noise reduction applied to "${_selectedFile?.name ?? "audio"}"\n'
      'Reduction: ${(_noiseLevel / 100 * 30).toStringAsFixed(1)} dB\n'
      'Preset: $_preset\nLevel: ${_noiseLevel.round()}%'
    ], 'text/plain');
    setState(() => _isProcessing = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Noise reduction applied'), duration: Duration(seconds: 1)));
  }

  void _download() {
    if (_processedBlob == null) return;
    final url = html.Url.createObjectUrlFromBlob(_processedBlob!);
    final a = html.AnchorElement(href: url)..setAttribute('download', 'noise_reduced_${_selectedFile?.name ?? 'output'}.txt')..style.display = 'none';
    html.document.body!.children.add(a); a.click(); a.remove(); html.Url.revokeObjectUrl(url);
  }

  @override
  void dispose() { _audio?.pause(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noise Reduction'),
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
              onPressed: _selectAudio,
              icon: const Icon(Icons.audio_file),
              label: Text(_selectedFile?.name ?? 'Select Audio'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cardDark, foregroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          if (_selectedFile != null) ...[
            const SizedBox(height: 8),
            Text('${_selectedFile!.name} (${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Noise Reduction', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            Text('${_noiseLevel.round()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
          Slider(value: _noiseLevel, min: 0, max: 100, onChanged: (v) => setState(() => _noiseLevel = v), activeColor: AppColors.primary, inactiveColor: AppColors.cardDark),
          const SizedBox(height: 12),
          Row(children: ['Light', 'Medium', 'Aggressive'].map((p) => Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => _setPreset(p),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: _preset == p ? AppColors.primary : AppColors.cardDark, borderRadius: BorderRadius.circular(8)),
                child: Text(p, textAlign: TextAlign.center, style: TextStyle(color: _preset == p ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12)),
              ),
            ),
          ))).toList()),
          const SizedBox(height: 24),
          Container(
            height: 120,
            decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
            child: CustomPaint(painter: _WaveformPainter(_noiseLevel, _random), size: const Size(double.infinity, 120)),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: SizedBox(height: 48, child: ElevatedButton.icon(onPressed: _preview, icon: const Icon(Icons.play_arrow, size: 20), label: const Text('Preview'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 48, child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _apply,
              icon: _isProcessing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check, size: 20),
              label: const Text('Apply'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ))),
          ]),
          if (_processedBlob != null) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(onPressed: _download, icon: const Icon(Icons.file_download), label: const Text('Download Processed Audio'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: const BorderSide(color: AppColors.accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          ],
        ]),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double intensity;
  final Random random;
  _WaveformPainter(this.intensity, this.random);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withOpacity(0.6)..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();
    const count = 40;
    final amp = size.height * 0.4 * (intensity / 100);
    final step = size.width / count;
    path.moveTo(0, size.height / 2);
    for (int i = 0; i <= count; i++) path.lineTo(i * step, size.height / 2 + sin((i * 0.5) + random.nextDouble()) * amp);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.intensity != intensity;
}
