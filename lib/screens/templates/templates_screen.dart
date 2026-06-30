import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Instagram', 'YouTube', 'WhatsApp', 'Business', 'Birthday', 'Wedding'];

  final List<Map<String, dynamic>> _templates = [
    {'name': 'Instagram Story', 'icon': Icons.auto_stories, 'colors': [0xFF833AB4, 0xFFFD1D1D, 0xFFFCAF45], 'cat': 'Instagram'},
    {'name': 'YouTube Thumbnail', 'icon': Icons.videocam, 'colors': [0xFFFF0000, 0xFFCC0000], 'cat': 'YouTube'},
    {'name': 'WhatsApp Status', 'icon': Icons.message, 'colors': [0xFF25D366, 0xFF075E54], 'cat': 'WhatsApp'},
    {'name': 'Business Card', 'icon': Icons.badge, 'colors': [0xFF0077B5, 0xFF00A0DC], 'cat': 'Business'},
    {'name': 'Birthday Invite', 'icon': Icons.cake, 'colors': [0xFFFF69B4, 0xFFFF1493], 'cat': 'Birthday'},
    {'name': 'Wedding Invite', 'icon': Icons.favorite, 'colors': [0xFFE91E63, 0xFF9C27B0], 'cat': 'Wedding'},
    {'name': 'Quote Card', 'icon': Icons.format_quote, 'colors': [0xFF6C63FF, 0xFF00D9FF], 'cat': 'Instagram'},
    {'name': 'Promo Poster', 'icon': Icons.business, 'colors': [0xFFFF6584, 0xFFFF9800], 'cat': 'Business'},
  ];

  List<Map<String, dynamic>> get _filtered => _selectedCategory == 'All'
      ? _templates
      : _templates.where((t) => t['cat'] == _selectedCategory).toList();

  void _useTemplate(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Template Selected', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('$name template ready for editing', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final selected = _categories[i] == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = _categories[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(_categories[i], style: TextStyle(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w500, fontSize: 13,
                      )),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: GridView.builder(
                key: ValueKey(_selectedCategory),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
                ),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final t = _filtered[i];
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: (t['colors'] as List<int>).map((c) => Color(c)).toList(),
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t['icon'] as IconData, color: Colors.white, size: 36),
                        const SizedBox(height: 12),
                        Text(t['name'] as String,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => _useTemplate(t['name'] as String),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.25),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Use Template', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
