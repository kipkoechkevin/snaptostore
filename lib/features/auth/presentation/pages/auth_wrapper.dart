import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../home/presentation/home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
const AuthWrapper({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authProvider);
  
  if (authState.isLoading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  if (authState.isAuthenticated) {
    return const HomeScreen();
  }
  
  return const LoginScreen();
}
}