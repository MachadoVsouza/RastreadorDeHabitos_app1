import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseAuthService _authService;

  AuthNotifier(this._authService)
      : super(AuthState(status: AuthStatus.initial)) {
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  void _checkAuthStatus() {
    final user = _authService.getCurrentUser();
    if (user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((authState) {
      final user = authState.session?.user;
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        return true;
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Erro ao fazer login',
        );
        return false;
      }
    } catch (e) {
      final errorMessage = _authService.getErrorMessage(e);
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        return true;
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Erro ao criar conta',
        );
        return false;
      }
    } catch (e) {
      final errorMessage = _authService.getErrorMessage(e);
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _authService.signOut();
      state = AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      final errorMessage = _authService.getErrorMessage(e);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: errorMessage,
      );
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: _authService.getErrorMessage(e),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
});
