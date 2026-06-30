import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../services/image_editor_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/image_viewer.dart';

class TextStickersScreen extends StatefulWidget {
  const TextStickersScreen({super.key});

  @override
  State<TextStickersScreen> createState() => _TextStickersScreenState();
}

class _TextStickersScreenState extends State<TextStickersScreen> {
  final ImageEditorService _editor = ImageEditorService();
  final TextEditingController _textController = TextEditingController();
  double _fontSize = 24;
  Color _textColor = Colors.white;
  double _posX = 50;
  double _posY = 50;
  bool _isLoading = false;
  ui.Image? _previewImage;

  static const List<double> fontSizes = [14, 24, 48];
  static const List<Color> presetColors = [
    Colors.white, Colors.red, Colors.yellow, AppColors.primary,
  ];

  @override
  void initState() {
    super.initState();
    _editor.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _editor.removeListener(() {});
    _editor.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text & Stickers')),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter text...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Size:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(width: 8),
                      ...fontSizes.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('${s.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          selected: _fontSize == s,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.cardDark,
                          onSelected: (_) => setState(() => _fontSize = s),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Color:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(width: 8),
                      ...presetColors.map((c) => GestureDetector(
                        onTap: () => setState(() => _textColor = c),
                        child: Container(
                          width: 28, height: 28,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _textColor == c ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _slider('X', _posX, (v) => setState(() => _posX = v)),
                  _slider('Y', _posY, (v) => setState(() => _posY = v)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyText,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Apply'),
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
    final image = await _editor.pickAndLoadImage();
    if (image != null && mounted) setState(() => _previewImage = null);
  }

  Future<void> _applyText() async {
    final wImage = _editor.workingImage;
    if (wImage == null || _textController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final text = _textController.text;
    final font = _fontSize == 14
        ? img.arial14
        : _fontSize == 24
            ? img.arial24
            : img.arial48;
    img.drawString(wImage, text,
        font: font,
        x: _posX.toInt(),
        y: _posY.toInt(),
        color: img.ColorRgb8(_textColor.red, _textColor.green, _textColor.blue));
    final bytes = Uint8List.fromList(img.encodePng(wImage));
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _previewImage = frame.image;
      _isLoading = false;
    });
    _editor.refresh();
  }

  Widget _slider(String label, double val, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Expanded(child: Slider(value: val, min: 0, max: 500, activeColor: AppColors.primary, onChanged: onChanged)),
      ],
    );
  }
}
