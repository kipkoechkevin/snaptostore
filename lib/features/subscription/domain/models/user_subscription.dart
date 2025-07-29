import 'package:equatable/equatable.dart';
import 'subscription_plan.dart';

enum SubscriptionStatus {
free,
active,
expired, 
cancelled,
inTrial,
pastDue,
}

class UserSubscription extends Equatable {
final String userId;
final PlanType currentPlan;
final SubscriptionStatus status;
final DateTime? expiresAt;
final DateTime? startedAt;
final int projectsUsedThisMonth;
final int templatesUsedThisMonth;
final String? flutterwaveSubscriptionId;
final String? revenueCatCustomerId;
final Map<String, dynamic>? metadata;

const UserSubscription({
  required this.userId,
  required this.currentPlan,
  required this.status,
  this.expiresAt,
  this.startedAt,
  this.projectsUsedThisMonth = 0,
  this.templatesUsedThisMonth = 0,
  this.flutterwaveSubscriptionId,
  this.revenueCatCustomerId,
  this.metadata,
});

// Helper methods
bool get isActive => status == SubscriptionStatus.active;
bool get isFree => currentPlan == PlanType.free;
bool get isPremium => !isFree && isActive;
bool get hasExpired => expiresAt?.isBefore(DateTime.now()) ?? false;
bool get isInTrial => status == SubscriptionStatus.inTrial;
bool get isCancelled => status == SubscriptionStatus.cancelled;
bool get isPastDue => status == SubscriptionStatus.pastDue;

/// Get the subscription plan details
SubscriptionPlan get plan {
  return SubscriptionPlan.allPlans.firstWhere(
    (p) => p.type == currentPlan,
    orElse: () => SubscriptionPlan.free,
  );
}

/// Check if user can create a new project
bool canCreateProject() {
  if (isPremium) return true;
  final limit = plan.projectLimit;
  return limit == null || projectsUsedThisMonth < limit;
}

/// Check if user can access a template
bool canAccessTemplate(bool isPremiumTemplate) {
  if (!isPremiumTemplate) return true;
  return isPremium;
}

/// Get remaining projects for free users (-1 means unlimited)
int get remainingProjects {
  if (isPremium) return -1; // unlimited
  final limit = plan.projectLimit ?? 0;
  return (limit - projectsUsedThisMonth).clamp(0, limit);
}

/// Get remaining templates for free users (-1 means unlimited)
int get remainingTemplates {
  if (isPremium) return -1; // unlimited
  final limit = plan.templatesLimit ?? 0;
  return (limit - templatesUsedThisMonth).clamp(0, limit);
}

/// Check if subscription is about to expire (within 7 days)
bool get isAboutToExpire {
  if (expiresAt == null || isPremium == false) return false;
  final now = DateTime.now();
  final daysUntilExpiry = expiresAt!.difference(now).inDays;
  return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
}

/// Get days until expiry
int get daysUntilExpiry {
  if (expiresAt == null) return 0;
  return expiresAt!.difference(DateTime.now()).inDays;
}

/// Check if user has specific feature
bool hasFeature(PlanFeature feature) {
  return plan.hasFeature(feature);
}

/// Get usage percentage for projects
double get projectUsagePercentage {
  if (isPremium) return 0.0; // No limits for premium
  final limit = plan.projectLimit ?? 1;
  return (projectsUsedThisMonth / limit).clamp(0.0, 1.0);
}

/// Get usage percentage for templates  
double get templateUsagePercentage {
  if (isPremium) return 0.0; // No limits for premium
  final limit = plan.templatesLimit ?? 1;
  return (templatesUsedThisMonth / limit).clamp(0.0, 1.0);
}

/// Check if usage limit is reached
bool get isProjectLimitReached {
  return !canCreateProject();
}

/// Get status display text
String get statusDisplayText {
  switch (status) {
    case SubscriptionStatus.free:
      return 'Free Plan';
    case SubscriptionStatus.active:
      return 'Active';
    case SubscriptionStatus.expired:
      return 'Expired';
    case SubscriptionStatus.cancelled:
      return 'Cancelled';
    case SubscriptionStatus.inTrial:
      return 'Trial';
    case SubscriptionStatus.pastDue:
      return 'Payment Due';
  }
}

/// Get subscription summary for display
String get subscriptionSummary {
  if (isFree) {
    return 'Free Plan • ${remainingProjects >= 0 ? '$remainingProjects projects left' : 'Unlimited projects'}';
  }
  
  if (isPremium) {
    final expiry = expiresAt;
    if (expiry != null) {
      final daysLeft = daysUntilExpiry;
      if (daysLeft > 0) {
        return '${plan.name} • Expires in $daysLeft days';
      } else {
        return '${plan.name} • Expired';
      }
    }
    return '${plan.name} • Active';
  }
  
  return statusDisplayText;
}

UserSubscription copyWith({
  String? userId,
  PlanType? currentPlan,
  SubscriptionStatus? status,
  DateTime? expiresAt,
  DateTime? startedAt,
  int? projectsUsedThisMonth,
  int? templatesUsedThisMonth,
  String? flutterwaveSubscriptionId,
  String? revenueCatCustomerId,
  Map<String, dynamic>? metadata,
}) {
  return UserSubscription(
    userId: userId ?? this.userId,
    currentPlan: currentPlan ?? this.currentPlan,
    status: status ?? this.status,
    expiresAt: expiresAt ?? this.expiresAt,
    startedAt: startedAt ?? this.startedAt,
    projectsUsedThisMonth: projectsUsedThisMonth ?? this.projectsUsedThisMonth,
    templatesUsedThisMonth: templatesUsedThisMonth ?? this.templatesUsedThisMonth,
    flutterwaveSubscriptionId: flutterwaveSubscriptionId ?? this.flutterwaveSubscriptionId,
    revenueCatCustomerId: revenueCatCustomerId ?? this.revenueCatCustomerId,
    metadata: metadata ?? this.metadata,
  );
}

@override
List<Object?> get props => [
  userId,
  currentPlan,
  status,
  expiresAt,
  startedAt,
  projectsUsedThisMonth,
  templatesUsedThisMonth,
  flutterwaveSubscriptionId,
  revenueCatCustomerId,
  metadata,
];

/// Convert to JSON for Supabase
Map<String, dynamic> toJson() {
  return {
    'user_id': userId,
    'current_plan': currentPlan.id,
    'status': status.name,
    'expires_at': expiresAt?.toIso8601String(),
    'started_at': startedAt?.toIso8601String(),
    'projects_used_this_month': projectsUsedThisMonth,
    'templates_used_this_month': templatesUsedThisMonth,
    'flutterwave_subscription_id': flutterwaveSubscriptionId,
    'revenuecat_customer_id': revenueCatCustomerId,
    'metadata': metadata,
  };
}

/// Create from JSON (Supabase response)
static UserSubscription fromJson(Map<String, dynamic> json) {
  return UserSubscription(
    userId: json['user_id'] as String,
    currentPlan: PlanType.values.firstWhere(
      (p) => p.id == json['current_plan'],
      orElse: () => PlanType.free,
    ),
    status: SubscriptionStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => SubscriptionStatus.free,
    ),
    expiresAt: json['expires_at'] != null 
        ? DateTime.parse(json['expires_at']) 
        : null,
    startedAt: json['started_at'] != null 
        ? DateTime.parse(json['started_at']) 
        : null,
    projectsUsedThisMonth: json['projects_used_this_month'] ?? 0,
    templatesUsedThisMonth: json['templates_used_this_month'] ?? 0,
    flutterwaveSubscriptionId: json['flutterwave_subscription_id'],
    revenueCatCustomerId: json['revenuecat_customer_id'],
    metadata: json['metadata'] as Map<String, dynamic>?,
  );
}

