import 'package:flutter/material.dart';
import 'project_card.dart';

class ProjectsGrid extends StatelessWidget {
final List<ProjectData> projects;
final Function(ProjectData) onProjectTap;
final Function(ProjectData)? onProjectLongPress;

const ProjectsGrid({
  super.key,
  required this.projects,
  required this.onProjectTap,
  this.onProjectLongPress,
});

@override
Widget build(BuildContext context) {
  if (projects.isEmpty) {
    return _buildEmptyState();
  }

  return Padding(
    padding: const EdgeInsets.all(20),
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(
          title: project.title,
          businessType: project.businessType,
          status: project.status,
          lastModified: _formatLastModified(project.updatedAt),
          thumbnailUrl: project.thumbnailUrl,
          onTap: () => onProjectTap(project),
          onLongPress: onProjectLongPress != null 
              ? () => onProjectLongPress!(project)
              : null,
        );
      },
    ),
  );
}

Widget _buildEmptyState() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder_outlined,
          size: 64,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Text(
          'No projects yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Start creating your first project!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

String _formatLastModified(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}
}

// Temporary data class - we'll replace this with the actual model later
class ProjectData {
final String id;
final String title;
final String businessType;
final String status;
final DateTime updatedAt;
final String? thumbnailUrl;

ProjectData({
  required this.id,
  required this.title,
  required this.businessType,
  required this.status,
  required this.updatedAt,
  this.thumbnailUrl,
});
}