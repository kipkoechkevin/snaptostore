import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../templates/presentation/template_browser_screen.dart';
import '../../projects/presentation/projects_screen.dart';

class QuickActionsGrid extends ConsumerWidget {
const QuickActionsGrid({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quick Actions',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 16),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.3,
        children: [
          _ActionCard(
            title: 'Take Photo',
            subtitle: 'Capture new product',
            icon: Icons.camera_alt_rounded,
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
          ),
          _ActionCard(
            title: 'From Gallery',
            subtitle: 'Choose existing photo',
            icon: Icons.photo_library_outlined,
            gradient: LinearGradient(
              colors: [colorScheme.accent, colorScheme.accent.withOpacity(0.8)],
            ),
            onTap: () {
              // TODO: Implement gallery picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gallery picker coming soon!')),
              );
            },
          ),
          _ActionCard(
            title: 'Templates',
            subtitle: 'Browse designs',
            icon: Icons.palette_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TemplateBrowserScreen(),
                ),
              );
            },
          ),
          _ActionCard(
            title: 'My Projects',
            subtitle: 'View saved work',
            icon: Icons.folder_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
            ),
            onTap: () {
              // ✅ Replace the TODO with actual navigation
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProjectsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
}

// _ActionCard class remains the same...
class _ActionCard extends StatelessWidget {
final String title;
final String subtitle;
final IconData icon;
final LinearGradient gradient;
final VoidCallback onTap;

const _ActionCard({
  required this.title,
  required this.subtitle,
  required this.icon,
  required this.gradient,
  required this.onTap,
});

@override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                    
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}