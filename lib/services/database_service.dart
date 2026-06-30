import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class DatabaseService {
  final SupabaseClient _client;

  DatabaseService() : _client = SupabaseService().client;

  // Users
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _client.from('users').update(data).eq('id', uid);
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final response = await _client.from('users').select().eq('id', uid).single();
    return response as Map<String, dynamic>?;
  }

  // Projects
  Future<String> createProject(String uid, Map<String, dynamic> project) async {
    project['user_id'] = uid;
    project['created_at'] = DateTime.now().toIso8601String();
    project['updated_at'] = DateTime.now().toIso8601String();
    final response = await _client.from('projects').insert(project).select().single();
    return (response as Map<String, dynamic>)['id'] as String;
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    await _client.from('projects').update(data).eq('id', projectId);
  }

  Future<void> deleteProject(String projectId) async {
    await _client.from('projects').delete().eq('id', projectId);
  }

  Stream<List<Map<String, dynamic>>> streamUserProjects(String uid) {
    return _client
        .from('projects')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('updated_at', ascending: false);
  }

  Future<Map<String, dynamic>?> getProject(String projectId) async {
    final response = await _client.from('projects').select().eq('id', projectId).single();
    return response as Map<String, dynamic>?;
  }

  // Subscriptions
  Future<void> setSubscription(String uid, String plan, DateTime expiresAt) async {
    await _client.from('subscriptions').upsert({
      'user_id': uid,
      'plan': plan,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getSubscription(String uid) async {
    final response = await _client.from('subscriptions').select().eq('user_id', uid).single();
    return response as Map<String, dynamic>?;
  }

  Stream<Map<String, dynamic>?> streamSubscription(String uid) {
    return _client
        .from('subscriptions')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', uid)
        .map((data) => data.isNotEmpty ? data.first as Map<String, dynamic> : null);
  }
}
