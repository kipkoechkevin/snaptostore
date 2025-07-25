import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/background_removal_result.dart';
import '../../data/services/background_processor.dart';

// Background Removal State
class BackgroundRemovalState {
final bool isProcessing;
final BackgroundRemovalResult? result;
final String? error;
final double progress;
final String? currentStep;

const BackgroundRemovalState({
  this.isProcessing = false,
  this.result,
  this.error,
  this.progress = 0.0,
  this.currentStep,
});

BackgroundRemovalState copyWith({
  bool? isProcessing,
  BackgroundRemovalResult? result,
  String? error,
  double? progress,
  String? currentStep,
}) {
  return BackgroundRemovalState(
    isProcessing: isProcessing ?? this.isProcessing,
    result: result ?? this.result,
    error: error,
    progress: progress ?? this.progress,
    currentStep: currentStep ?? this.currentStep,
  );
}
}

// Background Removal Notifier
class BackgroundRemovalNotifier extends StateNotifier<BackgroundRemovalState> {
final BackgroundProcessor _processor;

BackgroundRemovalNotifier(this._processor) : super(const BackgroundRemovalState());

Future<void> processImage({
  required String imagePath,
  required BackgroundOption backgroundOption,
}) async {
  state = state.copyWith(
    isProcessing: true,
    error: null,
    progress: 0.0,
    currentStep: 'Preparing image...',
  );

  try {
    // Update progress
    state = state.copyWith(
      progress: 0.2,
      currentStep: 'Removing background...',
    );

    // Process the image
    final result = await _processor.processImage(
      imagePath: imagePath,
      backgroundOption: backgroundOption,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        isProcessing: false,
        result: result,
        progress: 1.0,
        currentStep: 'Complete!',
      );
    } else {
      state = state.copyWith(
        isProcessing: false,
        error: result.error,
        progress: 0.0,
        currentStep: null,
      );
    }
  } catch (e) {
    state = state.copyWith(
      isProcessing: false,
      error: e.toString(),
      progress: 0.0,
      currentStep: null,
    );
  }
}

void clearResult() {
  state = const BackgroundRemovalState();
}

void clearError() {
  state = state.copyWith(error: null);
}
}

// Providers
final backgroundProcessorProvider = Provider<BackgroundProcessor>((ref) {
return BackgroundProcessor();
});

final backgroundRemovalProvider = StateNotifierProvider<BackgroundRemovalNotifier, BackgroundRemovalState>((ref) {
return BackgroundRemovalNotifier(ref.watch(backgroundProcessorProvider));
});

final backgroundOptionsProvider = Provider<List<BackgroundOption>>((ref) {
return BackgroundOption.defaultOptions;
});