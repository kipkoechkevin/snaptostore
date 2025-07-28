import 'package:equatable/equatable.dart';

enum ProjectStatus {
draft('Draft'),
completed('Completed'),
archived('Archived');

const ProjectStatus(this.label);
final String label;

static ProjectStatus fromString(String value) {
  switch (value.toLowerCase()) {
    case 'draft':
      return ProjectStatus.draft;
    case 'completed':
      return ProjectStatus.completed;
    case 'archived':
      return ProjectStatus.archived;
    default:
      return ProjectStatus.draft;
  }
}
}

class ProjectModel extends Equatable {
final String id;
final String userId;
final String title;
final String? description;
final String businessType;
final String? templateId;
final String? originalImageUrl;
final String? processedImageUrl;
final String? backgroundRemovedUrl;
final ProjectStatus status;
final Map<String, dynamic>? settings;
final DateTime createdAt;
final DateTime updatedAt;

const ProjectModel({
  required this.id,
  required this.userId,
  required this.title,
  this.description,
  required this.businessType,
  this.templateId,
  this.originalImageUrl,
  this.processedImageUrl,
  this.backgroundRemovedUrl,
  required this.status,
  this.settings,
  required this.createdAt,
  required this.updatedAt,
});

@override
List<Object?> get props => [
      id,
      userId,
      title,
      description,
      businessType,
      templateId,
      originalImageUrl,
      processedImageUrl,
      backgroundRemovedUrl,
      status,
      settings,
      createdAt,
      updatedAt,
    ];

ProjectModel copyWith({
  String? id,
  String? userId,
  String? title,
  String? description,
  String? businessType,
  String? templateId,
  String? originalImageUrl,
  String? processedImageUrl,
  String? backgroundRemovedUrl,
  ProjectStatus? status,
  Map<String, dynamic>? settings,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return ProjectModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    businessType: businessType ?? this.businessType,
    templateId: templateId ?? this.templateId,
    originalImageUrl: originalImageUrl ?? this.originalImageUrl,
    processedImageUrl: processedImageUrl ?? this.processedImageUrl,
    backgroundRemovedUrl: backgroundRemovedUrl ?? this.backgroundRemovedUrl,
    status: status ?? this.status,
    settings: settings ?? this.settings,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'business_type': businessType,
    'template_id': templateId,
    'original_image_url': originalImageUrl,
    'processed_image_url': processedImageUrl,
    'background_removed_url': backgroundRemovedUrl,
    'status': status.name,
    'settings': settings,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

factory ProjectModel.fromJson(Map<String, dynamic> json) {
  return ProjectModel(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    businessType: json['business_type'] as String,
    templateId: json['template_id'] as String?,
    originalImageUrl: json['original_image_url'] as String?,
    processedImageUrl: json['processed_image_url'] as String?,
    backgroundRemovedUrl: json['background_removed_url'] as String?,
    status: ProjectStatus.fromString(json['status'] as String),
    settings: json['settings'] as Map<String, dynamic>?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

// Helper methods
bool get isDraft => status == ProjectStatus.draft;
bool get isCompleted => status == ProjectStatus.completed;
bool get isArchived => status == ProjectStatus.archived;

String get thumbnailUrl => processedImageUrl ?? originalImageUrl ?? '';

String get statusLabel => status.label;

bool get hasImages => originalImageUrl != null || processedImageUrl != null;
}