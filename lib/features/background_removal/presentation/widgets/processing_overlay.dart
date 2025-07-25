import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';

class ProcessingOverlay extends ConsumerStatefulWidget {
final double progress;
final String currentStep;

const ProcessingOverlay({
  super.key,
  required this.progress,
  required this.currentStep,
});

@override
ConsumerState<ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends ConsumerState<ProcessingOverlay>
  with TickerProviderStateMixin {
late AnimationController _pulseController;
late AnimationController _rotationController;
late Animation<double> _pulseAnimation;
late Animation<double> _rotationAnimation;

@override
void initState() {
  super.initState();
  
  _pulseController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat();
  
  _rotationController = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat();

  _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
  );

  _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _rotationController, curve: Curves.linear),
  );
}

@override
void dispose() {
  _pulseController.dispose();
  _rotationController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    color: Colors.black.withOpacity(0.7),
    child: Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing circle
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    );
                  },
                ),

                // Rotating border
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 3,
                          ),
                          gradient: SweepGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.3),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Center icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress bar
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: colorScheme.gradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Progress text
            Text(
              '${(widget.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 8),

            // Current step
            Text(
              widget.currentStep,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Fun fact or tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getRandomTip(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _getRandomTip() {
  final tips = [
    'Good lighting makes background removal more accurate',
    'Try different backgrounds to see what works best',
    'White and colored backgrounds are great for products',
    'Transparent backgrounds work well for social media',
    'Professional photos increase sales by 40%',
  ];
  
  return tips[DateTime.now().second % tips.length];
}
}