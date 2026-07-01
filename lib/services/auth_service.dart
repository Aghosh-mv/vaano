import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  GoTrueClient? _auth;

  AuthService() {
    try {
      _auth = SupabaseService().auth;
      _auth!.onAuthStateChange.listen((data) {
        debugPrint('Auth state: ${data.event} - ${data.session?.user.email ?? "none"}');
      });
    } catch (e) {
      debugPrint('AuthService: Supabase not ready yet, using guest mode: $e');
    }
  }

  bool get isReady => _auth != null;
  User? get currentUser => _auth?.currentUser;
  bool get isLoggedIn => _auth?.currentUser != null;
  String? get userId => _auth?.currentUser?.id;
  String? get userEmail => _auth?.currentUser?.email;
  String? get userName => _auth?.currentUser?.userMetadata?['name'] as String?;

  Stream<AuthState> get authState {
    try {
      return _auth?.onAuthStateChange ?? const Stream.empty();
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<AuthResult> signUp(String email, String password, String name) async {
    if (_auth == null) return AuthResult(success: false, error: 'Auth not ready');
    try {
      final response = await _auth!.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name},
      );
      if (response.user != null) {
        await _createUserProfile(response.user!);
        return AuthResult(success: true, user: response.user);
      }
      return AuthResult(success: false, error: response.session?.accessToken == null ? 'Email verification required' : 'Signup failed');
    } on AuthException catch (e) {
      return AuthResult(success: false, error: _parseError(e.message));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  Future<AuthResult> signIn(String email, String password) async {
    if (_auth == null) return AuthResult(success: false, error: 'Auth not ready');
    try {
      final response = await _auth!.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult(success: true, user: response.user);
    } on AuthException catch (e) {
      return AuthResult(success: false, error: _parseError(e.message));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    if (_auth == null) return AuthResult(success: false, error: 'Auth not ready');
    try {
      final response = await _auth!.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://vaano-v1.vercel.app/auth/callback',
      );
      return AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult(success: false, error: _parseError(e.message));
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    try { await _auth?.signOut(); } catch (_) {}
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth!.resetPasswordForEmail(email.trim(),
        redirectTo: 'https://vaano-v1.vercel.app/auth/callback');
    } catch (_) {}
  }

  Future<void> _createUserProfile(User user) async {
    try {
      await SupabaseService().client.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'] ?? '',
        'plan': 'free',
        'storage_used': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Profile creation error: $e');
    }
  }

  String _parseError(String message) {
    if (message.contains('Email not confirmed')) return 'Check your email for confirmation';
    if (message.contains('Invalid login credentials')) return 'Invalid email or password';
    if (message.contains('User already registered')) return 'Email already registered';
    if (message.contains('Password should be')) return 'Password must be at least 6 characters';
    if (message.contains('Invalid email')) return 'Invalid email address';
    return message;
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  AuthResult({required this.success, this.user, this.error});
}
