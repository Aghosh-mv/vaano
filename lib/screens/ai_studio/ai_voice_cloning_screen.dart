import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_ai_service.dart';
import '../../theme/app_colors.dart';

class AiVoiceCloningScreen extends StatefulWidget {
  const AiVoiceCloningScreen({super.key});

  @override
  State<AiVoiceCloningScreen> createState() => _AiVoiceCloningScreenState();
}

class _AiVoiceCloningScreenState extends State<AiVoiceCloningScreen> {
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _audioFileName;
  final _textController = TextEditingController();
  bool _isLoading = false;
  String? _result;
  Timer? _timer;
  int _elapsedSeconds = 0;

  void _toggleRecording() {
    if (_isRecording) {
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        _hasRecording = true;
        _audioFileName = 'Voice recording (${_formatDuration(_elapsedSeconds)})';
        _result = null;
      });
    } else {
      setState(() {
        _elapsedSeconds = 0;
        _isRecording = true;
        _hasRecording = false;
        _result = null;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsedSeconds++);
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _generate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) { _showSnack('Enter text to speak'); return; }
    setState(() => _isLoading = true);
    final gen = await ApiAiService.generateCaptions(text);
    if (!mounted) return;
    setState(() { _isLoading = false; _result = gen; });
    if (gen == null || gen.startsWith('Error')) _showSnack(gen ?? 'Generation failed');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Voice Cloning'),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red.withOpacity(0.2) : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: _isRecording ? Colors.red : AppColors.accent,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRecording
                        ? _formatDuration(_elapsedSeconds)
                        : 'Tap to Record Voice',
                    style: TextStyle(
                      color: _isRecording ? Colors.red : AppColors.textPrimary,
                      fontSize: _isRecording ? 28 : 16,
                      fontWeight: FontWeight.w600,
                      fontFeatures: _isRecording ? const [FontFeature.tabularFigures()] : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRecording ? 'Recording... Tap to stop' : 'Record or upload a sample',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter text to speak with cloned voice...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generate,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.record_voice_over),
                label: Text(_isLoading ? 'Generating...' : 'Generate Cloned Voice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.record_voice_over, color: AppColors.accent, size: 20),
                        SizedBox(width: 8),
                        Text('Generated Audio Description', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_result!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
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