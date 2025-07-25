import 'package:equatable/equatable.dart';

class RemoveBgResponse extends Equatable {
final bool success;
final String? imageData; // Base64 encoded image
final String? error;
final Map<String, dynamic>? metadata;

const RemoveBgResponse({
  required this.success,
  this.imageData,
  this.error,
  this.metadata,
});

factory RemoveBgResponse.fromJson(Map<String, dynamic> json) {
  return RemoveBgResponse(
    success: json['success'] ?? false,
    imageData: json['image_data'],
    error: json['error'],
    metadata: json['metadata'],
  );
}

@override
List<Object?> get props => [success, imageData, error, metadata];
}