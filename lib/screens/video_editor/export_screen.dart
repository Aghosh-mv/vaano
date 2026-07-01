import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String _selectedQuality = '1080p';
  String _selectedFormat = 'MP4';
  String _selectedFps = '30fps';
  bool _isExporting = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: _isExporting ? _buildExporting() : _buildOptions(),
    );
  }

  Widget _buildOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
            child: const Column(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 56),
                SizedBox(height: 12),
                Text('Ready to Export', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Export your edited media', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Quality', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _qualityOption('720p', 'HD Ready', false),
          const SizedBox(height: 8),
          _qualityOption('1080p', 'Full HD', false),
          const SizedBox(height: 8),
          _qualityOption('4K', 'Ultra HD', true),
          const SizedBox(height: 24),
          const Text('Format', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            _formatChip('MP4', true), const SizedBox(width: 8),
            _formatChip('MOV', false), const SizedBox(width: 8),
            _formatChip('PNG', false),
          ]),
          const SizedBox(height: 24),
          const Text('Frame Rate', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            _fpsChip('24fps', false), const SizedBox(width: 8),
            _fpsChip('30fps', true), const SizedBox(width: 8),
            _fpsChip('60fps', false),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startExport,
              icon: const Icon(Icons.file_download),
              label: const Text('Export & Download'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExporting() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120, height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 8,
                  color: AppColors.primary,
                  backgroundColor: AppColors.cardLight,
                ),
                Text('${(_progress * 100).round()}%',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Exporting...', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$_selectedQuality · $_selectedFormat · $_selectedFps',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => setState(() => _isExporting = false),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _startExport() async {
    setState(() { _isExporting = true; _progress = 0; });
    final totalSteps = 20;
    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() => _progress = i / totalSteps);
    }
    if (!mounted) return;

    final content = 'vaano_export_${DateTime.now().millisecondsSinceEpoch}';
    final bytes = Uint8List.fromList(content.codeUnits);
    final blob = html.Blob([bytes], 'video/$_selectedFormat');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'vaano_export.${_selectedFormat.toLowerCase()}')
      ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export complete!'), backgroundColor: AppColors.success),
    );
    setState(() => _isExporting = false);
  }

  Widget _qualityOption(String label, String subtitle, bool isPremium) {
    final isSelected = _selectedQuality == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedQuality = label),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: label, groupValue: _selectedQuality,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedQuality = v!),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  if (isPremium) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.premium, borderRadius: BorderRadius.circular(4)),
                      child: const Text('PRO', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _formatChip(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFormat = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedFormat == label ? AppColors.primary : AppColors.cardDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            color: _selectedFormat == label ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          )),
        ),
      ),
    );
  }

  Widget _fpsChip(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFps = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedFps == label ? AppColors.primary : AppColors.cardDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            color: _selectedFps == label ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          )),
        ),
      ),
    );
  }
}
