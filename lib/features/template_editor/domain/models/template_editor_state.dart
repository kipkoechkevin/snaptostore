import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../templates/domain/models/template_model.dart';

class TemplateEditorState extends Equatable {
final String originalImagePath;
final String? processedImagePath;
final TemplateModel selectedTemplate;
final Map<String, dynamic> templateConfig;
final List<EditableElement> customElements; // ✅ Fixed: Changed from List<TemplateElement> to List<EditableElement>
final bool isApplying;
final bool isEditing;
final String? error;
final double zoomLevel;
final Offset panOffset;

const TemplateEditorState({
  required this.originalImagePath,
  this.processedImagePath,
  required this.selectedTemplate,
  this.templateConfig = const {},
  this.customElements = const [],
  this.isApplying = false,
  this.isEditing = false,
  this.error,
  this.zoomLevel = 1.0,
  this.panOffset = Offset.zero,
});

TemplateEditorState copyWith({
  String? originalImagePath,
  String? processedImagePath,
  TemplateModel? selectedTemplate,
  Map<String, dynamic>? templateConfig,
  List<EditableElement>? customElements, // ✅ Fixed: Changed type here too
  bool? isApplying,
  bool? isEditing,
  String? error,
  double? zoomLevel,
  Offset? panOffset,
}) {
  return TemplateEditorState(
    originalImagePath: originalImagePath ?? this.originalImagePath,
    processedImagePath: processedImagePath ?? this.processedImagePath,
    selectedTemplate: selectedTemplate ?? this.selectedTemplate,
    templateConfig: templateConfig ?? this.templateConfig,
    customElements: customElements ?? this.customElements,
    isApplying: isApplying ?? this.isApplying,
    isEditing: isEditing ?? this.isEditing,
    error: error,
    zoomLevel: zoomLevel ?? this.zoomLevel,
    panOffset: panOffset ?? this.panOffset,
  );
}

@override
List<Object?> get props => [
  originalImagePath,
  processedImagePath,
  selectedTemplate,
  templateConfig,
  customElements,
  isApplying,
  isEditing,
  error,
  zoomLevel,
  panOffset,
];
}

class EditableElement extends Equatable {
final String id;
final ElementType type;
final String content;
final Offset position;
final Size size;
final double rotation;
final Map<String, dynamic> style;
final bool isSelected;

const EditableElement({
  required this.id,
  required this.type,
  required this.content,
  required this.position,
  required this.size,
  this.rotation = 0.0,
  this.style = const {},
  this.isSelected = false,
});

EditableElement copyWith({
  String? id,
  ElementType? type,
  String? content,
  Offset? position,
  Size? size,
  double? rotation,
  Map<String, dynamic>? style,
  bool? isSelected,
}) {
  return EditableElement(
    id: id ?? this.id,
    type: type ?? this.type,
    content: content ?? this.content,
    position: position ?? this.position,
    size: size ?? this.size,
    rotation: rotation ?? this.rotation,
    style: style ?? this.style,
    isSelected: isSelected ?? this.isSelected,
  );
}

@override
List<Object?> get props => [id, type, content, position, size, rotation, style, isSelected];
}