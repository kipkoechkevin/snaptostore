import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../providers/subscription_provider.dart';
import '../pricing_screen.dart';

class UpgradePrompt extends ConsumerWidget {
final String title;
final String message;
final String? actionText;
final VoidCallback? onDismiss;
final bool isDismissible;

const UpgradePrompt({
  super.key,
  required this.title,
  required this.message,
  this.actionText,
  this.onDismiss,
  this.isDismissible = true,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: colorScheme.gradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            if (isDismissible && onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PricingScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              actionText ?? 'Upgrade Now',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Factory constructors for common scenarios
static Widget projectLimit() {
  return Consumer(
    builder: (context, ref, child) {
      final subscription = ref.watch(subscriptionProvider).subscription;
      if (subscription == null || !subscription.isProjectLimitReached) {
        return const SizedBox.shrink();
      }
      
      return UpgradePrompt(
        title: 'Project Limit Reached',
        message: 'You\'ve created ${subscription.projectsUsedThisMonth} projects this month. Upgrade for unlimited projects!',
        actionText: 'Get Unlimited',
      );
    },
  );
}

static Widget expiringSoon() {
  return Consumer(
    builder: (context, ref, child) {
      final subscription = ref.watch(subscriptionProvider).subscription;
      if (subscription == null || !subscription.isAboutToExpire) {
        return const SizedBox.shrink();
      }
      
      return UpgradePrompt(
        title: 'Subscription Expiring Soon',
        message: 'Your subscription expires in ${subscription.daysUntilExpiry} days. Renew now to keep your premium features!',
        actionText: 'Renew Now',
      );
    },
  );
}

static Widget premiumTemplate() {
  return const UpgradePrompt(
    title: 'Premium Template',
    message: 'This template is only available to Pro subscribers. Upgrade to access all premium designs!',
    actionText: 'Unlock Premium',
  );
}
}