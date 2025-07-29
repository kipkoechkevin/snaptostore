import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../domain/models/subscription_plan.dart';
import '../presentation/providers/subscription_provider.dart';
import '../presentation/widgets/plan_card.dart';
import '../presentation/widgets/payment_sheet.dart';
import '../presentation/widgets/features_comparison.dart';

class PricingScreen extends ConsumerStatefulWidget {
const PricingScreen({super.key});

@override
ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen>
  with TickerProviderStateMixin {
late AnimationController _slideController;
late Animation<Offset> _slideAnimation;

bool _showAnnualPricing = true;
SubscriptionPlan? _selectedPlan;

@override
void initState() {
  super.initState();
  
  _slideController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );
  
  _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeOutCubic,
  ));

  // Load subscription data
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(subscriptionProvider.notifier).loadSubscription();
    _slideController.forward();
  });
}

@override
void dispose() {
  _slideController.dispose();
  super.dispose();
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
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: 32),
              _buildBillingToggle(colorScheme),
              const SizedBox(height: 32),
              _buildPricingCards(subscriptionState.availablePlans),
              const SizedBox(height: 40),
              _buildFeaturesComparison(),
              const SizedBox(height: 40),
              _buildTestimonials(),
              const SizedBox(height: 40),
              _buildFAQ(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    ),
    bottomNavigationBar: _selectedPlan != null 
        ? _buildBottomCTA() 
        : null,
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
        'Choose Your Plan',
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
    actions: [
      TextButton(
        onPressed: () {
          // Show restore purchases dialog
          _showRestorePurchases();
        },
        child: const Text(
          'Restore',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

Widget _buildHeader() {
  return SlideTransition(
    position: _slideAnimation,
    child: Column(
      children: [
        Text(
          '🚀 Unlock Your Full Potential',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Join thousands of entrepreneurs creating stunning product photos in seconds',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildBillingToggle(BusinessColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showAnnualPricing = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_showAnnualPricing 
                    ? colorScheme.primary 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Monthly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: !_showAnnualPricing 
                      ? Colors.white 
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showAnnualPricing = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _showAnnualPricing 
                    ? colorScheme.primary 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Annual',
                    style: TextStyle(
                      color: _showAnnualPricing 
                          ? Colors.white 
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Save 17%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildPricingCards(List<SubscriptionPlan> plans) {
  final displayPlans = _showAnnualPricing 
      ? [SubscriptionPlan.free, SubscriptionPlan.yearly]
      : [SubscriptionPlan.free, SubscriptionPlan.monthly];

  return Column(
    children: displayPlans.map((plan) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: PlanCard(
          plan: plan,
          isSelected: _selectedPlan?.type == plan.type,
          onTap: () {
            setState(() {
              _selectedPlan = plan.isFree ? null : plan;
            });
          },
          showDiscount: _showAnnualPricing && plan.type == PlanType.yearly,
        ),
      );
    }).toList(),
  );
}

Widget _buildFeaturesComparison() {
  return const FeaturesComparison();
}

Widget _buildTestimonials() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'What Our Users Say',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 160,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildTestimonialCard(
              'Sarah K.',
              'Thrift Store Owner',
              'SnaptoStore saved me hours every day! My listings look professional now.',
              '⭐⭐⭐⭐⭐',
            ),
            _buildTestimonialCard(
              'James M.',
              'Boutique Owner',
              'The premium templates are amazing. Sales increased by 40% since I started using this.',
              '⭐⭐⭐⭐⭐',
            ),
            _buildTestimonialCard(
              'Maria L.',
              'Beauty Entrepreneur',
              'Perfect for my skincare products. The AI background removal is spot-on!',
              '⭐⭐⭐⭐⭐',
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildTestimonialCard(
  String name, 
  String title, 
  String testimonial,
  String rating,
) {
  return Container(
    width: 280,
    margin: const EdgeInsets.only(right: 16),
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
        Text(rating, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Expanded(
          child: Text(
            testimonial,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFAQ() {
  final faqs = [
    {
      'question': 'Can I cancel anytime?',
      'answer': 'Yes! You can cancel your subscription at any time. You\'ll continue to have access to premium features until your billing period ends.',
    },
    {
      'question': 'Do you offer refunds?',
      'answer': 'We offer a 30-day money-back guarantee if you\'re not satisfied with our service.',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer': 'We accept all major credit cards, M-Pesa, mobile money, and bank transfers through our secure payment partners.',
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Frequently Asked Questions',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 20),
      ...faqs.map((faq) => _buildFAQItem(
        faq['question']!,
        faq['answer']!,
      )),
    ],
  );
}

Widget _buildFAQItem(String question, String answer) {
  return ExpansionTile(
    title: Text(
      question,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(
          answer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    ],
  );
}

Widget _buildBottomCTA() {
  final subscriptionState = ref.watch(subscriptionProvider);
  
  return Container(
    padding: EdgeInsets.only(
      left: 24,
      right: 24,
      top: 20,
      bottom: MediaQuery.of(context).padding.bottom + 20,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPlan?.name ?? '',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_selectedPlan?.displayPrice ?? ''} ${_selectedPlan?.billingText ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: subscriptionState.isPurchasing 
                    ? null 
                    : () => _handlePurchase(),
                child: subscriptionState.isPurchasing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Get Started'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '✨ Start your 7-day free trial • Cancel anytime',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

void _handlePurchase() {
  if (_selectedPlan == null) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PaymentSheet(plan: _selectedPlan!),
  );
}

void _showRestorePurchases() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Restore Purchases'),
      content: const Text(
        'This will restore any previous purchases made with your Apple ID or Google account.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
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
          },
          child: const Text('Restore'),
        ),
      ],
    ),
  );
}
}