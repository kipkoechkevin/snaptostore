import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';

class FeaturesComparison extends ConsumerWidget {
const FeaturesComparison({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Feature Comparison',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 20),
      Container(
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
          children: [
            _buildHeader(context, colorScheme),
            ...featuresList.map((feature) => _buildFeatureRow(
              context,
              feature['name']!,
              feature['free']!,
              feature['pro']!,
              colorScheme,
            )),
          ],
        ),
      ),
    ],
  );
}

Widget _buildHeader(BuildContext context, BusinessColorScheme colorScheme) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: colorScheme.gradient,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    child: Row(
      children: [
        const Expanded(
          flex: 2,
          child: Text(
            'Features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Free',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildFeatureRow(
  BuildContext context,
  String feature,
  String freeValue,
  String proValue,
  BusinessColorScheme colorScheme,
) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: AppColors.surfaceVariant,
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            feature,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: _buildFeatureValue(context, freeValue, false, colorScheme),
        ),
        Expanded(
          child: _buildFeatureValue(context, proValue, true, colorScheme),
        ),
      ],
    ),
  );
}

Widget _buildFeatureValue(
  BuildContext context,
  String value,
  bool isPro,
  BusinessColorScheme colorScheme,
) {
  if (value == '✓') {
    return Icon(
      Icons.check_circle,
      color: isPro ? colorScheme.primary : AppColors.success,
      size: 20,
    );
  } else if (value == '✗') {
    return Icon(
      Icons.cancel,
      color: AppColors.textTertiary,
      size: 20,
    );
  } else {
    return Text(
      value,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: isPro ? colorScheme.primary : AppColors.textSecondary,
        fontWeight: isPro ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

static const List<Map<String, String>> featuresList = [
  {
    'name': 'Projects per month',
    'free': '5',
    'pro': 'Unlimited',
  },
  {
    'name': 'Basic templates',
    'free': '10',
    'pro': 'All',
  },
  {
    'name': 'Premium templates',
    'free': '✗',
    'pro': '✓',
  },
  {
    'name': 'Background removal',
    'free': '✓',
    'pro': '✓',
  },
  {
    'name': 'Custom backgrounds',
    'free': '✗',
    'pro': '✓',
  },
  {
    'name': 'AI backgrounds',
    'free': '✗',
    'pro': '✓',
  },
  {
    'name': 'Batch processing',
    'free': '✗',
    'pro': '✓',
  },
  {
    'name': 'Priority processing',
    'free': '✗',
    'pro': '✓',
  },
  {
    'name': 'Watermark removal',
    'free': '✗',
    'pro': '✓',
  },
  {
    'name': 'Cloud storage',
    'free': '✗',
    'pro': '✓',
  },
  {
    'name': 'Analytics dashboard',
    'free': '✗',
    'pro': '✓',
  },
  {
    'name': 'Priority support',
    'free': '✗',
    'pro': '✓',
  },
];
}