import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../domain/models/subscription_plan.dart';
import '../providers/subscription_provider.dart';

class PaymentSheet extends ConsumerStatefulWidget {
final SubscriptionPlan plan;

const PaymentSheet({
  super.key,
  required this.plan,
});

@override
ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet>
  with TickerProviderStateMixin {
late AnimationController _slideController;
late Animation<double> _slideAnimation;

final _formKey = GlobalKey<FormState>();
final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _phoneController = TextEditingController();

String _selectedPaymentMethod = 'card';
bool _agreeToTerms = false;
bool _isProcessing = false;

@override
void initState() {
  super.initState();
  
  _slideController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  
  _slideAnimation = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeOutCubic,
  ));

  _slideController.forward();
}

@override
void dispose() {
  _slideController.dispose();
  _nameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(_slideAnimation),
    child: Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanSummary(colorScheme),
                    const SizedBox(height: 24),
                    _buildUserInfoSection(),
                    const SizedBox(height: 24),
                    _buildPaymentMethodSection(colorScheme),
                    const SizedBox(height: 24),
                    _buildTrialInfo(colorScheme),
                    const SizedBox(height: 24),
                    _buildTermsAndConditions(),
                    const SizedBox(height: 32),
                    _buildPaymentButton(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildHandle() {
  return Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.only(top: 12, bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.textTertiary.withOpacity(0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

Widget _buildHeader(BusinessColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: colorScheme.gradient,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Your Purchase',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Secure payment powered by Flutterwave',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget _buildPlanSummary(BusinessColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: colorScheme.createOpacityGradient(),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: colorScheme.primary.withOpacity(0.2),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.plan.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Text(
              widget.plan.displayPrice,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.plan.billingText} • 7-day free trial',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.plan.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

Widget _buildUserInfoSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your Information',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Full Name',
          prefixIcon: Icon(Icons.person_outline),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter your full name';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email Address',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter your email';
          }
          if (!value!.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneController,
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          prefixIcon: Icon(Icons.phone_outlined),
          hintText: '+254712345678',
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter your phone number';
          }
          return null;
        },
      ),
    ],
  );
}

Widget _buildPaymentMethodSection(BusinessColorScheme colorScheme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Payment Method',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 16),
      _buildPaymentMethodOption(
        'card',
        'Credit/Debit Card',
        Icons.credit_card,
        'Visa, Mastercard, Amex',
        colorScheme,
      ),
      _buildPaymentMethodOption(
        'mpesa',
        'M-Pesa',
        Icons.phone_android,
        'Pay with M-Pesa mobile money',
        colorScheme,
      ),
      _buildPaymentMethodOption(
        'bank',
        'Bank Transfer',
        Icons.account_balance,
        'Direct bank transfer',
        colorScheme,
      ),
    ],
  );
}

Widget _buildPaymentMethodOption(
  String value,
  String title,
  IconData icon,
  String subtitle,
  BusinessColorScheme colorScheme,
) {
  final isSelected = _selectedPaymentMethod == value;
  
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: RadioListTile<String>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (newValue) {
        setState(() {
          _selectedPaymentMethod = newValue!;
        });
      },
      activeColor: colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: isSelected 
          ? colorScheme.primary.withOpacity(0.1) 
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? colorScheme.primary 
              : AppColors.textTertiary.withOpacity(0.3),
        ),
      ),
      secondary: Icon(
        icon,
        color: isSelected ? colorScheme.primary : AppColors.textTertiary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? colorScheme.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    ),
  );
}

Widget _buildTrialInfo(BusinessColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.info.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.info.withOpacity(0.3),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.info_outline,
          color: AppColors.info,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '7-Day Free Trial',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'You won\'t be charged until your trial ends. Cancel anytime.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTermsAndConditions() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Checkbox(
        value: _agreeToTerms,
        onChanged: (value) {
          setState(() {
            _agreeToTerms = value ?? false;
          });
        },
      ),
      Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: ref.watch(currentColorSchemeProvider).primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: ref.watch(currentColorSchemeProvider).primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildPaymentButton(BusinessColorScheme colorScheme) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: _agreeToTerms && !_isProcessing
          ? _handlePayment
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: _isProcessing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Start 7-Day Free Trial',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
    ),
  );
}

Future<void> _handlePayment() async {
if (!_formKey.currentState!.validate()) {
  return;
}

setState(() {
  _isProcessing = true;
});

try {
  // ✅ Fix: Create userDetails as Map<String, dynamic>
  final Map<String, dynamic> userDetails = {
    'context': context,
    'name': _nameController.text.trim(),
    'email': _emailController.text.trim(),
    'phone': _phoneController.text.trim(),
  };

  final success = await ref
      .read(subscriptionProvider.notifier)
      .purchaseSubscription(
        plan: widget.plan,
        userDetails: userDetails, // ✅ Now matches the expected type
      );

  if (success && mounted) {
    Navigator.pop(context);
    Navigator.pop(context); // Close pricing screen too
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Welcome to ${widget.plan.name}! Your free trial has started.',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${e.toString()}'),
        backgroundColor: AppColors.error,
      ),
    );
  }
} finally {
  if (mounted) {
    setState(() {
      _isProcessing = false;
    });
  }
}
}
}