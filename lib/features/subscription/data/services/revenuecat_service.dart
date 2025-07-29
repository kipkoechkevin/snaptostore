import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/models/user_subscription.dart';
import '../../../../core/config/env_config.dart';

class RevenueCatService {
static RevenueCatService? _instance;
static RevenueCatService get instance => _instance ??= RevenueCatService._();

RevenueCatService._();

/// Initialize RevenueCat
Future<void> initialize() async {
  try {
    await Purchases.setLogLevel(LogLevel.info);
    
    PurchasesConfiguration configuration = PurchasesConfiguration(
      EnvConfig.revenueCatApiKey,
    );
    
    await Purchases.configure(configuration);
    print('RevenueCat initialized successfully');
  } catch (e) {
    print('Error initializing RevenueCat: $e');
  }
}

/// Set user ID for RevenueCat
Future<void> setUserId(String userId) async {
  try {
    await Purchases.logIn(userId);
  } catch (e) {
    print('Error setting RevenueCat user ID: $e');
  }
}

/// Get available offerings
Future<List<SubscriptionPlan>> getAvailableOfferings() async {
  try {
    final offerings = await Purchases.getOfferings();
    final currentOffering = offerings.current;
    
    if (currentOffering != null) {
      return currentOffering.availablePackages.map((package) {
        return _packageToSubscriptionPlan(package);
      }).toList();
    }
    
    return SubscriptionPlan.paidPlans;
  } catch (e) {
    print('Error getting offerings: $e');
    return SubscriptionPlan.paidPlans;
  }
}

/// Purchase a subscription
Future<UserSubscription?> purchaseSubscription(String productId) async {
  try {
    final offerings = await Purchases.getOfferings();
    final currentOffering = offerings.current;
    
    if (currentOffering != null) {
      final package = currentOffering.availablePackages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
      );
      
      final purchaserInfo = await Purchases.purchasePackage(package);
      return _customerInfoToUserSubscription(purchaserInfo.customerInfo);
    }
    
    return null;
  } catch (e) {
    print('Error purchasing subscription: $e');
    return null;
  }
}

/// Get current subscription status
Future<UserSubscription?> getCurrentSubscription(String userId) async {
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    return _customerInfoToUserSubscription(customerInfo);
  } catch (e) {
    print('Error getting current subscription: $e');
    return null;
  }
}

/// Restore purchases
Future<UserSubscription?> restorePurchases() async {
  try {
    final customerInfo = await Purchases.restorePurchases();
    return _customerInfoToUserSubscription(customerInfo);
  } catch (e) {
    print('Error restoring purchases: $e');
    return null;
  }
}

/// Check if user has active entitlement
Future<bool> hasActiveEntitlement(String entitlementId) async {
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    final entitlements = customerInfo.entitlements.all;
    
    return entitlements[entitlementId]?.isActive ?? false;
  } catch (e) {
    print('Error checking entitlement: $e');
    return false;
  }
}

/// Convert RevenueCat package to SubscriptionPlan
SubscriptionPlan _packageToSubscriptionPlan(Package package) {
  final product = package.storeProduct;
  final identifier = product.identifier;
  
  // ✅ Fix: Extract price from priceString
  double price = 0.0;
  try {
    // Remove currency symbols and extract numeric value
    final priceString = product.priceString.replaceAll(RegExp(r'[^\d.]'), '');
    price = double.tryParse(priceString) ?? 0.0;
  } catch (e) {
    print('Error parsing price: ${product.priceString}');
  }
  
  if (identifier.contains('monthly')) {
    return SubscriptionPlan.monthly.copyWith(
      price: price,
      revenueCatProductId: identifier,
    );
  } else if (identifier.contains('yearly')) {
    return SubscriptionPlan.yearly.copyWith(
      price: price,
      revenueCatProductId: identifier,
    );
  }
  
  return SubscriptionPlan.monthly;
}

