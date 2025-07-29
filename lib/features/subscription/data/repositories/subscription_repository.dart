import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/models/user_subscription.dart';
import '../services/payment_service.dart';
import '../services/revenuecat_service.dart';


class SubscriptionRepository {
final SupabaseClient _supabase = Supabase.instance.client;
final PaymentService _paymentService = PaymentService();
final RevenueCatService _revenueCatService = RevenueCatService.instance;

/// Get user's current subscription
Future<UserSubscription> getCurrentSubscription() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Try to get from Supabase first
    final response = await _supabase
        .from('user_subscriptions')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      return UserSubscription.fromJson(response);
    }

    // Fallback to RevenueCat
    final revenueCatSubscription = await _revenueCatService.getCurrentSubscription(userId);
    if (revenueCatSubscription != null) {
      await _saveSubscriptionToSupabase(revenueCatSubscription);
      return revenueCatSubscription;
    }

    // Return free subscription if none found
    return UserSubscription(
      userId: userId,
      currentPlan: PlanType.free,
      status: SubscriptionStatus.free,
    );
  } catch (e) {
    throw Exception('Failed to get current subscription: $e');
  }
}

/// Save subscription to Supabase
Future<void> _saveSubscriptionToSupabase(UserSubscription subscription) async {
  try {
    await _supabase.from('user_subscriptions').upsert({
      'user_id': subscription.userId,
      'current_plan': subscription.currentPlan.id,
      'status': subscription.status.name,
      'expires_at': subscription.expiresAt?.toIso8601String(),
      'started_at': subscription.startedAt?.toIso8601String(),
      'projects_used_this_month': subscription.projectsUsedThisMonth,
      'templates_used_this_month': subscription.templatesUsedThisMonth,
      'flutterwave_subscription_id': subscription.flutterwaveSubscriptionId,
      'revenuecat_customer_id': subscription.revenueCatCustomerId,
      'metadata': subscription.metadata,
      'updated_at': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    print('Error saving subscription to Supabase: $e');
  }
}

/// Update usage counters
Future<UserSubscription> incrementProjectUsage() async {
  try {
    final subscription = await getCurrentSubscription();
    final updatedSubscription = subscription.copyWith(
      projectsUsedThisMonth: subscription.projectsUsedThisMonth + 1,
    );

    await _saveSubscriptionToSupabase(updatedSubscription);
    return updatedSubscription;
  } catch (e) {
    throw Exception('Failed to increment project usage: $e');
  }
}

/// Reset monthly usage counters
Future<void> resetMonthlyUsage() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('user_subscriptions').update({
      'projects_used_this_month': 0,
      'templates_used_this_month': 0,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  } catch (e) {
    print('Error resetting monthly usage: $e');
  }
}

/// Check if user can create project
Future<bool> canCreateProject() async {
  try {
    final subscription = await getCurrentSubscription();
    return subscription.canCreateProject();
  } catch (e) {
    return false;
  }
}

/// Check if user can access premium template
Future<bool> canAccessTemplate(bool isPremiumTemplate) async {
  try {
    final subscription = await getCurrentSubscription();
    return subscription.canAccessTemplate(isPremiumTemplate);
  } catch (e) {
    return !isPremiumTemplate; // Allow basic templates on error
  }
}

/// Get available subscription plans
Future<List<SubscriptionPlan>> getAvailablePlans() async {
  try {
    // Try to get plans from RevenueCat (with real pricing)
    final revenueCatPlans = await _revenueCatService.getAvailableOfferings();
    if (revenueCatPlans.isNotEmpty) {
      return revenueCatPlans;
    }

    // Fallback to static plans
    return SubscriptionPlan.allPlans;
  } catch (e) {
    return SubscriptionPlan.allPlans;
  }
}

/// Purchase subscription
Future<UserSubscription?> purchaseSubscription({
required SubscriptionPlan plan,
required Map<String, dynamic> userDetails, // ✅ Changed to Map<String, dynamic>
}) async {
try {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');

  // Process payment
  final paymentResult = await _paymentService.processSubscription(
    context: userDetails['context'] as BuildContext, // ✅ Safe casting
    userEmail: userDetails['email'] as String,
    userName: userDetails['name'] as String,
    phoneNumber: userDetails['phone'] as String,
    plan: plan,
    userId: userId,
  );

  if (paymentResult.success) {
    // Create subscription record
    final subscription = UserSubscription(
      userId: userId,
      currentPlan: plan.type,
      status: SubscriptionStatus.active,
      startedAt: DateTime.now(),
      expiresAt: _calculateExpiryDate(plan),
      flutterwaveSubscriptionId: paymentResult.transactionId,
    );

    await _saveSubscriptionToSupabase(subscription);
    return subscription;
  }

  return null;
} catch (e) {
  throw Exception('Failed to purchase subscription: $e');
}
}

/// Cancel subscription
Future<bool> cancelSubscription() async {
  try {
    final subscription = await getCurrentSubscription();
    
    // Cancel with RevenueCat if applicable
    if (subscription.revenueCatCustomerId != null) {
      // RevenueCat handles cancellation through iOS/Android stores
      print('Cancellation handled by App Store/Play Store');
    }

    // Update local status
    final cancelledSubscription = subscription.copyWith(
      status: SubscriptionStatus.cancelled,
    );

    await _saveSubscriptionToSupabase(cancelledSubscription);
    return true;
  } catch (e) {
    print('Error canceling subscription: $e');
    return false;
  }
}

/// Restore purchases (for mobile)
Future<UserSubscription?> restorePurchases() async {
  try {
    final restoredSubscription = await _revenueCatService.restorePurchases();
    if (restoredSubscription != null) {
      await _saveSubscriptionToSupabase(restoredSubscription);
    }
    return restoredSubscription;
  } catch (e) {
    print('Error restoring purchases: $e');
    return null;
  }
}

/// Get subscription analytics
Future<Map<String, dynamic>> getSubscriptionAnalytics() async {
  try {
    final subscription = await getCurrentSubscription();
    final plan = subscription.plan;

    return {
      'current_plan': subscription.currentPlan.id,
      'is_premium': subscription.isPremium,
      'projects_used': subscription.projectsUsedThisMonth,
      'projects_remaining': subscription.remainingProjects,
      'days_until_expiry': subscription.expiresAt != null 
          ? subscription.expiresAt!.difference(DateTime.now()).inDays 
          : null,
      'plan_features': plan.features.map((f) => f.name).toList(),
    };
  } catch (e) {
    return {};
  }
}

DateTime _calculateExpiryDate(SubscriptionPlan plan) {
  final now = DateTime.now();
  return now.add(Duration(days: plan.billingPeriodMonths * 30));
}
}