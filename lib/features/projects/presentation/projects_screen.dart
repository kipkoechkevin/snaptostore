import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaptostore/core/theme/app_colors.dart';
import 'package:snaptostore/features/projects/domain/models/project_model.dart';
import 'package:snaptostore/features/projects/presentation/providers/projects_provider.dart';
import 'package:snaptostore/features/projects/presentation/widgets/project_stats.dart';
import 'package:snaptostore/features/projects/presentation/widgets/project_filters.dart';
import 'package:snaptostore/features/projects/presentation/widgets/projects_grid.dart';
import 'package:snaptostore/features/projects/presentation/widgets/project_search_bar.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
const ProjectsScreen({super.key});

@override
ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
@override
void initState() {
  super.initState();
  // Load projects when screen initializes
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(projectsProvider.notifier).loadProjects();
  });
}

@override
Widget build(BuildContext context) {
  final projectsState = ref.watch(projectsProvider);
  final filteredProjects = ref.watch(filteredProjectsProvider);

  return Scaffold(
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(projectsProvider.notifier).refresh(),
        child: Column(
          children: [
            _buildHeader(projectsState.stats),
            const SizedBox(height: 20),
            _buildSearchSection(),
            const SizedBox(height: 16),
            _buildFiltersSection(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            Expanded(child: _buildProjectsSection(projectsState, filteredProjects)),
          ],
        ),
      ),
    ),
    floatingActionButton: _buildFloatingActionButton(),
  );
}

Widget _buildHeader(Map<String, int> stats) {
  final total = stats['total'] ?? 0;
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: _showSortOptions,
              icon: const Icon(Icons.sort, color: Colors.white),
            ),
            IconButton(
              onPressed: _showMoreOptions,
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'My Projects',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          total == 1 ? '1 project saved' : '$total projects saved',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSearchSection() {
  final projectsNotifier = ref.read(projectsProvider.notifier);
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ProjectSearchBar(
      hintText: 'Search projects...',
      onChanged: (query) {
        projectsNotifier.setSearchQuery(query);
      },
      onClear: () {
        projectsNotifier.clearSearch();
      },
    ),
  );
}

Widget _buildFiltersSection() {
  final projectsState = ref.watch(projectsProvider);
  final projectsNotifier = ref.read(projectsProvider.notifier);
  
  return ProjectFilters(
    selectedFilter: projectsState.currentFilter,
    onFilterChanged: (filter) {
      projectsNotifier.setFilter(filter);
    },
  );
}

Widget _buildStatsSection() {
  final stats = ref.watch(projectStatsProvider);
  final projectsNotifier = ref.read(projectsProvider.notifier);
  
  return ProjectStats(
    totalProjects: stats['total'] ?? 0,
    draftCount: stats['drafts'] ?? 0,
    completedCount: stats['completed'] ?? 0,
    onProjectsTap: () => projectsNotifier.setFilter(ProjectFilter.all),
    onDraftsTap: () => projectsNotifier.setFilter(ProjectFilter.drafts),
    onCompletedTap: () => projectsNotifier.setFilter(ProjectFilter.completed),
  );
}

Widget _buildProjectsSection(ProjectsState projectsState, List<ProjectModel> filteredProjects) {
  // Show error state
  if (projectsState.error != null) {
    return _buildErrorState(projectsState.error!);
  }

  // Show loading state
  if (projectsState.isLoading && projectsState.projects.isEmpty) {
    return _buildLoadingState();
  }

  // Convert ProjectModel to ProjectData for the grid widget
  final projectDataList = filteredProjects.map((project) => ProjectData(
    id: project.id,
    title: project.title,
    businessType: project.businessType,
    status: project.statusLabel,
    updatedAt: project.updatedAt,
    thumbnailUrl: project.thumbnailUrl.isNotEmpty ? project.thumbnailUrl : null,
  )).toList();

  return ProjectsGrid(
    projects: projectDataList,
    onProjectTap: _handleProjectTap,
    onProjectLongPress: _handleProjectLongPress,
  );
}

Widget _buildLoadingState() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Loading projects...',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorState(String error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: AppColors.error,
        ),
        const SizedBox(height: 16),
        const Text(
          'Something went wrong',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            ref.read(projectsProvider.notifier).clearError();
            ref.read(projectsProvider.notifier).loadProjects();
          },
          child: const Text('Try Again'),
        ),
      ],
    ),
  );
}

