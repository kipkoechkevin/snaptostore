import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../../../core/constants/business_types.dart'; // ✅ Import shared enum
import '../../domain/models/template_model.dart';
import '../providers/template_provider.dart';

class TemplateFilterBar extends ConsumerWidget {
const TemplateFilterBar({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final templateState = ref.watch(templateProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        // Business Type Filter
        _FilterSection(
          title: 'Business Type',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: BusinessType.values.map((type) {
                final isSelected = templateState.selectedBusinessType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: type.shortName, // ✅ Use extension method
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(templateProvider.notifier).filterByBusinessType(
                        isSelected ? null : type,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Category Filter
        _FilterSection(
          title: 'Category',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TemplateCategory.values.map((category) {
                final isSelected = templateState.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: _getCategoryLabel(category),
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(templateProvider.notifier).filterByCategory(
                        isSelected ? null : category,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        // Clear Filters Button
        if (templateState.selectedBusinessType != null || 
            templateState.selectedCategory != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: TextButton.icon(
              onPressed: () {
                ref.read(templateProvider.notifier).clearFilters();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ),
      ],
    ),
  );
}

String _getCategoryLabel(TemplateCategory category) {
  switch (category) {
    case TemplateCategory.product:
      return 'Product';
    case TemplateCategory.lifestyle:
      return 'Lifestyle';
    case TemplateCategory.minimal:
      return 'Minimal';
    case TemplateCategory.vintage:
      return 'Vintage';
    case TemplateCategory.modern:
      return 'Modern';
    case TemplateCategory.professional:
      return 'Professional';
    case TemplateCategory.creative:
      return 'Creative';
    case TemplateCategory.social:
      return 'Social';
  }
}
}

class _FilterSection extends StatelessWidget {
final String title;
final Widget child;

const _FilterSection({
  required this.title,
  required this.child,
});

@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      child,
    ],
  );
}
}

class _FilterChip extends ConsumerWidget {
final String label;
final bool isSelected;
final VoidCallback onTap;

const _FilterChip({
  required this.label,
  required this.isSelected,
  required this.onTap,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : AppColors.textTertiary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
}