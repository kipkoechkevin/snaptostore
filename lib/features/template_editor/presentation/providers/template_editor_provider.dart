import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../templates/domain/models/template_model.dart';
import '../../domain/models/template_editor_state.dart'; // ✅ Add this import
import '../../domain/models/template_application_result.dart';
import '../../data/services/template_application_service.dart';

// Template Editor Notifier
class TemplateEditorNotifier extends StateNotifier<TemplateEditorState> {
final TemplateApplicationService _service;

TemplateEditorNotifier(
  this._service,
  String imagePath,
  TemplateModel template,
) : super(TemplateEditorState(
        originalImagePath: imagePath,
        selectedTemplate: template,
      ));

void updateTemplateConfig(String key, dynamic value) {
  final updatedConfig = Map<String, dynamic>.from(state.templateConfig);
  updatedConfig[key] = value;
  
  state = state.copyWith(templateConfig: updatedConfig);
}

void addCustomElement(EditableElement element) { // ✅ Now EditableElement is available
  final updatedElements = [...state.customElements, element];
  state = state.copyWith(customElements: updatedElements);
}

void updateCustomElement(String elementId, EditableElement updatedElement) {
  final updatedElements = state.customElements.map((element) {
    return element.id == elementId ? updatedElement : element;
  }).toList();
  
  state = state.copyWith(customElements: updatedElements);
}

void removeCustomElement(String elementId) {
  final updatedElements = state.customElements
      .where((element) => element.id != elementId)
      .toList();
  
  state = state.copyWith(customElements: updatedElements);
}

void selectElement(String? elementId) {
  final updatedElements = state.customElements.map((element) {
    return element.copyWith(isSelected: element.id == elementId);
  }).toList();
  
  state = state.copyWith(customElements: updatedElements);
}

void updateZoom(double zoomLevel) {
  state = state.copyWith(zoomLevel: zoomLevel.clamp(0.5, 3.0));
}

void updatePan(Offset panOffset) {
  state = state.copyWith(panOffset: panOffset);
}

void toggleEditing() {
  state = state.copyWith(isEditing: !state.isEditing);
}

Future<TemplateApplicationResult> applyTemplate() async {
  state = state.copyWith(isApplying: true, error: null);
  
  try {
    final result = await _service.applyTemplate(
      imagePath: state.originalImagePath,
      template: state.selectedTemplate,
      config: state.templateConfig,
      customElements: state.customElements, // ✅ This is now List<EditableElement>
    );
    
    if (result.isSuccess) {
      state = state.copyWith(
        processedImagePath: result.finalImagePath,
        isApplying: false,
      );
    } else {
      state = state.copyWith(
        isApplying: false,
        error: result.error,
      );
    }
    
    return result;
  } catch (e) {
    state = state.copyWith(
      isApplying: false,
      error: e.toString(),
    );
    
    return TemplateApplicationResult(
      originalImagePath: state.originalImagePath,
      templateId: state.selectedTemplate.id,
      finalImagePath: '',
      isSuccess: false,
      error: e.toString(),
      processingTimeMs: 0,
    );
  }
}

void resetEditor() {
  state = TemplateEditorState(
    originalImagePath: state.originalImagePath,
    selectedTemplate: state.selectedTemplate,
  );
}

void clearError() {
  state = state.copyWith(error: null);
}
}

// Providers
final templateApplicationServiceProvider = Provider<TemplateApplicationService>((ref) {
return TemplateApplicationService();
});

final templateEditorProvider = StateNotifierProviderFamily<TemplateEditorNotifier, TemplateEditorState, TemplateEditorParams>(
(ref, params) {
  return TemplateEditorNotifier(
    ref.watch(templateApplicationServiceProvider),
    params.imagePath,
    params.template,
  );
},
);

class TemplateEditorParams {
final String imagePath;
final TemplateModel template;

const TemplateEditorParams({
  required this.imagePath,
  required this.template,
});
}

// Convenience providers
final isApplyingTemplateProvider = ProviderFamily<bool, TemplateEditorParams>((ref, params) {
return ref.watch(templateEditorProvider(params)).isApplying;
});

final templateConfigProvider = ProviderFamily<Map<String, dynamic>, TemplateEditorParams>((ref, params) {
return ref.watch(templateEditorProvider(params)).templateConfig;
});

final customElementsProvider = ProviderFamily<List<EditableElement>, TemplateEditorParams>((ref, params) {
return ref.watch(templateEditorProvider(params)).customElements;
});

final selectedElementProvider = ProviderFamily<EditableElement?, TemplateEditorParams>((ref, params) {
final elements = ref.watch(templateEditorProvider(params)).customElements;
return elements.where((element) => element.isSelected).firstOrNull;
});