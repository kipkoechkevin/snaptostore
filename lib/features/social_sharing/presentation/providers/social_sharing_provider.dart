import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/social_platform.dart';
import '../../domain/models/share_result.dart';
import '../../data/services/social_sharing_service.dart';

// Social Sharing State
class SocialSharingState {
final List<SocialPlatform> availablePlatforms;
final bool isLoading;
final bool isSharing;
final ShareResult? lastShareResult;
final String? error;
final List<ShareResult> shareHistory;

const SocialSharingState({
  this.availablePlatforms = const [],
  this.isLoading = false,
  this.isSharing = false,
  this.lastShareResult,
  this.error,
  this.shareHistory = const [],
});

SocialSharingState copyWith({
  List<SocialPlatform>? availablePlatforms,
  bool? isLoading,
  bool? isSharing,
  ShareResult? lastShareResult,
  String? error,
  List<ShareResult>? shareHistory,
}) {
  return SocialSharingState(
    availablePlatforms: availablePlatforms ?? this.availablePlatforms,
    isLoading: isLoading ?? this.isLoading,
    isSharing: isSharing ?? this.isSharing,
    lastShareResult: lastShareResult ?? this.lastShareResult,
    error: error,
    shareHistory: shareHistory ?? this.shareHistory,
  );
}
}

// Social Sharing Notifier
class SocialSharingNotifier extends StateNotifier<SocialSharingState> {
final SocialSharingService _service;

SocialSharingNotifier(this._service) : super(const SocialSharingState()) {
  loadAvailablePlatforms();
}

Future<void> loadAvailablePlatforms() async {
  state = state.copyWith(isLoading: true);
  
  try {
    final platforms = await _service.getInstalledPlatforms();
    state = state.copyWith(
      availablePlatforms: platforms,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}

Future<void> shareToInstagram({
  required String imagePath,
  String? caption,
}) async {
  state = state.copyWith(isSharing: true, error: null);
  
  try {
    final result = await _service.shareToInstagram(
      imagePath: imagePath,
      caption: caption,
    );
    
    _updateShareResult(result);
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isSharing: false,
    );
  }
}

Future<void> shareToFacebook({
  required String imagePath,
  String? caption,
  String? url,
}) async {
  state = state.copyWith(isSharing: true, error: null);
  
  try {
    final result = await _service.shareToFacebook(
      imagePath: imagePath,
      caption: caption,
      url: url,
    );
    
    _updateShareResult(result);
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isSharing: false,
    );
  }
}

Future<void> shareToPinterest({
  required String imagePath,
  String? description,
  String? url,
}) async {
  state = state.copyWith(isSharing: true, error: null);
  
  try {
    final result = await _service.shareToPinterest(
      imagePath: imagePath,
      description: description,
      url: url,
    );
    
    _updateShareResult(result);
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isSharing: false,
    );
  }
}

Future<void> shareGeneric({
  required String imagePath,
  String? text,
}) async {
  state = state.copyWith(isSharing: true, error: null);
  
  try {
    final result = await _service.shareGeneric(
      imagePath: imagePath,
      text: text,
    );
    
    _updateShareResult(result);
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isSharing: false,
    );
  }
}

void _updateShareResult(ShareResult result) {
  final updatedHistory = [...state.shareHistory, result];
  state = state.copyWith(
    lastShareResult: result,
    shareHistory: updatedHistory,
    isSharing: false,
  );
}

void clearError() {
  state = state.copyWith(error: null);
}

void clearShareResult() {
  state = state.copyWith(lastShareResult: null);
}
}

// Providers
final socialSharingServiceProvider = Provider<SocialSharingService>((ref) {
return SocialSharingService();
});

final socialSharingProvider = StateNotifierProvider<SocialSharingNotifier, SocialSharingState>((ref) {
return SocialSharingNotifier(ref.watch(socialSharingServiceProvider));
});

final availablePlatformsProvider = Provider<List<SocialPlatform>>((ref) {
return ref.watch(socialSharingProvider).availablePlatforms;
});

final isLoadingPlatformsProvider = Provider<bool>((ref) {
return ref.watch(socialSharingProvider).isLoading;
});

final isSharingProvider = Provider<bool>((ref) {
return ref.watch(socialSharingProvider).isSharing;
});