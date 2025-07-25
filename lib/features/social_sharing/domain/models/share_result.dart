import 'package:equatable/equatable.dart';
import 'social_platform.dart';

class ShareResult extends Equatable {
final SocialPlatformType platform;
final bool isSuccess;
final String? error;
final DateTime timestamp;
final Map<String, dynamic> metadata;

const ShareResult({
  required this.platform,
  required this.isSuccess,
  this.error,
  required this.timestamp,
  this.metadata = const {},
});

@override
List<Object?> get props => [platform, isSuccess, error, timestamp, metadata];
}