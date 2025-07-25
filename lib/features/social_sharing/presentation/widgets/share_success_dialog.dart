import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../domain/models/share_result.dart';
import '../../domain/models/social_platform.dart';

class ShareSuccessDialog extends ConsumerStatefulWidget {
final ShareResult result;

const ShareSuccessDialog({
  super.key,
  required this.result,
});

@override
ConsumerState<ShareSuccessDialog> createState() => _ShareSuccessDialogState();
}

class _ShareSuccessDialogState extends ConsumerState<ShareSuccessDialog>
  with SingleTickerProviderStateMixin {
late AnimationController _animationController;
late Animation<double> _scaleAnimation;
late Animation<double> _opacityAnimation;

@override
void initState() {
  super.initState();
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );
  
  _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
  );
  
  _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
  );

  _animationController.forward();
}

@override
void dispose() {
  _animationController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  final platform = SocialPlatform.allPlatforms
      .firstWhere((p) => p.type == widget.result.platform);

  return AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Shared Successfully!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Platform info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: platform.brandColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          platform.icon,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Posted to ${platform.displayName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: AppColors.textTertiary.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Done'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // TODO: Navigate to share another platform
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Share More'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
}