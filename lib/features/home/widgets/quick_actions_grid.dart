import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';

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
        childAspectRatio: 1.3, // ✅ Increased from 1.5 to give more height
        children: [
          _ActionCard(
            title: 'Take Photo',
            subtitle: 'Capture new product',
            icon: Icons.camera_alt_rounded,
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
            ),
            onTap: () {
              // Navigate to camera
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
              // Open gallery picker
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
              // Navigate to templates
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
              // Navigate to projects
            },
          ),
        ],
      ),
    ],
  );
}
}



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
          padding: const EdgeInsets.all(16), // ✅ Reduced from 20 to 16
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 28, // ✅ Reduced from 32 to 28
                height: 28, // ✅ Reduced from 32 to 28
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16, // ✅ Reduced from 18 to 16
                ),
              ),
              
              // ✅ Use Expanded instead of Spacer for better control
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13, // ✅ Slightly smaller font
                      ),
                      maxLines: 1, // ✅ Prevent overflow
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Subtitle
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11, // ✅ Smaller subtitle font
                      ),
                      maxLines: 1, // ✅ Prevent overflow
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

//Alternative Action Card

// class _ActionCard extends StatelessWidget {
// final String title;
// final String subtitle;
// final IconData icon;
// final LinearGradient gradient;
// final VoidCallback onTap;

// const _ActionCard({
//   required this.title,
//   required this.subtitle,
//   required this.icon,
//   required this.gradient,
//   required this.onTap,
// });

// @override
// Widget build(BuildContext context) {
//   return Container(
//     decoration: BoxDecoration(
//       gradient: gradient,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: gradient.colors.first.withOpacity(0.3),
//           blurRadius: 15,
//           offset: const Offset(0, 8),
//         ),
//       ],
//     ),
//     child: Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center, // ✅ Center everything
//             crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center horizontally
//             children: [
//               // Icon
//               Icon(
//                 icon,
//                 color: Colors.white,
//                 size: 24, // ✅ Simpler, no container
//               ),
              
//               const SizedBox(height: 8), // ✅ Fixed spacing
              
//               // Title only (remove subtitle to save space)
//               Flexible( // ✅ Use Flexible to prevent overflow
//                 child: Text(
//                   title,
//                   style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
// }