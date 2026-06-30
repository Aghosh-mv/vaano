import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseStorageClient _storage;

  StorageService() : _storage = SupabaseService().storage;

  Future<String> uploadImage(String uid, Uint8List bytes, String fileName) async {
    final path = 'users/$uid/images/$fileName';
    await _storage.from('vaano').uploadBinary(path, bytes,
      fileOptions: const FileOptions(contentType: 'image/png'));
    return _storage.from('vaano').getPublicUrl(path);
  }

  Future<String> uploadVideo(String uid, Uint8List bytes, String fileName) async {
    final path = 'users/$uid/videos/$fileName';
    await _storage.from('vaano').uploadBinary(path, bytes,
      fileOptions: const FileOptions(contentType: 'video/mp4'));
    return _storage.from('vaano').getPublicUrl(path);
  }

  Future<String> uploadAudio(String uid, Uint8List bytes, String fileName) async {
    final path = 'users/$uid/audio/$fileName';
    await _storage.from('vaano').uploadBinary(path, bytes,
      fileOptions: const FileOptions(contentType: 'audio/webm'));
    return _storage.from('vaano').getPublicUrl(path);
  }

  Future<String> uploadProjectFile(String uid, String projectId, Uint8List bytes, String fileName) async {
    final path = 'users/$uid/projects/$projectId/$fileName';
    await _storage.from('vaano').uploadBinary(path, bytes);
    return _storage.from('vaano').getPublicUrl(path);
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.from('vaano').remove([path]);
    } catch (e) {
      debugPrint('Delete file error: $e');
    }
  }

  Future<List<String>> listFiles(String uid) async {
    try {
      final result = await _storage.from('vaano').list(path: 'users/$uid/images');
      return result.map((f) => f.name).toList();
    } catch (e) {
      debugPrint('List files error: $e');
      return [];
    }
  }
}
