import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ExportShareScreen extends StatelessWidget {
  const ExportShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export & Share')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _exportOption('HD Export', '1080p · MP4', Icons.hd, AppColors.primary, false),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _exportOption('4K Export', 'Ultra HD', Icons.four_k, AppColors.premium, true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Share to',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _shareIcon(Icons.photo_camera, 'Instagram', const Color(0xFFE1306C)),
                const SizedBox(width: 12),
                _shareIcon(Icons.facebook, 'Facebook', const Color(0xFF1877F2)),
                const SizedBox(width: 12),
                _shareIcon(Icons.videocam, 'YouTube', const Color(0xFFFF0000)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _shareIcon(Icons.message, 'WhatsApp', const Color(0xFF25D366)),
                const SizedBox(width: 12),
                _shareIcon(Icons.music_note, 'TikTok', Colors.black),
                const SizedBox(width: 12),
                _shareIcon(Icons.more_horiz, 'More', AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Quick Actions',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _quickAction(Icons.content_copy, 'Copy to Clipboard'),
            const Divider(color: AppColors.cardLight),
            _quickAction(Icons.download, 'Save to Device'),
            const Divider(color: AppColors.cardLight),
            _quickAction(Icons.cloud_upload, 'Save to Cloud'),
            const Divider(color: AppColors.cardLight),
            _quickAction(Icons.share, 'Share Link'),
          ],
        ),
      ),
    );
  }

  Widget _exportOption(String title, String subtitle, IconData icon, Color color, bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          if (isPremium) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.premium,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('PRO', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _shareIcon(IconData icon, String name, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
