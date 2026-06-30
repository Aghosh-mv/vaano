import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/image_editor_service.dart';
import '../../widgets/image_viewer.dart';

class CropToolScreen extends StatefulWidget {
  const CropToolScreen({super.key});

  @override
  State<CropToolScreen> createState() => _CropToolScreenState();
}

class _CropToolScreenState extends State<CropToolScreen> {
  final ImageEditorService _editor = ImageEditorService();
  final Rect _cropRect = Rect.fromLTWH(50, 50, 300, 300);
  double _rotation = 0;
  bool _isLoading = false;

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
      appBar: AppBar(
        title: const Text('Crop & Rotate'),
        actions: [
          if (_editor.currentImage != null)
            TextButton(
              onPressed: _applyCrop,
              child: const Text('Apply', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  ImageViewer(
                    image: _editor.currentImage,
                    placeholder: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('Tap to Import', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ),
                ],
              ),
            ),
          ),
          if (_editor.currentImage != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const Text('Transform', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _transformButton(Icons.rotate_left, 'Rotate L', () => _rotate(-90)),
                      const SizedBox(width: 12),
                      _transformButton(Icons.rotate_right, 'Rotate R', () => _rotate(90)),
                      const SizedBox(width: 12),
                      _transformButton(Icons.flip, 'Flip H', () => _flipH()),
                      const SizedBox(width: 12),
                      _transformButton(Icons.flip_to_back, 'Flip V', () => _flipV()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyCrop,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Crop Image'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await ImageEditorService().pickAndLoadImage();
    if (image != null) {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes != null) {
        await _editor.loadBytes(bytes.buffer.asUint8List());
      }
    }
  }

  Future<void> _rotate(double deg) async {
    setState(() => _isLoading = true);
    _rotation = (_rotation + deg) % 360;
    await _editor.rotateImage(deg);
    setState(() => _isLoading = false);
  }

  Future<void> _flipH() async {
    setState(() => _isLoading = true);
    await _editor.flipHorizontal();
    setState(() => _isLoading = false);
  }

  Future<void> _flipV() async {
    setState(() => _isLoading = true);
    await _editor.flipVertical();
    setState(() => _isLoading = false);
  }

  Future<void> _applyCrop() async {
    setState(() => _isLoading = true);
    await _editor.cropImage(
      _cropRect.left.toInt(),
      _cropRect.top.toInt(),
      _cropRect.width.toInt(),
      _cropRect.height.toInt(),
    );
    setState(() => _isLoading = false);
  }

  Widget _transformButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
