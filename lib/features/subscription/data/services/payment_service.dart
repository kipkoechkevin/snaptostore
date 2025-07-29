import 'package:flutter/material.dart';
import '../../domain/models/subscription_plan.dart';
import 'flutterwave_service.dart';
import 'revenuecat_service.dart';

class PaymentService {
final FlutterwaveService _flutterwaveService = FlutterwaveService();
final RevenueCatService _revenueCatService = RevenueCatService.instance;

/// Process subscription payment
Future<PaymentResult> processSubscription({
  required BuildContext context,
  required String userEmail,
  required String userName,  
  required String phoneNumber,
  required SubscriptionPlan plan,
  required String userId,
}) async {
  try {
    // Step 1: Try RevenueCat first (for App Store/Play Store)
    try {
      final subscription = await _revenueCatService.purchaseSubscription(
        plan.revenueCatProductId ?? '',
      );
      
      if (subscription != null) {
        return PaymentResult(
          success: true,
          subscriptionData: subscription,
          paymentMethod: 'app_store',
        );
      }
    } catch (e) {
      print('RevenueCat payment failed, trying Flutterwave: $e');
    }

    // Step 2: Fallback to Flutterwave (for web/direct payments)
    final flutterwaveResponse = await _flutterwaveService.initiateDirectPayment(
      userEmail: userEmail,
      userName: userName,
      phoneNumber: phoneNumber,
      plan: plan,
      userId: userId,
    );

    if (flutterwaveResponse != null && flutterwaveResponse['status'] == 'success') {
      // Verify the transaction
      final transactionId = flutterwaveResponse['data']['id']?.toString() ?? '';
      final verification = await _flutterwaveService.verifyTransaction(transactionId);

      if (verification.isSuccessful) {
        return PaymentResult(
          success: true,
          transactionId: transactionId,
          paymentMethod: 'flutterwave',
        );
      }
    }

    return PaymentResult(
      success: false,
      error: 'Payment was not completed successfully',
    );

  } catch (e) {
    return PaymentResult(
      success: false,
      error: 'Payment failed: $e',
    );
  }
}

/// Verify payment status
Future<bool> verifyPayment(String transactionId) async {
  final result = await _flutterwaveService.verifyTransaction(transactionId);
  return result.isSuccessful;
}
}

/// Payment result wrapper
class PaymentResult {
final bool success;
final String? transactionId;
final String? paymentMethod;
final dynamic subscriptionData;
final String? error;

PaymentResult({
  required this.success,
  this.transactionId,
  this.paymentMethod,
  this.subscriptionData,
  this.error,
});
}