/// Create a default free subscription
static UserSubscription createFree(String userId) {
  return UserSubscription(
    userId: userId,
    currentPlan: PlanType.free,
    status: SubscriptionStatus.free,
  );
}

/// Create a premium subscription
static UserSubscription createPremium({
  required String userId,
  required PlanType planType,
  required DateTime startDate,
  required DateTime expiryDate,
  String? flutterwaveId,
  String? revenueCatId,
}) {
  return UserSubscription(
    userId: userId,
    currentPlan: planType,
    status: SubscriptionStatus.active,
    startedAt: startDate,
    expiresAt: expiryDate,
    flutterwaveSubscriptionId: flutterwaveId,
    revenueCatCustomerId: revenueCatId,
  );
}

/// Create trial subscription
static UserSubscription createTrial({
  required String userId,
  required PlanType planType,
  int trialDays = 7,
}) {
  final now = DateTime.now();
  return UserSubscription(
    userId: userId,
    currentPlan: planType,
    status: SubscriptionStatus.inTrial,
    startedAt: now,
    expiresAt: now.add(Duration(days: trialDays)),
  );
}

@override
String toString() {
  return 'UserSubscription('
      'userId: $userId, '
      'plan: ${currentPlan.id}, '
      'status: ${status.name}, '
      'expires: $expiresAt, '
      'projects: $projectsUsedThisMonth'
      ')';
}
}

/// Extension methods for convenience
extension UserSubscriptionExtensions on UserSubscription {
/// Get color for status display
String get statusColor {
  switch (status) {
    case SubscriptionStatus.active:
    case SubscriptionStatus.inTrial:
      return '#10B981'; // Green
    case SubscriptionStatus.expired:
    case SubscriptionStatus.pastDue:
      return '#EF4444'; // Red
    case SubscriptionStatus.cancelled:
      return '#F59E0B'; // Orange
    case SubscriptionStatus.free:
      return '#6B7280'; // Gray
  }
}

/// Check if user should see upgrade prompts
bool get shouldShowUpgradePrompts {
  return isFree || isAboutToExpire || isProjectLimitReached;
}

/// Get upgrade urgency level (0-3, 3 being most urgent)
int get upgradeUrgencyLevel {
  if (isPremium && !isAboutToExpire) return 0;
  if (isFree && !isProjectLimitReached) return 1;
  if (isFree && isProjectLimitReached) return 2;
  if (isAboutToExpire || hasExpired) return 3;
  return 0;
}

/// Get appropriate upgrade message
String get upgradeMessage {
  if (isProjectLimitReached) {
    return 'You\'ve reached your project limit. Upgrade to create unlimited projects!';
  }
  if (isAboutToExpire) {
    return 'Your subscription expires in $daysUntilExpiry days. Renew now to keep your premium features!';
  }
  if (hasExpired) {
    return 'Your subscription has expired. Upgrade to restore premium features!';
  }
  if (isFree) {
    return 'Upgrade to Pro for unlimited projects and premium templates!';
  }
  return '';
}
}