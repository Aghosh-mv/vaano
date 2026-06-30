import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import '../../theme/app_colors.dart';

class AiBackgroundReplacementScreen extends StatefulWidget {
  const AiBackgroundReplacementScreen({super.key});

  @override
  State<AiBackgroundReplacementScreen> createState() => _AiBackgroundReplacementScreenState();
}

class _AiBackgroundReplacementScreenState extends State<AiBackgroundReplacementScreen> {
  Uint8List? _imageBytes;
  Color _selectedColor = const Color(0xFF87CEEB);
  bool _isProcessing = false;
  Uint8List? _resultBytes;

  final _presets = [
    ('Beach', const Color(0xFF87CEEB)), ('City', const Color(0xFF2C3E50)),
    ('Forest', const Color(0xFF27AE60)), ('Space', const Color(0xFF1A1A2E)),
    ('Abstract', const Color(0xFF6C5CE7)), ('Sunset', const Color(0xFFFF6B35)),
  ];

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() { _imageBytes = result.files.first.bytes; _resultBytes = null; });
    }
  }

  Future<void> _replaceBg() async {
    if (_imageBytes == null) return;
    setState(() => _isProcessing = true);
    try {
      final original = img.decodeImage(_imageBytes!);
      if (original == null) { _showSnack('Failed to decode image'); setState(() => _isProcessing = false); return; }
      final overlay = img.Image.from(original);
      final borderW = (overlay.width * 0.2).round().clamp(1, overlay.width ~/ 2);
      final borderH = (overlay.height * 0.2).round().clamp(1, overlay.height ~/ 2);
      final cr = _selectedColor.red;
      final cg = _selectedColor.green;
      final cb = _selectedColor.blue;
      for (int y = 0; y < overlay.height; y++) {
        for (int x = 0; x < overlay.width; x++) {
          final inTop = y < borderH;
          final inBottom = y >= overlay.height - borderH;
          final inLeft = x < borderW;
          final inRight = x >= overlay.width - borderW;
          if (inTop || inBottom || inLeft || inRight) {
            final src = overlay.getPixel(x, y);
            final blend = 0.6;
            final nr = (src.r * (1 - blend) + cr * blend).round().clamp(0, 255);
            final ng = (src.g * (1 - blend) + cg * blend).round().clamp(0, 255);
            final nb = (src.b * (1 - blend) + cb * blend).round().clamp(0, 255);
            overlay.setPixelRgb(x, y, nr, ng, nb);
          }
        }
      }
      _resultBytes = Uint8List.fromList(img.encodePng(overlay));
    } catch (e) {
      _showSnack('Error: $e');
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Background Replacement'), backgroundColor: AppColors.surface,
        actions: [
          Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(6)),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20),
                  image: _resultBytes != null ? DecorationImage(image: MemoryImage(_resultBytes!), fit: BoxFit.cover) : null),
                child: _imageBytes == null
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.wallpaper, size: 64, color: AppColors.accent),
                        SizedBox(height: 12), Text('Tap to Select Photo', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                      ])
                    : Stack(fit: StackFit.expand, children: [
                        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(_resultBytes ?? _imageBytes!, fit: BoxFit.cover)),
                        if (_isProcessing) Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                          child: const Center(child: CircularProgressIndicator(color: AppColors.primary))),
                      ]),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              const Text('Background Color', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(height: 60, child: ListView.separated(
                scrollDirection: Axis.horizontal, itemCount: _presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final p = _presets[i];
                  final sel = _selectedColor == p.$2;
                  return GestureDetector(onTap: () => setState(() => _selectedColor = p.$2), child: Column(children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(color: p.$2, borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.cardLight, width: sel ? 2 : 1)),
                      child: sel ? const Icon(Icons.check, color: Colors.white, size: 18) : null),
                    const SizedBox(height: 2), Text(p.$1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                  ]));
                },
              )),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: _imageBytes == null || _isProcessing ? null : _replaceBg,
                icon: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isProcessing ? 'Processing...' : 'Replace Background'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              )),
            ]),
          ),
        ],
      ),
    );
  }
}
