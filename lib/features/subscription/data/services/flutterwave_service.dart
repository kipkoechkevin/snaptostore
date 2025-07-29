import 'dart:convert';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/subscription_plan.dart';
import '../../../../core/config/env_config.dart';

class FlutterwaveService {
static const String _baseUrl = 'https://api.flutterwave.com/v3';
final String _secretKey;
final String _publicKey;

FlutterwaveService()
    : _secretKey = EnvConfig.flutterwaveSecretKey,
      _publicKey = EnvConfig.flutterwavePublicKey;

/// Create a payment for subscription (requires BuildContext)
Future<ChargeResponse> initiateSubscriptionPayment({
required BuildContext context,
required String userEmail,
required String userName,
required String phoneNumber,
required SubscriptionPlan plan,
required String userId,
}) async {
try {
  final customer = Customer(
    name: userName,
    phoneNumber: phoneNumber,
    email: userEmail,
  );

  final flutterwave = Flutterwave(
    publicKey: _publicKey,
    currency: plan.currency,
    redirectUrl: 'https://snaptostore.app/payment-success',
    txRef: 'snaptostore_${plan.type.id}_${DateTime.now().millisecondsSinceEpoch}',
    amount: plan.price.toString(),
    customer: customer,
    paymentOptions: 'card,mobilemoneyghana,ussd,banktransfer,mpesa,mobilemoneykenya',
    customization: Customization(
      title: 'SnaptoStore Subscription',
      description: plan.description,
      logo: 'https://snaptostore.app/logo.png',
    ),
    isTestMode: EnvConfig.isDebug,
  );

  // ✅ Fix: Pass context as parameter to charge method
  final ChargeResponse response = await flutterwave.charge(context);
  return response;
} catch (e) {
  throw Exception('Failed to initiate payment: $e');
}
}

/// Alternative method without context (for direct API calls)
Future<Map<String, dynamic>?> initiateDirectPayment({
  required String userEmail,
  required String userName,
  required String phoneNumber,
  required SubscriptionPlan plan,
  required String userId,
}) async {
  try {
    final txRef = 'snaptostore_${plan.type.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    final response = await http.post(
      Uri.parse('$_baseUrl/payments'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tx_ref': txRef,
        'amount': plan.price,
        'currency': plan.currency,
        'redirect_url': 'https://snaptostore.app/payment-success',
        'payment_options': 'card,mobilemoney,ussd,banktransfer',
        'customer': {
          'email': userEmail,
          'phonenumber': phoneNumber,
          'name': userName,
        },
        'customizations': {
          'title': 'SnaptoStore Subscription',
          'description': plan.description,
          'logo': 'https://snaptostore.app/logo.png',
        },
        'meta': {
          'user_id': userId,
          'plan_type': plan.type.id,
        },
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  } catch (e) {
    print('Error initiating direct payment: $e');
    return null;
  }
}

/// Verify payment transaction
Future<PaymentVerificationResult> verifyTransaction(String transactionId) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/transactions/$transactionId/verify'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final isSuccessful = data['status'] == 'success' && 
                         data['data']['status'] == 'successful';
      
      return PaymentVerificationResult(
        isSuccessful: isSuccessful,
        transactionId: transactionId,
        amount: data['data']['amount']?.toDouble() ?? 0.0,
        currency: data['data']['currency'] ?? 'USD',
        customerEmail: data['data']['customer']['email'] ?? '',
        metadata: data['data'],
      );
    }
    
    return PaymentVerificationResult(
      isSuccessful: false,
      transactionId: transactionId,
      amount: 0.0,
      currency: 'USD',
      customerEmail: '',
    );
  } catch (e) {
    print('Error verifying transaction: $e');
    return PaymentVerificationResult(
      isSuccessful: false,
      transactionId: transactionId,
      amount: 0.0,
      currency: 'USD',
      customerEmail: '',
      error: e.toString(),
    );
  }
}

// ... rest of your methods stay the same

/// Create subscription plan on Flutterwave
Future<String?> createSubscriptionPlan(SubscriptionPlan plan) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/payment-plans'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': plan.price.toInt(),
        'name': plan.name,
        'interval': plan.billingPeriodMonths == 1 ? 'monthly' : 'yearly',
        'duration': plan.billingPeriodMonths,
        'currency': plan.currency,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['id'].toString();
    }
    return null;
  } catch (e) {
    print('Error creating subscription plan: $e');
    return null;
  }
}

/// Cancel subscription
Future<bool> cancelSubscription(String subscriptionId) async {
  try {
    final response = await http.put(
      Uri.parse('$_baseUrl/subscriptions/$subscriptionId/cancel'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error canceling subscription: $e');
    return false;
  }
}

/// Get subscription status
Future<Map<String, dynamic>?> getSubscriptionStatus(String subscriptionId) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    return null;
  } catch (e) {
    print('Error getting subscription status: $e');
    return null;
  }
}
}

/// Custom class for payment verification results
class PaymentVerificationResult {
final bool isSuccessful;
final String transactionId;
final double amount;
final String currency;
final String customerEmail;
final Map<String, dynamic>? metadata;
final String? error;

PaymentVerificationResult({
  required this.isSuccessful,
  required this.transactionId,
  required this.amount,
  required this.currency,
  required this.customerEmail,
  this.metadata,
  this.error,
});

@override
String toString() {
  return 'PaymentVerificationResult('
      'isSuccessful: $isSuccessful, '
      'transactionId: $transactionId, '
      'amount: $amount, '
      'currency: $currency, '
      'customerEmail: $customerEmail'
      ')';
}
}