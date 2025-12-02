import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  bool isAuthenticated() {
    return getCurrentUser() != null;
  }

  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserResponse> updateEmail(String newEmail) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  String getErrorMessage(Object error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email ou senha incorretos';
        case 'Email not confirmed':
          return 'Email não confirmado. Verifique sua caixa de entrada';
        case 'User already registered':
          return 'Este email já está cadastrado';
        case 'Password should be at least 6 characters':
          return 'A senha deve ter pelo menos 6 caracteres';
        default:
          return error.message;
      }
    }
    return 'Erro ao processar requisição. Tente novamente';
  }
}
