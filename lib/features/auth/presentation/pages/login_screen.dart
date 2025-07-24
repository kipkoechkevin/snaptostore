import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';
import '../../../../core/core.dart';

class LoginScreen extends ConsumerStatefulWidget {
const LoginScreen({super.key});

@override
ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
bool _isSignUp = false;

void _toggleAuthMode() {
  setState(() {
    _isSignUp = !_isSignUp;
  });
  ref.read(authProvider.notifier).clearError();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Scaffold(
    // ✅ Remove any background color from Scaffold
    backgroundColor: Colors.transparent,
    body: Container(
      // ✅ Make container fill entire screen
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: colorScheme.gradient,
      ),
      child: SafeArea(
        // ✅ Add minimum: false to allow gradient to extend to bottom
        minimum: EdgeInsets.zero,
        child: SingleChildScrollView(
          // ✅ Add physics to prevent bounce
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            // ✅ Ensure content takes at least full height
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isSignUp
                        ? 'Join thousands of entrepreneurs'
                        : 'Sign in to continue creating',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: AuthForm(
                      isSignUp: _isSignUp,
                      onToggleMode: _toggleAuthMode,
                    ),
                  ),

                  // ✅ Add flexible spacer to push content up
                  const Flexible(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}