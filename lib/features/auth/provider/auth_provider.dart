import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? error;

  AuthState({required this.status, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo)
      : super(AuthState(status: AuthStatus.initial)) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await SecureStorage.getAccessToken();
    state = AuthState(
      status: token != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _repo.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _repo.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      state = AuthState(status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: 'Registration failed');
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
