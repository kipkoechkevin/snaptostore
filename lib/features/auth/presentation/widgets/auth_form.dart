import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../core/core.dart';

class AuthForm extends ConsumerStatefulWidget {
final bool isSignUp;
final VoidCallback onToggleMode;

const AuthForm({
  super.key,
  required this.isSignUp,
  required this.onToggleMode,
});

@override
ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();
final _fullNameController = TextEditingController();
final _businessNameController = TextEditingController();

bool _obscurePassword = true;
bool _obscureConfirmPassword = true;
String? _selectedBusinessType;

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  _fullNameController.dispose();
  _businessNameController.dispose();
  super.dispose();
}

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  ref.read(authProvider.notifier).clearError();

  if (widget.isSignUp) {
    await ref.read(authProvider.notifier).signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      businessType: _selectedBusinessType,
      businessName: _businessNameController.text.trim().isEmpty 
          ? null 
          : _businessNameController.text.trim(),
    );
  } else {
    await ref.read(authProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}

@override
Widget build(BuildContext context) {
  final authState = ref.watch(authProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full Name Field (Sign Up only)
        if (widget.isSignUp) ...[
          TextFormField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],

        // Email Field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Password Field
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: widget.isSignUp ? TextInputAction.next : TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (widget.isSignUp && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),

        // Confirm Password Field (Sign Up only)
        if (widget.isSignUp) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],

        // Business Type Dropdown (Sign Up only)
        if (widget.isSignUp) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration: const InputDecoration(
              labelText: 'Business Type (Optional)',
              prefixIcon: Icon(Icons.business_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'thrift', child: Text('Thrift Boss')),
              DropdownMenuItem(value: 'boutique', child: Text('Boutique Boss')),
              DropdownMenuItem(value: 'beauty', child: Text('Beauty Boss')),
              DropdownMenuItem(value: 'handmade', child: Text('Handmade Boss')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedBusinessType = value;
              });
            },
          ),
        ],

        // Business Name Field (Sign Up only and if business type is selected)
        if (widget.isSignUp && _selectedBusinessType != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _businessNameController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Business Name (Optional)',
              prefixIcon: Icon(Icons.store_outlined),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Error Message
        if (authState.error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authState.error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Submit Button
        ElevatedButton(
          onPressed: authState.isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.isSignUp ? 'Create Account' : 'Sign In',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),

        const SizedBox(height: 16),

        // Toggle Auth Mode
        TextButton(
          onPressed: widget.onToggleMode,
          child: Text(
            widget.isSignUp
                ? 'Already have an account? Sign In'
                : 'Don\'t have an account? Sign Up',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Forgot Password (Sign In only)
        if (!widget.isSignUp) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showForgotPasswordDialog(context),
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: colorScheme.primary.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

void _showForgotPasswordDialog(BuildContext context) {
  final emailController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter your email address to receive a password reset link.'),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (emailController.text.trim().isNotEmpty) {
              await ref.read(authProvider.notifier).resetPassword(
                emailController.text.trim(),
              );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent!'),
                  ),
                );
              }
            }
          },
          child: const Text('Send Reset Link'),
        ),
      ],
    ),
  );
}
}