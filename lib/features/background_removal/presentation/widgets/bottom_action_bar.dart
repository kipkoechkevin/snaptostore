import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../../social_sharing/presentation/social_share_screen.dart';
import '../../domain/models/background_removal_result.dart';

class BottomActionBar extends ConsumerWidget {
final BackgroundRemovalResult result;
final VoidCallback onSave;
final VoidCallback onShare;
final VoidCallback onRetry;

const BottomActionBar({
  super.key,
  required this.result,
  required this.onSave,
  required this.onShare,
  required this.onRetry,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Row(
      children: [
        // Processing info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Processed in ${result.processingTimeMs}ms',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_getBackgroundTypeText(result.backgroundType)} background applied',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Action buttons
        Row(
          children: [
            // Retry button
            _ActionButton(
              icon: Icons.refresh,
              onTap: onRetry,
              backgroundColor: AppColors.surfaceVariant,
              iconColor: AppColors.textSecondary,
              tooltip: 'Retry',
            ),

            const SizedBox(width: 12),

            // Share button - Updated to navigate to social share screen
            _ActionButton(
              icon: Icons.share_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SocialShareScreen(
                      imagePath: result.processedImagePath,
                      defaultCaption: 'Check out my latest creation! ✨',
                    ),
                  ),
                );
              },
              backgroundColor: colorScheme.secondary.withOpacity(0.1),
              iconColor: colorScheme.secondary,
              tooltip: 'Share',
            ),

            const SizedBox(width: 12),

            // Save button
            Container(
              decoration: BoxDecoration(
                gradient: colorScheme.gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onSave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Save',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String _getBackgroundTypeText(BackgroundType type) {
  switch (type) {
    case BackgroundType.transparent:
      return 'Transparent';
    case BackgroundType.solidColor:
      return 'Solid color';
    case BackgroundType.gradient:
      return 'Gradient';
    case BackgroundType.aiGenerated:
      return 'AI-generated';
    case BackgroundType.customImage:
      return 'Custom image';
  }
}
}

class _ActionButton extends StatelessWidget {
final IconData icon;
final VoidCallback onTap;
final Color backgroundColor;
final Color iconColor;
final String tooltip;

const _ActionButton({
  required this.icon,
  required this.onTap,
  required this.backgroundColor,
  required this.iconColor,
  required this.tooltip,
});

@override
Widget build(BuildContext context) {
  return Tooltip(
    message: tooltip,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    ),
  );
}
}