import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Auth State
class AuthState {
final UserModel? user;
final bool isLoading;
final String? error;
final bool isAuthenticated;

const AuthState({
  this.user,
  this.isLoading = false,
  this.error,
  this.isAuthenticated = false,
});

AuthState copyWith({
  UserModel? user,
  bool? isLoading,
  String? error,
  bool? isAuthenticated,
}) {
  return AuthState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
  );
}
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
final AuthRepository _authRepository;

AuthNotifier(this._authRepository) : super(const AuthState()) {
  _initializeAuth();
}

Future<void> _initializeAuth() async {
  state = state.copyWith(isLoading: true);
  
  try {
    final user = await _authRepository.getCurrentUser();
    state = state.copyWith(
      user: user,
      isAuthenticated: user != null,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

Future<void> signUp({
  required String email,
  required String password,
  required String fullName,
  String? businessType,
  String? businessName,
}) async {
  state = state.copyWith(isLoading: true, error: null);
  
  try {
    final user = await _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      businessType: businessType,
      businessName: businessName,
    );
    
    state = state.copyWith(
      user: user,
      isAuthenticated: user != null,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

Future<void> signIn({
  required String email,
  required String password,
}) async {
  state = state.copyWith(isLoading: true, error: null);
  
  try {
    final user = await _authRepository.signIn(
      email: email,
      password: password,
    );
    
    state = state.copyWith(
      user: user,
      isAuthenticated: user != null,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

Future<void> signOut() async {
  state = state.copyWith(isLoading: true);
  
  try {
    await _authRepository.signOut();
    state = const AuthState();
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

Future<void> updateProfile({
  String? fullName,
  String? businessType,
  String? businessName,
  String? profileImageUrl,
}) async {
  state = state.copyWith(isLoading: true, error: null);
  
  try {
    final user = await _authRepository.updateUserProfile(
      fullName: fullName,
      businessType: businessType,
      businessName: businessName,
      profileImageUrl: profileImageUrl,
    );
    
    state = state.copyWith(
      user: user,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

Future<void> resetPassword(String email) async {
  state = state.copyWith(isLoading: true, error: null);
  
  try {
    await _authRepository.resetPassword(email);
    state = state.copyWith(isLoading: false);
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

void clearError() {
  state = state.copyWith(error: null);
}
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
return AuthRepositoryImpl();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
return AuthNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserModel?>((ref) {
return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
return ref.watch(authProvider).isAuthenticated;
});