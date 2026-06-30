import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/feature_item.dart';
import '../../widgets/section_header.dart';
import '../../widgets/category_grid.dart';

class AiStudioScreen extends StatelessWidget {
  const AiStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradientAi),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            const Text('Studio'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradientAi),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI-Powered Creativity',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Generate, edit, and enhance with AI',
                          style: TextStyle(color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'AI Tools'),
            const CategoryGrid(features: _tools),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.premium.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.workspace_premium, color: AppColors.premium, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unlock All AI Features',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        const Text('Get Premium for unlimited AI access',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/subscription'),
                    child: const Text('Upgrade', style: TextStyle(color: AppColors.premium, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static const List<FeatureItem> _tools = [
    FeatureItem(title: 'AI Image Gen', icon: Icons.image, color: Colors.blue, route: '/ai-image-generator', isPremium: true),
    FeatureItem(title: 'AI Avatar', icon: Icons.face, color: Colors.purple, route: '/ai-avatar', isPremium: true),
    FeatureItem(title: 'AI Face Swap', icon: Icons.swap_horiz, color: Colors.orange, route: '/ai-face-swap', isPremium: true),
    FeatureItem(title: 'AI Bg Replace', icon: Icons.wallpaper, color: Colors.teal, route: '/ai-bg-replace', isPremium: true),
    FeatureItem(title: 'AI Video Gen', icon: Icons.video_call, color: Colors.red, route: '/ai-video-generator', isPremium: true),
    FeatureItem(title: 'AI Highlights', icon: Icons.auto_awesome, color: Colors.amber, route: '/ai-highlights', isPremium: true),
    FeatureItem(title: 'AI Captions', icon: Icons.closed_caption, color: Colors.indigo, route: '/ai-captions'),
    FeatureItem(title: 'AI Translate', icon: Icons.translate, color: Colors.cyan, route: '/ai-translate', isPremium: true),
    FeatureItem(title: 'AI Voice Clone', icon: Icons.record_voice_over, color: Colors.pink, route: '/ai-voice-clone', isPremium: true),
  ];
}
