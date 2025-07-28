import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snaptostore/features/projects/domain/models/project_model.dart';

class ProjectsRepository {
final SupabaseClient _supabase = Supabase.instance.client;

// Get all projects for current user
Future<List<ProjectModel>> getUserProjects() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('projects')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch projects: $e');
  }
}

// Get projects by status
Future<List<ProjectModel>> getProjectsByStatus(ProjectStatus status) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('projects')
        .select()
        .eq('user_id', userId)
        .eq('status', status.name)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch projects by status: $e');
  }
}

// Get projects by business type
Future<List<ProjectModel>> getProjectsByBusinessType(String businessType) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('projects')
        .select()
        .eq('user_id', userId)
        .eq('business_type', businessType)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch projects by business type: $e');
  }
}

// Search projects
Future<List<ProjectModel>> searchProjects(String query) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('projects')
        .select()
        .eq('user_id', userId)
        .or('title.ilike.%$query%,description.ilike.%$query%')
        .order('updated_at', ascending: false);

    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Failed to search projects: $e');
  }
}

// Get single project
Future<ProjectModel?> getProject(String projectId) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('projects')
        .select()
        .eq('id', projectId)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null ? ProjectModel.fromJson(response) : null;
  } catch (e) {
    throw Exception('Failed to fetch project: $e');
  }
}

// Create new project
Future<ProjectModel> createProject(ProjectModel project) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final projectData = project.toJson();
    projectData['user_id'] = userId; // Ensure user_id is set

    final response = await _supabase
        .from('projects')
        .insert(projectData)
        .select()
        .single();

    return ProjectModel.fromJson(response);
  } catch (e) {
    throw Exception('Failed to create project: $e');
  }
}

// Update existing project
Future<ProjectModel> updateProject(ProjectModel project) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final projectData = project.toJson();
    projectData['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('projects')
        .update(projectData)
        .eq('id', project.id)
        .eq('user_id', userId)
        .select()
        .single();

    return ProjectModel.fromJson(response);
  } catch (e) {
    throw Exception('Failed to update project: $e');
  }
}

// Delete project
Future<void> deleteProject(String projectId) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase
        .from('projects')
        .delete()
        .eq('id', projectId)
        .eq('user_id', userId);
  } catch (e) {
    throw Exception('Failed to delete project: $e');
  }
}

// Archive project
Future<ProjectModel> archiveProject(String projectId) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('projects')
        .update({
          'status': ProjectStatus.archived.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', projectId)
        .eq('user_id', userId)
        .select()
        .single();

    return ProjectModel.fromJson(response);
  } catch (e) {
    throw Exception('Failed to archive project: $e');
  }
}

// Duplicate project
Future<ProjectModel> duplicateProject(String projectId, String newTitle) async {
  try {
    final originalProject = await getProject(projectId);
    if (originalProject == null) {
      throw Exception('Project not found');
    }

    final now = DateTime.now();
    final duplicatedProject = originalProject.copyWith(
      id: '', // Will be generated by Supabase
      title: newTitle,
      status: ProjectStatus.draft,
      createdAt: now,
      updatedAt: now,
    );

    return await createProject(duplicatedProject);
  } catch (e) {
    throw Exception('Failed to duplicate project: $e');
  }
}

// Get project statistics
Future<Map<String, int>> getProjectStats() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('projects')
        .select('status')
        .eq('user_id', userId);

    final projects = response as List;
    final total = projects.length;
    final drafts = projects.where((p) => p['status'] == 'draft').length;
    final completed = projects.where((p) => p['status'] == 'completed').length;
    final archived = projects.where((p) => p['status'] == 'archived').length;

    return {
      'total': total,
      'drafts': drafts,
      'completed': completed,
      'archived': archived,
    };
  } catch (e) {
    throw Exception('Failed to fetch project stats: $e');
  }
}

// Clear all archived projects
Future<void> clearArchivedProjects() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase
        .from('projects')
        .delete()
        .eq('user_id', userId)
        .eq('status', 'archived');
  } catch (e) {
    throw Exception('Failed to clear archived projects: $e');
  }
}

// Get recent projects (last 10)
Future<List<ProjectModel>> getRecentProjects({int limit = 10}) async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('projects')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch recent projects: $e');
  }
}
}