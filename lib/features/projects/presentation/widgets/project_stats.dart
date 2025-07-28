import 'package:flutter/material.dart';
import 'package:snaptostore/core/theme/app_colors.dart';

class ProjectStats extends StatelessWidget {
final int totalProjects;
final int draftCount;
final int completedCount;
final VoidCallback? onProjectsTap;
final VoidCallback? onDraftsTap;
final VoidCallback? onCompletedTap;

const ProjectStats({
  super.key,
  required this.totalProjects,
  required this.draftCount,
  required this.completedCount,
  this.onProjectsTap,
  this.onDraftsTap,
  this.onCompletedTap,
});

@override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.1),
          AppColors.primary.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.primary.withOpacity(0.1),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Projects',
          totalProjects.toString(),
          Icons.folder_outlined,
          AppColors.primary,
          onProjectsTap,
        ),
        _buildDivider(),
        _buildStatItem(
          'Drafts',
          draftCount.toString(),
          Icons.edit_outlined,
          AppColors.warning,
          onDraftsTap,
        ),
        _buildDivider(),
        _buildStatItem(
          'Completed',
          completedCount.toString(),
          Icons.check_circle_outline,
          AppColors.success,
          onCompletedTap,
        ),
      ],
    ),
  );
}

Widget _buildStatItem(
  String label,
  String count,
  IconData icon,
  Color color,
  VoidCallback? onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDivider() {
  return Container(
    height: 40,
    width: 1,
    color: AppColors.primary.withOpacity(0.2),
  );
}
}