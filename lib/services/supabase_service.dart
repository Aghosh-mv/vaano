import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  static const String _supabaseUrl = 'https://qxdzqgsxzsqwuqxtpiff.supabase.co';
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4ZHpxZ3N4enNxd3VxeHRwaWZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4MTY3MzksImV4cCI6MjA5ODM5MjczOX0.88L_p_2JC5QIBaolVHQVMN60m1QaUegJ_wT9CcuUDeI';

  Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _anonKey,
      debug: kDebugMode,
    );
    debugPrint('Supabase initialized');
  }

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;
  SupabaseStorageClient get storage => client.storage;

  User? get currentUser => auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String? get userId => currentUser?.id;
  String? get userEmail => currentUser?.email;
}
