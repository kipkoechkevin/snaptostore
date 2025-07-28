import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../domain/models/template_model.dart';
import '../../template_editor/presentation/template_editor_screen.dart';

class TemplateDetailScreen extends ConsumerWidget {
final TemplateModel template;
final String? imagePath; // Optional image path for direct editing

const TemplateDetailScreen({
  super.key,
  required this.template,
  this.imagePath,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Scaffold(
    backgroundColor: AppColors.background,
    body: CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: colorScheme.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              template.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: colorScheme.gradient,
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  template.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Template Info
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: template.category.toString().split('.').last,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    if (template.isPremium)
                      _InfoChip(
                        icon: Icons.star,
                        label: 'Premium',
                        color: AppColors.warning,
                      ),
                    const SizedBox(width: 8),
                    if (template.isPopular)
                      _InfoChip(
                        icon: Icons.trending_up,
                        label: 'Popular',
                        color: AppColors.success,
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // Use Template Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: imagePath != null
                        ? () => _navigateToEditor(context)
                        : () => _showImagePicker(context),
                    icon: Icon(imagePath != null ? Icons.edit : Icons.add_a_photo),
                    label: Text(imagePath != null ? 'Edit with Template' : 'Choose Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void _navigateToEditor(BuildContext context) {
  if (imagePath != null) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TemplateEditorScreen(
          imagePath: imagePath!,
          template: template,
        ),
      ),
    );
  }
}

void _showImagePicker(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please capture or select an image first!'),
    ),
  );
}
}

class _InfoChip extends StatelessWidget {
final IconData icon;
final String label;
final Color color;

const _InfoChip({
  required this.icon,
  required this.label,
  required this.color,
});

@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
}