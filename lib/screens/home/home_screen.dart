import 'dart:convert';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/section_header.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/vaano_logo.dart';
import '../../services/guest_storage.dart';

const List<Map<String, dynamic>> _quickActions = [
  {'icon': Icons.add_photo_alternate_outlined, 'title': 'New Project', 'color': AppColors.primary},
  {'icon': Icons.photo_camera_back, 'title': 'Photo Editor', 'color': AppColors.secondary, 'route': '/photo-editor'},
  {'icon': Icons.videocam, 'title': 'Video Editor', 'color': AppColors.accent, 'route': '/video-editor'},
  {'icon': Icons.auto_awesome, 'title': 'AI Tools', 'color': Color(0xFFBB86FC), 'route': '/ai-studio'},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    final stored = GuestStorage.loadProjects();
    if (stored != null) {
      final list = json.decode(stored) as List;
      setState(() => _projects = list.cast<Map<String, dynamic>>());
    }
  }

  void _newProject() {
    final project = {
      'name': 'New Project ${_projects.length + 1}',
      'type': 'Photo',
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'created_at': DateTime.now().toIso8601String(),
    };
    _projects.insert(0, project);
    GuestStorage.saveProjects(json.encode(_projects));
    setState(() {});
  }

  void _deleteProject(int index) {
    _projects.removeAt(index);
    GuestStorage.saveProjects(json.encode(_projects));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Vaanologo(size: 36, showText: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: AppColors.premium),
            onPressed: () => Navigator.pushNamed(context, '/subscription'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Vaanologo(size: 72, showText: false, hasBackground: true),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Create Something\nAmazing Today', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('AI-powered photo & video editing', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/subscription'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                          child: const Text('Start Free'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.workspace_premium, color: Color(0xFFF2D06B), size: 36),
                        SizedBox(height: 4),
                        Text('PRO', style: TextStyle(color: Color(0xFFF2D06B), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Quick Actions'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _quickActions.map((action) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FeatureCard(
                      icon: action['icon'] as IconData,
                      title: action['title'] as String,
                      color: action['color'] as Color,
                      onTap: action['route'] != null
                          ? () => Navigator.pushNamed(context, action['route'] as String)
                          : _newProject,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'My Projects', actionText: 'View All'),
            _projects.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16)),
                      child: const Column(children: [
                        Icon(Icons.folder_open, color: AppColors.textSecondary, size: 48),
                        SizedBox(height: 12),
                        Text('No projects yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Tap "New Project" to get started', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ]),
                    ),
                  )
                : SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _projects.length,
                      itemBuilder: (_, i) {
                        final p = _projects[i];
                        return GestureDetector(
                          onLongPress: () => _deleteProject(i),
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                                  child: Center(
                                    child: Icon(p['type'] == 'Video' ? Icons.videocam : Icons.photo, color: AppColors.textSecondary, size: 40),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['name'] as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text('${p['type']} · ${p['date']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Explore Tools'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _toolChip(Icons.photo_filter, 'Filters'),
                  _toolChip(Icons.crop, 'Crop'),
                  _toolChip(Icons.auto_fix_high, 'Retouch'),
                  _toolChip(Icons.person_remove, 'Bg Remove'),
                  _toolChip(Icons.subtitles, 'Captions'),
                  _toolChip(Icons.music_note, 'Music'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _toolChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }
}
