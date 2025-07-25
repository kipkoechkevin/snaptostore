import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/template_model.dart';
import '../../domain/models/template_collection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/business_types.dart';

// Template State
class TemplateState {
final List<TemplateCollection> collections;
final List<TemplateModel> filteredTemplates;
final TemplateModel? selectedTemplate;
final BusinessType? selectedBusinessType;
final TemplateCategory? selectedCategory;
final bool isLoading;
final String? error;

const TemplateState({
  this.collections = const [],
  this.filteredTemplates = const [],
  this.selectedTemplate,
  this.selectedBusinessType,
  this.selectedCategory,
  this.isLoading = false,
  this.error,
});

TemplateState copyWith({
  List<TemplateCollection>? collections,
  List<TemplateModel>? filteredTemplates,
  TemplateModel? selectedTemplate,
  BusinessType? selectedBusinessType,
  TemplateCategory? selectedCategory,
  bool? isLoading,
  String? error,
}) {
  return TemplateState(
    collections: collections ?? this.collections,
    filteredTemplates: filteredTemplates ?? this.filteredTemplates,
    selectedTemplate: selectedTemplate ?? this.selectedTemplate,
    selectedBusinessType: selectedBusinessType ?? this.selectedBusinessType,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}
}

// Template Notifier
class TemplateNotifier extends StateNotifier<TemplateState> {
TemplateNotifier() : super(const TemplateState()) {
  loadTemplates();
}

Future<void> loadTemplates() async {
  state = state.copyWith(isLoading: true, error: null);
  
  try {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    
    final collections = TemplateCollection.businessCollections;
    final allTemplates = collections
        .expand((collection) => collection.templates)
        .toList();
    
    state = state.copyWith(
      collections: collections,
      filteredTemplates: allTemplates,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

void filterByBusinessType(BusinessType? businessType) {
  state = state.copyWith(selectedBusinessType: businessType);
  _applyFilters();
}

void filterByCategory(TemplateCategory? category) {
  state = state.copyWith(selectedCategory: category);
  _applyFilters();
}

void _applyFilters() {
  List<TemplateModel> filtered = state.collections
      .expand((collection) => collection.templates)
      .toList();

  if (state.selectedBusinessType != null) {
    filtered = filtered
        .where((template) => template.businessType == state.selectedBusinessType)
        .toList();
  }

  if (state.selectedCategory != null) {
    filtered = filtered
        .where((template) => template.category == state.selectedCategory)
        .toList();
  }

  state = state.copyWith(filteredTemplates: filtered);
}

void selectTemplate(TemplateModel template) {
  state = state.copyWith(selectedTemplate: template);
}

void clearSelection() {
  state = state.copyWith(selectedTemplate: null);
}

void clearFilters() {
  state = state.copyWith(
    selectedBusinessType: null,
    selectedCategory: null,
  );
  _applyFilters();
}

List<TemplateModel> getPopularTemplates() {
  return state.filteredTemplates
      .where((template) => template.isPopular)
      .take(6)
      .toList();
}

List<TemplateModel> getFeaturedTemplates() {
  return state.filteredTemplates
      .where((template) => template.isFeatured)
      .take(4)
      .toList();
}

List<TemplateModel> getTemplatesByBusinessType(BusinessType businessType) {
  return state.filteredTemplates
      .where((template) => template.businessType == businessType)
      .toList();
}
}

// Providers
final templateProvider = StateNotifierProvider<TemplateNotifier, TemplateState>((ref) {
return TemplateNotifier();
});

final templateCollectionsProvider = Provider<List<TemplateCollection>>((ref) {
return ref.watch(templateProvider).collections;
});

final filteredTemplatesProvider = Provider<List<TemplateModel>>((ref) {
return ref.watch(templateProvider).filteredTemplates;
});

final selectedTemplateProvider = Provider<TemplateModel?>((ref) {
return ref.watch(templateProvider).selectedTemplate;
});

final popularTemplatesProvider = Provider<List<TemplateModel>>((ref) {
return ref.watch(templateProvider.notifier).getPopularTemplates();
});

final featuredTemplatesProvider = Provider<List<TemplateModel>>((ref) {
return ref.watch(templateProvider.notifier).getFeaturedTemplates();
});