/// Convert RevenueCat CustomerInfo to UserSubscription
UserSubscription _customerInfoToUserSubscription(CustomerInfo customerInfo) {
final activeEntitlements = customerInfo.entitlements.active;

if (activeEntitlements.isNotEmpty) {
  final entitlement = activeEntitlements.values.first;
  final productId = entitlement.productIdentifier;
  
  PlanType planType = PlanType.free;
  if (productId.contains('monthly')) {
    planType = PlanType.monthly;
  } else if (productId.contains('yearly')) {
    planType = PlanType.yearly;
  }
  
  return UserSubscription(
    userId: customerInfo.originalAppUserId,
    currentPlan: planType,
    status: SubscriptionStatus.active,
    // ✅ Fix: Safe date parsing
    expiresAt: _parseRevenueCatDate(entitlement.expirationDate),
    startedAt: _parseRevenueCatDate(entitlement.latestPurchaseDate),
    revenueCatCustomerId: customerInfo.originalAppUserId,
  );
}

return UserSubscription(
  userId: customerInfo.originalAppUserId,
  currentPlan: PlanType.free,
  status: SubscriptionStatus.free,
);
}

/// ✅ Add this helper method to RevenueCat service
DateTime? _parseRevenueCatDate(dynamic dateValue) {
if (dateValue == null) return null;

// If it's already a DateTime
if (dateValue is DateTime) {
  return dateValue;
}

// If it's a String, parse it
if (dateValue is String) {
  try {
    return DateTime.parse(dateValue);
  } catch (e) {
    print('Error parsing RevenueCat date: $dateValue, error: $e');
    return null;
  }
}

// If it's an int (timestamp)
if (dateValue is int) {
  try {
    return DateTime.fromMillisecondsSinceEpoch(dateValue);
  } catch (e) {
    print('Error parsing RevenueCat timestamp: $dateValue, error: $e');
    return null;
  }
}

print('Unknown date type in RevenueCat: ${dateValue.runtimeType}');
return null;
}

/// Get subscription details for display
Future<Map<String, dynamic>?> getSubscriptionDetails() async {
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    final activeEntitlements = customerInfo.entitlements.active;
    
    if (activeEntitlements.isNotEmpty) {
      final entitlement = activeEntitlements.values.first;
      
      return {
        'product_id': entitlement.productIdentifier,
        'is_active': entitlement.isActive,
        'will_renew': entitlement.willRenew,
        'purchase_date': entitlement.latestPurchaseDate,
        'expiration_date': entitlement.expirationDate,
        'is_sandbox': entitlement.isSandbox,
      };
    }
    
    return null;
  } catch (e) {
    print('Error getting subscription details: $e');
    return null;
  }
}

/// Check if subscription will renew
Future<bool> willRenew() async {
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    final activeEntitlements = customerInfo.entitlements.active;
    
    if (activeEntitlements.isNotEmpty) {
      final entitlement = activeEntitlements.values.first;
      return entitlement.willRenew;
    }
    
    return false;
  } catch (e) {
    print('Error checking if subscription will renew: $e');
    return false;
  }
}

/// Get customer info
Future<CustomerInfo?> getCustomerInfo() async {
  try {
    return await Purchases.getCustomerInfo();
  } catch (e) {
    print('Error getting customer info: $e');
    return null;
  }
}

/// ✅ Fix: Updated setAttributes method
Future<void> setUserAttributes(Map<String, String?> attributes) async {
  try {
    // Set attributes one by one since batch setting might not be available
    for (final entry in attributes.entries) {
      if (entry.value != null) {
        await Purchases.setEmail(entry.value!);
        // You can add more specific attribute setters based on your needs
      }
    }
  } catch (e) {
    print('Error setting user attributes: $e');
  }
}

/// Log out current user
Future<void> logOut() async {
  try {
    await Purchases.logOut();
  } catch (e) {
    print('Error logging out: $e');
  }
}
}