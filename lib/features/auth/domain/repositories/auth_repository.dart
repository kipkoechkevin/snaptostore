import '../models/user_model.dart';

abstract class AuthRepository {
Future<UserModel?> signUp({
  required String email,
  required String password,
  required String fullName,
  String? businessType,
  String? businessName,
});

Future<UserModel?> signIn({
  required String email,
  required String password,
});

Future<void> signOut();

Future<UserModel?> getCurrentUser();

Future<UserModel?> updateUserProfile({
  String? fullName,
  String? businessType,
  String? businessName,
  String? profileImageUrl,
});

Future<void> resetPassword(String email);

Stream<UserModel?> get authStateChanges;
}