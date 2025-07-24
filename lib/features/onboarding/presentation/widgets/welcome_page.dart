import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';

class WelcomePage extends ConsumerWidget {
final VoidCallback onNext;

const WelcomePage({
  super.key,
  required this.onNext,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    decoration: BoxDecoration(
      gradient: colorScheme.gradient,
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            
            // Hero Image/Icon
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 48),

            // Title
            Text(
              'Welcome to\nSnaptoStore',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              'Transform your product photos into professional listings in under 60 seconds',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Features
            Column(
              children: [
                _FeatureItem(
                  icon: Icons.camera_alt_rounded,
                  text: 'AI-powered photo enhancement',
                ),
                _FeatureItem(
                  icon: Icons.auto_fix_high,
                  text: 'Professional background removal',
                ),
                _FeatureItem(
                  icon: Icons.palette_outlined,
                  text: 'Customizable brand templates',
                ),
                _FeatureItem(
                  icon: Icons.share_rounded,
                  text: 'Direct social media sharing',
                ),
              ],
            ),

            const Spacer(),

            // Get Started Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Get Started',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}
}

class _FeatureItem extends StatelessWidget {
final IconData icon;
final String text;

const _FeatureItem({
  required this.icon,
  required this.text,
});

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    ),
  );
}
}