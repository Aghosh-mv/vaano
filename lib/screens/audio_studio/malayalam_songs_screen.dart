import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MalayalamSongsScreen extends StatefulWidget {
  const MalayalamSongsScreen({super.key});

  @override
  State<MalayalamSongsScreen> createState() => _MalayalamSongsScreenState();
}

class _MalayalamSongsScreenState extends State<MalayalamSongsScreen> {
  int _currentPlaying = -1;
  bool _isPlaying = false;
  double _progress = 0;
  String _search = '';
  html.AudioElement? _audio;

  final List<Map<String, String>> _songs = List.generate(16, (i) => {
    'title': 'Malayalam Song ${i + 1}',
    'artist': 'Artist ${i + 1}',
    'duration': '${3 + (i % 4)}:${10 + (i * 7) % 50}',
    'song': '${i + 1}',
  });

  List<Map<String, String>> get _filtered => _songs
      .where((s) => (s['title'] as String).toLowerCase().contains(_search.toLowerCase()))
      .toList();

  void _togglePlay(int index) {
    final origIndex = _songs.indexOf(_filtered[index]);
    if (_currentPlaying == origIndex && _isPlaying) {
      _audio?.pause();
      setState(() => _isPlaying = false);
      return;
    }
    _audio?.pause();
    final songNum = (origIndex % 16) + 1;
    _audio = html.AudioElement('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$songNum.mp3');
    _audio!.play();
    setState(() {
      _currentPlaying = origIndex;
      _isPlaying = true;
      _progress = 0;
    });
    _audio!.onTimeUpdate.listen((_) {
      if (!mounted || _audio == null) return;
      setState(() {
        _progress = _audio!.currentTime / (_audio!.duration > 0 ? _audio!.duration : 1);
      });
    });
    _audio!.onEnded.listen((_) {
      if (mounted) setState(() {
        _isPlaying = false;
        _progress = 1;
      });
    });
  }

  @override
  void dispose() {
    _audio?.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Malayalam Songs'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.premium,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search songs...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final origIndex = _songs.indexOf(_filtered[i]);
                final isPlaying = _currentPlaying == origIndex && _isPlaying;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPlaying ? AppColors.primary.withOpacity(0.15) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: isPlaying ? Border.all(color: AppColors.primary, width: 1) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.music_note, color: AppColors.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_filtered[i]['title'] as String,
                              style: TextStyle(
                                color: isPlaying ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              )),
                            Text(_filtered[i]['artist'] as String,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(_filtered[i]['duration'] as String,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                          color: isPlaying ? AppColors.primary : AppColors.textSecondary,
                        ),
                        onPressed: () => _togglePlay(i),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_currentPlaying >= 0 && _isPlaying)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.cardDark),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_songs[_currentPlaying]['title'] as String,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous, color: AppColors.textSecondary, size: 20),
                            onPressed: () {
                              final prev = (_currentPlaying - 1 + _songs.length) % _songs.length;
                              _audio?.pause();
                              _audio = html.AudioElement('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-${(prev % 16) + 1}.mp3');
                              _audio!.play();
                              setState(() {
                                _currentPlaying = prev;
                                _isPlaying = true;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.primary, size: 28),
                            onPressed: () {
                              if (_isPlaying) {
                                _audio?.pause();
                              } else {
                                _audio?.play();
                              }
                              setState(() => _isPlaying = !_isPlaying);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next, color: AppColors.textSecondary, size: 20),
                            onPressed: () {
                              final next = (_currentPlaying + 1) % _songs.length;
                              _audio?.pause();
                              _audio = html.AudioElement('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-${(next % 16) + 1}.mp3');
                              _audio!.play();
                              setState(() {
                                _currentPlaying = next;
                                _isPlaying = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
