import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/models/user_subscription.dart';
import '../../data/repositories/subscription_repository.dart';

// Subscription State
class SubscriptionState {
final UserSubscription? subscription;
final List<SubscriptionPlan> availablePlans;
final bool isLoading;
final String? error;
final bool isPurchasing;

const SubscriptionState({
  this.subscription,
  this.availablePlans = const [],
  this.isLoading = false,
  this.error,
  this.isPurchasing = false,
});

SubscriptionState copyWith({
  UserSubscription? subscription,
  List<SubscriptionPlan>? availablePlans,
  bool? isLoading,
  String? error,
  bool? isPurchasing,
}) {
  return SubscriptionState(
    subscription: subscription ?? this.subscription,
    availablePlans: availablePlans ?? this.availablePlans,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isPurchasing: isPurchasing ?? this.isPurchasing,
  );
}

// Helper getters
bool get isSubscribed => subscription?.isPremium ?? false;
bool get isFree => subscription?.isFree ?? true;
PlanType get currentPlan => subscription?.currentPlan ?? PlanType.free;
int get remainingProjects => subscription?.remainingProjects ?? 0;
}

// Subscription Notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
final SubscriptionRepository _repository;

SubscriptionNotifier(this._repository) : super(const SubscriptionState());

/// Load current subscription and available plans
Future<void> loadSubscription() async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final subscription = await _repository.getCurrentSubscription();
    final plans = await _repository.getAvailablePlans();

    state = state.copyWith(
      subscription: subscription,
      availablePlans: plans,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

/// Purchase a subscription plan
Future<bool> purchaseSubscription({
required SubscriptionPlan plan,
required Map<String, dynamic> userDetails, // ✅ Changed to Map<String, dynamic>
}) async {
state = state.copyWith(isPurchasing: true, error: null);

try {
  final subscription = await _repository.purchaseSubscription(
    plan: plan,
    userDetails: userDetails,
  );

  if (subscription != null) {
    state = state.copyWith(
      subscription: subscription,
      isPurchasing: false,
    );
    return true;
  }

  state = state.copyWith(
    isPurchasing: false,
    error: 'Purchase failed. Please try again.',
  );
  return false;
} catch (e) {
  state = state.copyWith(
    isPurchasing: false,
    error: e.toString(),
  );
  return false;
}
}

/// Cancel current subscription
Future<bool> cancelSubscription() async {
  try {
    final success = await _repository.cancelSubscription();
    if (success) {
      await loadSubscription(); // Refresh subscription state
    }
    return success;
  } catch (e) {
    state = state.copyWith(error: e.toString());
    return false;
  }
}

/// Restore purchases (mobile only)
Future<bool> restorePurchases() async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final subscription = await _repository.restorePurchases();
    if (subscription != null) {
      state = state.copyWith(
        subscription: subscription,
        isLoading: false,
      );
      return true;
    }

    state = state.copyWith(isLoading: false);
    return false;
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
    return false;
  }
}

/// Check if user can create project
Future<bool> canCreateProject() async {
  return await _repository.canCreateProject();
}

/// Check if user can access template
Future<bool> canAccessTemplate(bool isPremiumTemplate) async {
  return await _repository.canAccessTemplate(isPremiumTemplate);
}

/// Increment project usage
Future<void> incrementProjectUsage() async {
  try {
    final updatedSubscription = await _repository.incrementProjectUsage();
    state = state.copyWith(subscription: updatedSubscription);
  } catch (e) {
    print('Error incrementing project usage: $e');
  }
}

/// Clear error
void clearError() {
  state = state.copyWith(error: null);
}
}

// Providers
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
return SubscriptionRepository();
});

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
final repository = ref.read(subscriptionRepositoryProvider);
return SubscriptionNotifier(repository);
});

// Convenience providers
final isSubscribedProvider = Provider<bool>((ref) {
return ref.watch(subscriptionProvider).isSubscribed;
});

final currentPlanProvider = Provider<PlanType>((ref) {
return ref.watch(subscriptionProvider).currentPlan;
});

final remainingProjectsProvider = Provider<int>((ref) {
return ref.watch(subscriptionProvider).remainingProjects;
});

final availablePlansProvider = Provider<List<SubscriptionPlan>>((ref) {
return ref.watch(subscriptionProvider).availablePlans;
});