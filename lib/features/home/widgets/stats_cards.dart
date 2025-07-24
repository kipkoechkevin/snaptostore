import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';

class StatsCards extends ConsumerWidget {
const StatsCards({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  return Row(
    children: [
      Expanded(
        child: _StatCard(
          title: 'Projects',
          value: '12',
          subtitle: 'This month',
          icon: Icons.photo_camera_outlined,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _StatCard(
          title: 'Templates',
          value: '8',
          subtitle: 'Favorites',
          icon: Icons.favorite_outline,
          color: AppColors.secondary,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _StatCard(
          title: 'Shares',
          value: '47',
          subtitle: 'Total',
          icon: Icons.share_outlined,
          color: AppColors.accent,
        ),
      ),
    ],
  );
}
}

class _StatCard extends StatelessWidget {
final String title;
final String value;
final String subtitle;
final IconData icon;
final Color color;

const _StatCard({
  required this.title,
  required this.value,
  required this.subtitle,
  required this.icon,
  required this.color,
});

@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    ),
  );
}
}