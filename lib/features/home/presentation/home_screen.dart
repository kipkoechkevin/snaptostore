import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../auth/auth.dart';
import '../../camera/presentation/camera_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_projects_section.dart';
import '../widgets/stats_cards.dart';

class HomeScreen extends ConsumerStatefulWidget {
const HomeScreen({super.key});

@override
ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
  with TickerProviderStateMixin {
late AnimationController _fadeController;
late AnimationController _slideController;
late Animation<double> _fadeAnimation;
late Animation<Offset> _slideAnimation;

@override
void initState() {
  super.initState();
  _fadeController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );
  _slideController = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );

  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
  );

  _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

  _startAnimations();
}

void _startAnimations() async {
  await Future.delayed(const Duration(milliseconds: 100));
  _fadeController.forward();
  _slideController.forward();
}

@override
void dispose() {
  _fadeController.dispose();
  _slideController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final user = ref.watch(currentUserProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Scaffold(
    backgroundColor: AppColors.background,
    body: FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: HomeHeader(user: user),
            ),

            // Stats Cards
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: StatsCards(),
              ),
            ),

            // Quick Actions
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: QuickActionsGrid(),
              ),
            ),

            // Recent Projects
            const SliverToBoxAdapter(
              child: RecentProjectsSection(),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    ),

    // Floating Action Button
    floatingActionButton: _buildFloatingActionButton(colorScheme),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}

Widget _buildFloatingActionButton(BusinessColorScheme colorScheme) {
  return Container(
    height: 64,
    width: 64,
    decoration: BoxDecoration(
      gradient: colorScheme.gradient,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const CameraScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    ),
  );
}
}