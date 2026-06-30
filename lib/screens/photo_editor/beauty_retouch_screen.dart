import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../services/image_editor_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/image_viewer.dart';

class BeautyRetouchScreen extends StatefulWidget {
  const BeautyRetouchScreen({super.key});

  @override
  State<BeautyRetouchScreen> createState() => _BeautyRetouchScreenState();
}

class _BeautyRetouchScreenState extends State<BeautyRetouchScreen> {
  final ImageEditorService _editor = ImageEditorService();
  ui.Image? _previewImage;
  bool _isLoading = false;
  String _selectedEffect = 'smooth';
  double _blurRadius = 3;

  @override
  void initState() {
    super.initState();
    _editor.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _editor.removeListener(() {});
    _editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beauty Retouch')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  ImageViewer(
                    image: _previewImage ?? _editor.currentImage,
                    placeholder: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12), Text('Tap to Import', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading) Container(
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
          if (_editor.currentImage != null) Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(children: [
              const Text('Effect', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                _effectChip('smooth', Icons.spa, 'Smooth'),
                const SizedBox(width: 8),
                _effectChip('eyes', Icons.visibility, 'Eyes'),
                const SizedBox(width: 8),
                _effectChip('teeth', Icons.face, 'Teeth'),
              ]),
              if (_selectedEffect == 'smooth') ...[
                const SizedBox(height: 16),
                _slider('Blur', _blurRadius, (v) => setState(() => _blurRadius = v)),
              ],
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _applyEffect,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(_selectedEffect == 'smooth' ? 'Apply Skin Smooth' : _selectedEffect == 'eyes' ? 'Apply Brighten Eyes' : 'Apply Whiten Teeth'),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _effectChip(String id, IconData icon, String label) {
    final selected = _selectedEffect == id;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _selectedEffect = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.3) : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Column(children: [
          Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontSize: 11)),
        ]),
      ),
    ));
  }

  Future<void> _pickImage() async {
    final image = await _editor.pickAndLoadImage();
    if (image != null && mounted) setState(() => _previewImage = null);
  }

  Future<void> _applyEffect() async {
    final wImage = _editor.workingImage;
    if (wImage == null) return;
    setState(() => _isLoading = true);
    if (_selectedEffect == 'smooth') _applySkinSmooth(wImage);
    else if (_selectedEffect == 'eyes') _applyBrightenEyes(wImage);
    else _applyWhitenTeeth(wImage);
    final bytes = Uint8List.fromList(img.encodePng(wImage));
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() { _previewImage = frame.image; _isLoading = false; });
    _editor.refresh();
  }

  void _applySkinSmooth(img.Image wImage) {
    final radius = _blurRadius.round();
    if (radius <= 0) return;
    final blurred = img.gaussianBlur(wImage, radius: radius);
    for (int y = 0; y < wImage.height; y++) {
      for (int x = 0; x < wImage.width; x++) {
        wImage.setPixel(x, y, blurred.getPixel(x, y));
      }
    }
  }

  void _applyBrightenEyes(img.Image wImage) {
    final cx = wImage.width ~/ 2, cy = wImage.height ~/ 2;
    final rw = wImage.width ~/ 5, rh = wImage.height ~/ 5;
    if (rw <= 0 || rh <= 0) return;
    for (int y = cy - rh; y < cy + rh; y++) {
      for (int x = cx - rw; x < cx + rw; x++) {
        if (x < 0 || x >= wImage.width || y < 0 || y >= wImage.height) continue;
        final p = wImage.getPixel(x, y);
        wImage.setPixelRgb(x, y, (p.r * 1.1).round().clamp(0, 255), (p.g * 1.1).round().clamp(0, 255), (p.b * 1.15).round().clamp(0, 255));
      }
    }
  }

  void _applyWhitenTeeth(img.Image wImage) {
    for (int y = 0; y < wImage.height; y++) {
      for (int x = 0; x < wImage.width; x++) {
        final p = wImage.getPixel(x, y);
        if (p.r > 180 && p.g > 140 && p.b < 160) {
          wImage.setPixelRgb(x, y, (p.r + 25).clamp(0, 255), (p.g + 25).clamp(0, 255), (p.b + 50).clamp(0, 255));
        }
      }
    }
  }

  Widget _slider(String label, double val, ValueChanged<double> onChanged) {
    return Row(children: [
      SizedBox(width: 60, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Expanded(child: Slider(value: val, min: 1, max: 10, activeColor: AppColors.primary, onChanged: onChanged)),
    ]);
  }
}
