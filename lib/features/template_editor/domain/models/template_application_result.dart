import 'package:equatable/equatable.dart';

class TemplateApplicationResult extends Equatable {
final String originalImagePath;
final String templateId;
final String finalImagePath;
final bool isSuccess;
final String? error;
final int processingTimeMs;
final Map<String, dynamic> appliedConfig;

const TemplateApplicationResult({
  required this.originalImagePath,
  required this.templateId,
  required this.finalImagePath,
  required this.isSuccess,
  this.error,
  required this.processingTimeMs,
  this.appliedConfig = const {},
});

@override
List<Object?> get props => [
  originalImagePath,
  templateId,
  finalImagePath,
  isSuccess,
  error,
  processingTimeMs,
  appliedConfig,
];
}