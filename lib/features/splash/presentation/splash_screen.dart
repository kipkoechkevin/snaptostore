import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
const SplashScreen({super.key});

@override
ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
  with TickerProviderStateMixin {
late AnimationController _logoController;
late AnimationController _textController;
late Animation<double> _logoScale;
late Animation<double> _logoRotation;
late Animation<double> _textOpacity;
late Animation<Offset> _textSlide;

@override
void initState() {
  super.initState();
  
  _logoController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );
  
  _textController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );
  
  _logoScale = Tween<double>(
    begin: 0.5,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _logoController,
    curve: Curves.elasticOut,
  ));
  
  _logoRotation = Tween<double>(
    begin: -0.5,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: _logoController,
    curve: Curves.easeOutBack,
  ));
  
  _textOpacity = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _textController,
    curve: Curves.easeIn,
  ));
  
  _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _textController,
    curve: Curves.easeOutCubic,
  ));
  
  _startAnimations();
}

void _startAnimations() async {
  await _logoController.forward();
  await _textController.forward();
  
  await Future.delayed(const Duration(milliseconds: 1000));
  
  if (mounted) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

@override
void dispose() {
  _logoController.dispose();
  _textController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(gradient: colorScheme.gradient),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Transform.rotate(
                      angle: _logoRotation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 60,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Text Animation
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'SnaptoStore',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Professional listings in 60 seconds',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          // Loading indicator
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}