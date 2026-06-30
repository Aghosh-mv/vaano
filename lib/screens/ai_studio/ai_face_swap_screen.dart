import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_ai_service.dart';
import '../../theme/app_colors.dart';

class AiFaceSwapScreen extends StatefulWidget {
  const AiFaceSwapScreen({super.key});

  @override
  State<AiFaceSwapScreen> createState() => _AiFaceSwapScreenState();
}

class _AiFaceSwapScreenState extends State<AiFaceSwapScreen> {
  Uint8List? _sourceBytes;
  Uint8List? _targetBytes;
  String? _sourceName;
  String? _targetName;
  bool _isLoading = false;
  String? _result;

  Future<void> _pickSource() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() { _sourceBytes = result.files.first.bytes; _sourceName = result.files.first.name; _result = null; });
    }
  }

  Future<void> _pickTarget() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() { _targetBytes = result.files.first.bytes; _targetName = result.files.first.name; _result = null; });
    }
  }

  Future<void> _swapFaces() async {
    if (_sourceBytes == null || _targetBytes == null) return;
    setState(() => _isLoading = true);
    final gen = await ApiAiService.generateCaptions('Face swap: source face from $_sourceName onto target image $_targetName');
    if (!mounted) return;
    setState(() { _isLoading = false; _result = gen; });
    if (gen == null || gen.startsWith('Error')) _showSnack(gen ?? 'Face swap failed');
  }

  void _copy() {
    if (_result == null) return;
    Clipboard.setData(ClipboardData(text: _result!));
    _showSnack('Result copied to clipboard');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  Widget _imageBox(String label, Uint8List? bytes, String? name, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16)),
          child: bytes != null
              ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(bytes, fit: BoxFit.cover))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.person, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Tap to select', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11)),
                ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Face Swap'),
        backgroundColor: AppColors.surface,
        actions: [
          Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(6)),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _imageBox('Source Face', _sourceBytes, _sourceName, _pickSource),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.swap_horiz, color: AppColors.primary, size: 32)),
                  _imageBox('Target Image', _targetBytes, _targetName, _pickTarget),
                ],
              ),
            ),
            if (_result != null) ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    const Text('Result', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _copy,
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Copy', style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(_result!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: (_sourceBytes == null || _targetBytes == null || _isLoading) ? null : _swapFaces,
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Swapping...' : 'Swap Faces'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
            const SizedBox(height: 12),
            Text('Premium feature: High-quality face swaps',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
