import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../domain/models/background_removal_result.dart';
import '../providers/background_removal_provider.dart';
import 'checkered_background_painter.dart';

class BackgroundOptionsGrid extends ConsumerWidget {
final BackgroundOption? selectedOption;
final Function(BackgroundOption) onOptionSelected;
final VoidCallback onClose;

const BackgroundOptionsGrid({
  super.key,
  required this.selectedOption,
  required this.onOptionSelected,
  required this.onClose,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final backgroundOptions = ref.watch(backgroundOptionsProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Choose Background',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Options Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: backgroundOptions.length,
            itemBuilder: (context, index) {
              final option = backgroundOptions[index];
              final isSelected = selectedOption?.id == option.id;

              return _BackgroundOptionCard(
                option: option,
                isSelected: isSelected,
                onTap: () => onOptionSelected(option),
              );
            },
          ),
        ),

        // Custom Background Button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCustomBackgroundDialog(context),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Custom Background'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: colorScheme.primary),
              foregroundColor: colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

void _showCustomBackgroundDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Custom Background'),
      content: const Text('Custom background feature coming soon! You\'ll be able to upload your own images or generate AI backgrounds.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
}

class _BackgroundOptionCard extends ConsumerWidget {
final BackgroundOption option;
final bool isSelected;
final VoidCallback onTap;

const _BackgroundOptionCard({
  required this.option,
  required this.isSelected,
  required this.onTap,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSelected
            ? ref.watch(currentColorSchemeProvider).primary
            : AppColors.textTertiary.withOpacity(0.3),
        width: isSelected ? 3 : 1,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: ref.watch(currentColorSchemeProvider).primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
          : [],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textTertiary.withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildPreview(),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Label
              Text(
                option.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? ref.watch(currentColorSchemeProvider).primary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Premium badge
              if (option.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PRO',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildPreview() {
  switch (option.type) {
    case BackgroundType.transparent:
      return CustomPaint(
        painter: CheckeredBackgroundPainter(),
        child: Container(),
      );

    case BackgroundType.solidColor:
      return Container(
        color: Color(int.parse(option.color!.replaceAll('#', '0xFF'))),
      );

    case BackgroundType.gradient:
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: option.colors!
                .map((c) => Color(int.parse(c.replaceAll('#', '0xFF'))))
                .toList(),
          ),
        ),
      );

    case BackgroundType.customImage:
      // TODO: Show custom image preview
      return Container(
        color: AppColors.surfaceVariant,
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textTertiary,
        ),
      );
    case BackgroundType.aiGenerated:
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.blue.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      );
  }
}
}