Widget _buildFloatingActionButton() {
  return FloatingActionButton.extended(
    onPressed: _createNewProject,
    backgroundColor: AppColors.primary,
    icon: const Icon(Icons.add, color: Colors.white),
    label: const Text(
      'New Project',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// Project Actions
void _handleProjectTap(ProjectData projectData) async {
  // Find the actual ProjectModel
  final project = ref.read(projectsProvider).projects.firstWhere((p) => p.id == projectData.id);
  
  // TODO: Navigate to project editor/template editor
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Opening project: ${project.title}')),
  );
  
  // Example: Navigate to template editor with project data
  // Navigator.pushNamed(context, '/template-editor', arguments: project);
}

void _handleProjectLongPress(ProjectData projectData) async {
  // Find the actual ProjectModel
  final project = ref.read(projectsProvider).projects.firstWhere((p) => p.id == projectData.id);
  _showProjectOptions(project);
}

void _createNewProject() async {
  final result = await showDialog<Map<String, String>>(
    context: context,
    builder: (context) => _CreateProjectDialog(),
  );

  if (result != null && result['title'] != null && result['businessType'] != null) {
    final projectsNotifier = ref.read(projectsProvider.notifier);
    final project = await projectsNotifier.createProject(
      title: result['title']!,
      businessType: result['businessType']!,
      description: result['description'],
    );

    if (project != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project "${project.title}" created!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create project')),
      );
    }
  }
}

// Options and Actions
void _showSortOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sort Projects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Last Modified'),
            onTap: () {
              Navigator.pop(context);
              // Projects are already sorted by updated_at in repository
            },
          ),
          ListTile(
            leading: const Icon(Icons.title),
            title: const Text('Name'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement sort by name
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Business Type'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement sort by business type
            },
          ),
        ],
      ),
    ),
  );
}

void _showMoreOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear Archived'),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await _confirmClearArchived();
              if (confirmed) {
                final success = await ref.read(projectsProvider.notifier).clearArchivedProjects();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Archived projects cleared')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh'),
            onTap: () {
              Navigator.pop(context);
              ref.read(projectsProvider.notifier).refresh();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Project Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
    ),
  );
}

void _showProjectOptions(ProjectModel project) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Project'),
            onTap: () {
              Navigator.pop(context);
              _handleProjectTap(ProjectData(
                id: project.id,
                title: project.title,
                businessType: project.businessType,
                status: project.statusLabel,
                updatedAt: project.updatedAt,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicate'),
            onTap: () async {
              Navigator.pop(context);
              final newTitle = await _getDuplicateTitle(project.title);
              if (newTitle != null) {
                final duplicated = await ref.read(projectsProvider.notifier)
                    .duplicateProject(project.id, newTitle);
                if (duplicated != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Project duplicated as "$newTitle"')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share
            },
          ),
          if (!project.isArchived)
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () async {
                Navigator.pop(context);
                final success = await ref.read(projectsProvider.notifier)
                    .archiveProject(project.id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${project.title} archived')),
                  );
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.error),
            title: const Text('Delete', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(project);
            },
          ),
        ],
      ),
    ),
  );
}

Future<bool> _confirmClearArchived() async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear Archived Projects'),
      content: const Text('Are you sure you want to permanently delete all archived projects? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete All'),
        ),
      ],
    ),
  ) ?? false;
}

Future<String?> _getDuplicateTitle(String originalTitle) async {
  final controller = TextEditingController(text: '$originalTitle (Copy)');
  
  return await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Duplicate Project'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'New project name',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Duplicate'),
        ),
      ],
    ),
  );
}

void _confirmDelete(ProjectModel project) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Project'),
      content: Text('Are you sure you want to delete "${project.title}"? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final success = await ref.read(projectsProvider.notifier)
                .deleteProject(project.id);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${project.title} deleted')),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
}

// Create Project Dialog Widget
class _CreateProjectDialog extends StatefulWidget {
@override
State<_CreateProjectDialog> createState() => __CreateProjectDialogState();
}

class __CreateProjectDialogState extends State<_CreateProjectDialog> {
final _titleController = TextEditingController();
final _descriptionController = TextEditingController();
String _selectedBusinessType = 'Thrift';

final List<String> businessTypes = ['Thrift', 'Boutique', 'Beauty', 'Handmade'];

@override
Widget build(BuildContext context) {
  return AlertDialog(
    title: const Text('Create New Project'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Project Title',
              hintText: 'Enter project name',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration: const InputDecoration(labelText: 'Business Type'),
            items: businessTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedBusinessType = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Brief description of your project',
            ),
            maxLines: 2,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          if (_titleController.text.trim().isNotEmpty) {
            Navigator.pop(context, {
              'title': _titleController.text.trim(),
              'businessType': _selectedBusinessType,
              'description': _descriptionController.text.trim().isNotEmpty 
                  ? _descriptionController.text.trim() : null,
            });
          }
        },
        child: const Text('Create'),
      ),
    ],
  );
}
}