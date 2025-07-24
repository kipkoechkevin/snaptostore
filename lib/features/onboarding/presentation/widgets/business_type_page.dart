import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/business_type_model.dart';
import '../providers/onboarding_provider.dart';
import '../../../../core/providers/theme_provider.dart';

class BusinessTypePage extends ConsumerWidget {
final VoidCallback onNext;
final VoidCallback onBack;

const BusinessTypePage({
  super.key,
  required this.onNext,
  required this.onBack,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final onboardingState = ref.watch(onboardingProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Back Button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            'What type of business\nare you running?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Choose your business type to get customized templates and features',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),

          const SizedBox(height: 32),

          // Business Type Cards
          Expanded(
            child: ListView.builder(
              itemCount: BusinessTypeModel.allBusinessTypes.length,
              itemBuilder: (context, index) {
                final businessType = BusinessTypeModel.allBusinessTypes[index];
                final isSelected = onboardingState.selectedBusinessType?.id == businessType.id;

                return _BusinessTypeCard(
                  businessType: businessType,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(onboardingProvider.notifier).selectBusinessType(businessType);
                    ref.read(themeProvider.notifier).updateColorScheme(businessType.colorScheme);
                  },
                );
              },
            ),
          ),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onboardingState.selectedBusinessType != null ? onNext : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _BusinessTypeCard extends StatelessWidget {
final BusinessTypeModel businessType;
final bool isSelected;
final VoidCallback onTap;

const _BusinessTypeCard({
  required this.businessType,
  required this.isSelected,
  required this.onTap,
});

@override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected 
                ? businessType.colorScheme.primary.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? businessType.colorScheme.primary
                  : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: businessType.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: businessType.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  businessType.icon,
                  color: businessType.colorScheme.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          businessType.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (businessType.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: businessType.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Popular',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      businessType.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: businessType.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      businessType.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: businessType.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}