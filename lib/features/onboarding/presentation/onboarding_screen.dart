import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../onboarding/presentation/widgets/welcome_page.dart';
import '../../onboarding/presentation/widgets/business_type_page.dart';
import '../../onboarding/presentation/widgets/features_page.dart';
import '../../../../features/home/presentation/home_screen.dart';
import '../../../../core/providers/theme_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
const OnboardingScreen({super.key});

@override
ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
late PageController _pageController;

@override
void initState() {
  super.initState();
  _pageController = PageController();
}

@override
void dispose() {
  _pageController.dispose();
  super.dispose();
}

void _onPageChanged(int page) {
  ref.read(onboardingProvider.notifier).nextPage();
}

void _navigateToPage(int page) {
  _pageController.animateToPage(
    page,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}

void _completeOnboarding() async {
  await ref.read(onboardingProvider.notifier).completeOnboarding();
  
  final selectedBusiness = ref.read(selectedBusinessTypeProvider);
  if (selectedBusiness != null) {
    ref.read(themeProvider.notifier).updateColorScheme(selectedBusiness.colorScheme);
  }

  if (mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}

@override
Widget build(BuildContext context) {
  final onboardingState = ref.watch(onboardingProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  // Listen to onboarding completion
  ref.listen<OnboardingState>(onboardingProvider, (previous, next) {
    if (next.isCompleted && !next.isLoading) {
      _completeOnboarding();
    }
  });

  return Scaffold(
    body: Stack(
      children: [
        // Page View
        PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            WelcomePage(onNext: () => _navigateToPage(1)),
            BusinessTypePage(
              onNext: () => _navigateToPage(2),
              onBack: () => _navigateToPage(0),
            ),
            FeaturesPage(
              onComplete: _completeOnboarding,
              onBack: () => _navigateToPage(1),
            ),
          ],
        ),

        // Top Progress Indicator
        Positioned(
          top: MediaQuery.of(context).padding.top + 20,
          left: 24,
          right: 24,
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: index <= onboardingState.currentPage
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),

        // Loading Overlay
        if (onboardingState.isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          ),
      ],
    ),
  );
}
}