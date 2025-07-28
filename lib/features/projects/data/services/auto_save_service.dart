import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaptostore/features/projects/domain/models/project_model.dart';
import 'package:snaptostore/features/projects/data/repositories/projects_repository.dart';
import '../../presentation/providers/projects_provider.dart';

class AutoSaveService {
final ProjectsRepository _repository;
Timer? _saveTimer;
ProjectModel? _currentProject;
bool _hasUnsavedChanges = false;

// Auto-save interval (30 seconds)
static const Duration autoSaveInterval = Duration(seconds: 30);

AutoSaveService(this._repository);

// Start auto-save for a project
void startAutoSave(ProjectModel project) {
  _currentProject = project;
  _startTimer();
}

// Stop auto-save
void stopAutoSave() {
  _saveTimer?.cancel();
  _saveTimer = null;
  _currentProject = null;
  _hasUnsavedChanges = false;
}

// Mark project as having unsaved changes
void markAsModified(ProjectModel updatedProject) {
  _currentProject = updatedProject;
  _hasUnsavedChanges = true;
}

// Force save immediately
Future<bool> saveNow() async {
  if (_currentProject == null || !_hasUnsavedChanges) {
    return true;
  }

  try {
    await _repository.updateProject(_currentProject!);
    _hasUnsavedChanges = false;
    return true;
  } catch (e) {
    print('Auto-save failed: $e');
    return false;
  }
}

// Check if there are unsaved changes
bool get hasUnsavedChanges => _hasUnsavedChanges;

// Get current project being auto-saved
ProjectModel? get currentProject => _currentProject;

void _startTimer() {
  _saveTimer?.cancel();
  _saveTimer = Timer.periodic(autoSaveInterval, (timer) {
    if (_hasUnsavedChanges && _currentProject != null) {
      _autoSave();
    }
  });
}

Future<void> _autoSave() async {
  if (_currentProject == null || !_hasUnsavedChanges) return;

  try {
    print('Auto-saving project: ${_currentProject!.title}');
    await _repository.updateProject(_currentProject!);
    _hasUnsavedChanges = false;
    print('Auto-save successful');
  } catch (e) {
    print('Auto-save failed: $e');
    // Don't reset _hasUnsavedChanges on failure, so we can retry
  }
}

// Dispose and clean up
void dispose() {
  stopAutoSave();
}
}

// Provider for auto-save service
final autoSaveServiceProvider = Provider<AutoSaveService>((ref) {
final repository = ref.read(projectsRepositoryProvider);
final service = AutoSaveService(repository);

// Clean up when provider is disposed
ref.onDispose(() {
  service.dispose();
});

return service;
});

// Auto-save state notifier
class AutoSaveNotifier extends StateNotifier<AutoSaveState> {
final AutoSaveService _service;

AutoSaveNotifier(this._service) : super(const AutoSaveState());

void startAutoSave(ProjectModel project) {
  _service.startAutoSave(project);
  state = state.copyWith(
    isActive: true,
    currentProjectId: project.id,
    lastSaved: DateTime.now(),
  );
}

void stopAutoSave() {
  _service.stopAutoSave();
  state = const AutoSaveState();
}

void markAsModified(ProjectModel project) {
  _service.markAsModified(project);
  state = state.copyWith(hasUnsavedChanges: true);
}

Future<bool> saveNow() async {
  final success = await _service.saveNow();
  if (success) {
    state = state.copyWith(
      hasUnsavedChanges: false,
      lastSaved: DateTime.now(),
    );
  }
  return success;
}
}

class AutoSaveState {
final bool isActive;
final String? currentProjectId;
final bool hasUnsavedChanges;
final DateTime? lastSaved;

const AutoSaveState({
  this.isActive = false,
  this.currentProjectId,
  this.hasUnsavedChanges = false,
  this.lastSaved,
});

AutoSaveState copyWith({
  bool? isActive,
  String? currentProjectId,
  bool? hasUnsavedChanges,
  DateTime? lastSaved,
}) {
  return AutoSaveState(
    isActive: isActive ?? this.isActive,
    currentProjectId: currentProjectId ?? this.currentProjectId,
    hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    lastSaved: lastSaved ?? this.lastSaved,
  );
}

String get statusText {
  if (!isActive) return 'Auto-save inactive';
  if (hasUnsavedChanges) return 'Saving...';
  if (lastSaved != null) {
    final now = DateTime.now();
    final diff = now.difference(lastSaved!);
    if (diff.inMinutes < 1) {
      return 'Saved just now';
    } else {
      return 'Saved ${diff.inMinutes}m ago';
    }
  }
  return 'Auto-save active';
}
}

final autoSaveProvider = StateNotifierProvider<AutoSaveNotifier, AutoSaveState>((ref) {
final service = ref.read(autoSaveServiceProvider);
return AutoSaveNotifier(service);
});