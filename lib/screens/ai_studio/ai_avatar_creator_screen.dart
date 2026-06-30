import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_ai_service.dart';
import '../../theme/app_colors.dart';

class AiAvatarCreatorScreen extends StatefulWidget {
  const AiAvatarCreatorScreen({super.key});

  @override
  State<AiAvatarCreatorScreen> createState() => _AiAvatarCreatorScreenState();
}

class _AiAvatarCreatorScreenState extends State<AiAvatarCreatorScreen> {
  Uint8List? _photoBytes;
  final _descController = TextEditingController();
  String _selectedStyle = 'Realistic';
  bool _isLoading = false;
  Uint8List? _generatedImage;

  final _styles = ['Realistic', 'Anime', 'Cartoon', '3D', 'Pixel Art'];

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _photoBytes = result.files.first.bytes;
        _generatedImage = null;
      });
    }
  }

  Future<void> _generateAvatar() async {
    if (_photoBytes == null) { _showSnack('Upload a photo first'); return; }
    setState(() => _isLoading = true);
    final desc = _descController.text.trim();
    final prompt = '$_selectedStyle style avatar${desc.isNotEmpty ? ": $desc" : ''}';
    final image = await ApiAiService.generateImage(prompt);
    if (!mounted) return;
    setState(() { _isLoading = false; _generatedImage = image; });
    if (image == null) _showSnack('Image generation failed');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Avatar Creator'),
        backgroundColor: AppColors.surface,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(6)),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  image: _generatedImage != null
                      ? DecorationImage(image: MemoryImage(_generatedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _photoBytes == null && _generatedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.face, size: 64, color: AppColors.accent),
                          SizedBox(height: 16),
                          Text('Upload a Selfie', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          Text('Tap to select photo', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_photoBytes != null && _generatedImage == null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(_photoBytes!, fit: BoxFit.cover),
                            ),
                          if (_isLoading)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Choose Style', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _styles.map((style) {
                final isSelected = _selectedStyle == style;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStyle = style),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardLight),
                    ),
                    child: Text(style, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 14)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Describe your avatar (e.g. "wearing sunglasses")...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.description, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _photoBytes == null || _isLoading ? null : _generateAvatar,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Generating...' : 'Generate Avatar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            if (_generatedImage != null && !_isLoading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text('Avatar generated successfully!', style: TextStyle(color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
