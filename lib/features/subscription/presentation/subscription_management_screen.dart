import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../domain/models/user_subscription.dart';
import '../presentation/providers/subscription_provider.dart';
import 'pricing_screen.dart';

class SubscriptionManagementScreen extends ConsumerStatefulWidget {
const SubscriptionManagementScreen({super.key});

@override
ConsumerState<SubscriptionManagementScreen> createState() =>
    _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
  extends ConsumerState<SubscriptionManagementScreen> {
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(subscriptionProvider.notifier).loadSubscription();
  });
}

@override
Widget build(BuildContext context) {
  final subscriptionState = ref.watch(subscriptionProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Scaffold(
    backgroundColor: AppColors.background,
    body: CustomScrollView(
      slivers: [
        _buildSliverAppBar(colorScheme),
        if (subscriptionState.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (subscriptionState.error != null)
          SliverFillRemaining(
            child: _buildErrorState(subscriptionState.error!),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCurrentPlanCard(subscriptionState.subscription!, colorScheme),
                const SizedBox(height: 24),
                _buildUsageStats(subscriptionState.subscription!, colorScheme),
                const SizedBox(height: 24),
                _buildQuickActions(subscriptionState.subscription!, colorScheme),
                const SizedBox(height: 24),
                _buildBillingHistory(),
                const SizedBox(height: 24),
                _buildSupportSection(colorScheme),
              ]),
            ),
          ),
      ],
    ),
  );
}

Widget _buildSliverAppBar(BusinessColorScheme colorScheme) {
  return SliverAppBar(
    expandedHeight: 120,
    floating: false,
    pinned: true,
    backgroundColor: colorScheme.primary,
    flexibleSpace: FlexibleSpaceBar(
      title: const Text(
        'Subscription',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      background: Container(
        decoration: BoxDecoration(
          gradient: colorScheme.gradient,
        ),
      ),
    ),
    leading: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
    ),
  );
}

Widget _buildCurrentPlanCard(UserSubscription subscription, BusinessColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: colorScheme.gradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.plan.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscription.statusDisplayText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (subscription.isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscription.plan.displayPrice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        if (subscription.isPremium && subscription.expiresAt != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                subscription.isAboutToExpire 
                    ? Icons.warning_amber_rounded 
                    : Icons.schedule,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                subscription.isAboutToExpire
                    ? 'Expires in ${subscription.daysUntilExpiry} days'
                    : 'Renews on ${_formatDate(subscription.expiresAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _buildUsageStats(UserSubscription subscription, BusinessColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
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
        Text(
          'This Month\'s Usage',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        _buildUsageItem(
          'Templates Used',
          subscription.templatesUsedThisMonth,
          subscription.plan.templatesLimit,
          Icons.palette_outlined,
          colorScheme,
        ),
      ],
    ),
  );
}

Widget _buildUsageItem(
  String title,
  int used,
  int? limit,
  IconData icon,
  BusinessColorScheme colorScheme,
) {
  final isUnlimited = limit == null;
  final percentage = isUnlimited ? 0.0 : (used / limit).clamp(0.0, 1.0);
  
  return Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: colorScheme.primary,
          size: 20,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isUnlimited ? '$used used' : '$used / $limit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isUnlimited) ...[
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 0.8 ? AppColors.warning : colorScheme.primary,
                ),
                minHeight: 6,
              ),
            ] else ...[
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

Widget _buildQuickActions(UserSubscription subscription, BusinessColorScheme colorScheme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quick Actions',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 16),
      if (subscription.isFree) ...[
        _buildActionCard(
          'Upgrade to Pro',
          'Get unlimited projects and premium templates',
          Icons.star_rounded,
          colorScheme.primary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PricingScreen(),
              ),
            );
          },
        ),
      ] else ...[
        _buildActionCard(
          'Manage Subscription',
          'Change plan, update payment method',
          Icons.settings_rounded,
          AppColors.textSecondary,
          () => _showManageSubscriptionDialog(),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Download Invoice',
          'Get receipt for your subscription',
          Icons.receipt_long_rounded,
          AppColors.textSecondary,
          () => _downloadInvoice(),
        ),
      ],
      const SizedBox(height: 12),
      _buildActionCard(
        'Restore Purchases',
        'Restore previous purchases',
        Icons.restore_rounded,
        AppColors.textSecondary,
        () => _restorePurchases(),
      ),
    ],
  );
}

Widget _buildActionCard(
  String title,
  String subtitle,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.textTertiary.withOpacity(0.1),
      ),
    ),
    child: ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textTertiary,
        size: 16,
      ),
      onTap: onTap,
    ),
  );
}

Widget _buildBillingHistory() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Billing History',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textTertiary.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            _buildBillingItem(
              'Dec 15, 2024',
              'SnaptoStore Pro Monthly',
              '\$9.99',
              'Paid',
              AppColors.success,
            ),
            const Divider(height: 24),
            _buildBillingItem(
              'Nov 15, 2024',
              'SnaptoStore Pro Monthly',
              '\$9.99',
              'Paid',
              AppColors.success,
            ),
            const Divider(height: 24),
            _buildBillingItem(
              'Oct 15, 2024',
              'SnaptoStore Pro Monthly',
              '\$9.99',
              'Paid',
              AppColors.success,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildBillingItem(
  String date,
  String description,
  String amount,
  String status,
  Color statusColor,
) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildSupportSection(BusinessColorScheme colorScheme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Need Help?',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: colorScheme.createOpacityGradient(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Support',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Get help with your subscription',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactSupport('email'),
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactSupport('chat'),
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildErrorState(String error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: AppColors.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Something went wrong',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ref.read(subscriptionProvider.notifier).loadSubscription();
          },
          child: const Text('Try Again'),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

void _showManageSubscriptionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Manage Subscription'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.upgrade_rounded),
            title: const Text('Change Plan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PricingScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel_rounded),
            title: const Text('Cancel Subscription'),
            onTap: () {
              Navigator.pop(context);
              _showCancelSubscriptionDialog();
            },
          ),
        ],
      ),
    ),
  );
}

void _showCancelSubscriptionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel Subscription'),
      content: const Text(
        'Are you sure you want to cancel your subscription? You\'ll lose access to premium features at the end of your billing period.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep Subscription'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final success = await ref
                .read(subscriptionProvider.notifier)
                .cancelSubscription();
            
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription cancelled successfully'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Cancel Subscription'),
        ),
      ],
    ),
  );
}

void _downloadInvoice() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Invoice download feature coming soon!'),
    ),
  );
}

void _restorePurchases() async {
  final success = await ref
      .read(subscriptionProvider.notifier)
      .restorePurchases();
  
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purchases restored successfully!'),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No purchases found to restore.'),
      ),
    );
  }
}

void _contactSupport(String method) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Opening $method support...'),
    ),
  );
}
}