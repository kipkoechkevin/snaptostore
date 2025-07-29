import 'package:equatable/equatable.dart';

enum PlanType {
free('free'),
monthly('monthly_pro'), 
yearly('yearly_pro');

const PlanType(this.id);
final String id;
}

enum PlanFeature {
basicTemplates,
premiumTemplates,
unlimitedProjects,
priorityProcessing,
customBackgrounds,
noWatermark,
aiBackgrounds,
batchProcessing,
cloudStorage,
analytics,
}

class SubscriptionPlan extends Equatable {
final PlanType type;
final String name;
final String description;
final double price;
final String currency;
final int billingPeriodMonths;
final List<PlanFeature> features;
final int? projectLimit; // null = unlimited
final int? templatesLimit; // null = unlimited
final bool isPopular;
final String? flutterwavePlanId;
final String? revenueCatProductId;

const SubscriptionPlan({
  required this.type,
  required this.name,
  required this.description,
  required this.price,
  required this.currency,
  required this.billingPeriodMonths,
  required this.features,
  this.projectLimit,
  this.templatesLimit,
  this.isPopular = false,
  this.flutterwavePlanId,
  this.revenueCatProductId,
});

// Predefined plans for Kenya market
  static const SubscriptionPlan free = SubscriptionPlan(
type: PlanType.free,
name: 'SnaptoStore Free',
description: 'Perfect for trying out the app',
price: 0,
currency: 'USD',
billingPeriodMonths: 0,
features: [
  PlanFeature.basicTemplates,
],
projectLimit: 5, // 5 projects per month
templatesLimit: 10, // 10 basic templates
);


static const SubscriptionPlan monthly = SubscriptionPlan(
type: PlanType.monthly,
name: 'SnaptoStore Pro',
description: 'Full access to all features',
price: 9.99, // $9.99/month
currency: 'USD', 
billingPeriodMonths: 1,
features: [
  PlanFeature.basicTemplates,
  PlanFeature.premiumTemplates,
  PlanFeature.unlimitedProjects,
  PlanFeature.priorityProcessing,
  PlanFeature.customBackgrounds,
  PlanFeature.noWatermark,
  PlanFeature.aiBackgrounds,
  PlanFeature.batchProcessing,
],
isPopular: true,
flutterwavePlanId: 'snaptostore_monthly_usd',
revenueCatProductId: 'snaptostore_monthly_pro',
);

static const SubscriptionPlan yearly = SubscriptionPlan(
type: PlanType.yearly,
name: 'SnaptoStore Pro Yearly',
description: 'Best value - 2 months free!',
price: 99.99, // $99.99/year (~17% discount)
currency: 'USD',
billingPeriodMonths: 12,
features: [
  PlanFeature.basicTemplates,
  PlanFeature.premiumTemplates,
  PlanFeature.unlimitedProjects,
  PlanFeature.priorityProcessing,
  PlanFeature.customBackgrounds,
  PlanFeature.noWatermark,
  PlanFeature.aiBackgrounds,
  PlanFeature.batchProcessing,
  PlanFeature.cloudStorage,
  PlanFeature.analytics,
],
flutterwavePlanId: 'snaptostore_yearly_usd',
revenueCatProductId: 'snaptostore_yearly_pro',
);

static List<SubscriptionPlan> get allPlans => [free, monthly, yearly];
static List<SubscriptionPlan> get paidPlans => [monthly, yearly];

// Helper methods
bool get isFree => type == PlanType.free;
bool get isPaid => !isFree;

bool hasFeature(PlanFeature feature) => features.contains(feature);

String get displayPrice {
if (isFree) return 'Free';
return '\$${price.toStringAsFixed(2)}';
}

String get billingText {
  if (isFree) return '';
  if (billingPeriodMonths == 1) return 'per month';
  if (billingPeriodMonths == 12) return 'per year';
  return 'per $billingPeriodMonths months';
}

@override
List<Object?> get props => [
  type, name, description, price, currency, billingPeriodMonths,
  features, projectLimit, templatesLimit, isPopular,
  flutterwavePlanId, revenueCatProductId,
];
}
extension SubscriptionPlanExtension on SubscriptionPlan {
SubscriptionPlan copyWith({
  PlanType? type,
  String? name,
  String? description,
  double? price,
  String? currency,
  int? billingPeriodMonths,
  List<PlanFeature>? features,
  int? projectLimit,
  int? templatesLimit,
  bool? isPopular,
  String? flutterwavePlanId,
  String? revenueCatProductId,
}) {
  return SubscriptionPlan(
    type: type ?? this.type,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    billingPeriodMonths: billingPeriodMonths ?? this.billingPeriodMonths,
    features: features ?? this.features,
    projectLimit: projectLimit ?? this.projectLimit,
    templatesLimit: templatesLimit ?? this.templatesLimit,
    isPopular: isPopular ?? this.isPopular,
    flutterwavePlanId: flutterwavePlanId ?? this.flutterwavePlanId,
    revenueCatProductId: revenueCatProductId ?? this.revenueCatProductId,
  );
}
}