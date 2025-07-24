import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/supabase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
final SupabaseClient _client = SupabaseService.client;

@override
Future<UserModel?> signUp({
  required String email,
  required String password,
  required String fullName,
  String? businessType,
  String? businessName,
}) async {
  try {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'business_type': businessType,
        'business_name': businessName,
      },
    );

    if (response.user != null) {
      // Create user profile in our custom table
      await _client.from('user_profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'business_type': businessType,
        'business_name': businessName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return await getCurrentUser();
    }

    return null;
  } catch (e) {
    throw Exception('Failed to sign up: $e');
  }
}

@override
Future<UserModel?> signIn({
  required String email,
  required String password,
}) async {
  try {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      return await getCurrentUser();
    }

    return null;
  } catch (e) {
    throw Exception('Failed to sign in: $e');
  }
}

@override
Future<void> signOut() async {
  try {
    await _client.auth.signOut();
  } catch (e) {
    throw Exception('Failed to sign out: $e');
  }
}

@override
Future<UserModel?> getCurrentUser() async {
  try {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  } catch (e) {
    return null;
  }
}

@override
Future<UserModel?> updateUserProfile({
  String? fullName,
  String? businessType,
  String? businessName,
  String? profileImageUrl,
}) async {
  try {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (businessType != null) updates['business_type'] = businessType;
    if (businessName != null) updates['business_name'] = businessName;
    if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

    await _client
        .from('user_profiles')
        .update(updates)
        .eq('id', user.id);

    return await getCurrentUser();
  } catch (e) {
    throw Exception('Failed to update profile: $e');
  }
}

@override
Future<void> resetPassword(String email) async {
  try {
    await _client.auth.resetPasswordForEmail(email);
  } catch (e) {
    throw Exception('Failed to reset password: $e');
  }
}

@override
Stream<UserModel?> get authStateChanges {
  return _client.auth.onAuthStateChange.asyncMap((state) async {
    if (state.event == AuthChangeEvent.signedIn) {
      return await getCurrentUser();
    } else if (state.event == AuthChangeEvent.signedOut) {
      return null;
    }
    return null;
  });
}
}