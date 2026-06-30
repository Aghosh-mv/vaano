import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/image_editor_service.dart';
import '../../widgets/image_viewer.dart';

class PhotoEditorScreen extends StatefulWidget {
  const PhotoEditorScreen({super.key});

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  final ImageEditorService _editor = ImageEditorService();

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
      appBar: AppBar(title: const Text('Photo Editor')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ImageViewer(
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
                        Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 48),
                        SizedBox(height: 16),
                        Text('Tap to Import Photo',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('JPG, PNG, WEBP supported',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_editor.currentImage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const Text('Tools', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _toolButton(Icons.crop, 'Crop', () => Navigator.pushNamed(context, '/crop-tool')),
                      const SizedBox(width: 12),
                      _toolButton(Icons.photo_filter, 'Filters', () => Navigator.pushNamed(context, '/filters')),
                      const SizedBox(width: 12),
                      _toolButton(Icons.text_fields, 'Text', () => Navigator.pushNamed(context, '/text-stickers')),
                      const SizedBox(width: 12),
                      _toolButton(Icons.file_download, 'Export', () => _exportImage(context)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _editor.currentImage == null
          ? FloatingActionButton(
              onPressed: _pickImage,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _pickImage() async {
    await _editor.pickAndLoadImage();
  }

  Future<void> _exportImage(BuildContext context) async {
    final bytes = await _editor.exportPng();
    if (bytes.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Export Image', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: AppColors.primary),
              title: const Text('PNG - Lossless', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _download(bytes, '${_editor.fileName ?? "vaano"}.png', 'image/png');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: AppColors.primary),
              title: const Text('JPG - Smaller File', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () async {
                Navigator.pop(context);
                final jpgBytes = await _editor.exportJpg();
                _download(jpgBytes, '${_editor.fileName ?? "vaano"}.jpg', 'image/jpeg');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _download(Uint8List bytes, String fileName, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Widget _toolButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
