import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../domain/models/subscription_plan.dart';

class PlanCard extends ConsumerWidget {
final SubscriptionPlan plan;
final bool isSelected;
final VoidCallback onTap;
final bool showDiscount;

const PlanCard({
  super.key,
  required this.plan,
  required this.isSelected,
  required this.onTap,
  this.showDiscount = false,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected 
              ? colorScheme.primary 
              : AppColors.textTertiary.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colorScheme),
          const SizedBox(height: 16),
          _buildPricing(context),
          const SizedBox(height: 20),
          _buildFeatures(context),
          if (!plan.isFree) ...[
            const SizedBox(height: 20),
            _buildCTA(context, colorScheme),
          ],
        ],
      ),
    ),
  );
}

Widget _buildHeader(BuildContext context, BusinessColorScheme colorScheme) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (plan.isPopular) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MOST POPULAR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              plan.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      if (isSelected)
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        ),
    ],
  );
}

Widget _buildPricing(BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        plan.displayPrice,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          fontSize: plan.isFree ? 28 : 36,
        ),
      ),
      if (!plan.isFree) ...[
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            plan.billingText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
      if (showDiscount) ...[
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Save 17%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ],
  );
}

Widget _buildFeatures(BuildContext context) {
  final featureTexts = _getFeatureTexts();
  
  return Column(
    children: featureTexts.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

Widget _buildCTA(BuildContext context, BusinessColorScheme colorScheme) {
  return Container(
    width: double.infinity,
    height: 48,
    decoration: BoxDecoration(
      gradient: isSelected ? colorScheme.gradient : null,
      color: isSelected ? null : AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        isSelected ? 'Selected' : 'Select Plan',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

List<String> _getFeatureTexts() {
  switch (plan.type) {
    case PlanType.free:
      return [
        '5 projects per month',
        '10 basic templates',
        'Background removal',
        'Basic editing tools',
      ];
    case PlanType.monthly:
    case PlanType.yearly:
      return [
        'Unlimited projects',
        'All premium templates',
        'Priority processing',
        'Custom backgrounds',
        'No watermarks',
        'AI-generated backgrounds',
        'Batch processing',
        if (plan.type == PlanType.yearly) 'Cloud storage',
        if (plan.type == PlanType.yearly) 'Analytics dashboard',
      ];
  }
}
}