import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../domain/models/social_platform.dart';
import '../providers/social_sharing_provider.dart';

class PlatformSelectionGrid extends ConsumerWidget {
final SocialPlatform? selectedPlatform;
final Function(SocialPlatform) onPlatformSelected;

const PlatformSelectionGrid({
  super.key,
  required this.selectedPlatform,
  required this.onPlatformSelected,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final platforms = ref.watch(availablePlatformsProvider);
  final isLoading = ref.watch(isLoadingPlatformsProvider);

  return Container(
    margin: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Platform',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: platforms.length,
            itemBuilder: (context, index) {
              final platform = platforms[index];
              final isSelected = selectedPlatform?.type == platform.type;
              
              return _PlatformCard(
                platform: platform,
                isSelected: isSelected,
                onTap: () => onPlatformSelected(platform),
              );
            },
          ),
      ],
    ),
  );
}
}

class _PlatformCard extends ConsumerStatefulWidget {
final SocialPlatform platform;
final bool isSelected;
final VoidCallback onTap;

const _PlatformCard({
  required this.platform,
  required this.isSelected,
  required this.onTap,
});

@override
ConsumerState<_PlatformCard> createState() => _PlatformCardState();
}

class _PlatformCardState extends ConsumerState<_PlatformCard>
  with SingleTickerProviderStateMixin {
late AnimationController _scaleController;
late Animation<double> _scaleAnimation;

@override
void initState() {
  super.initState();
  _scaleController = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );
  _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
    CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
  );
}

@override
void dispose() {
  _scaleController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _scaleController,
    builder: (context, child) {
      return Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? widget.platform.brandColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: widget.isSelected ? 15 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              onTapDown: (_) => _scaleController.forward(),
              onTapUp: (_) => _scaleController.reverse(),
              onTapCancel: () => _scaleController.reverse(),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.platform.brandColor.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.platform.brandColor
                        : AppColors.textTertiary.withOpacity(0.3),
                    width: widget.isSelected ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Platform content
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.platform.brandColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.platform.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.platform.displayName,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: widget.isSelected
                                  ? widget.platform.brandColor
                                  : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Installation status
                    if (!widget.platform.isInstalled)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),

                    // Selection indicator
                    if (widget.isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: widget.platform.brandColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
}