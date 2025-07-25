import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/models/camera_state.dart';

class CameraNotifier extends StateNotifier<CameraState> {
CameraNotifier() : super(const CameraState());

Future<void> initializeCamera() async {
  try {
    // Request camera permission
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      state = state.copyWith(
        error: 'Camera permission denied',
        hasPermission: false,
      );
      return;
    }

    // Get available cameras
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      state = state.copyWith(
        error: 'No cameras found',
        hasPermission: true,
      );
      return;
    }

    state = state.copyWith(
      availableCameras: cameras,
      hasPermission: true,
    );

    await _initializeController();
  } catch (e) {
    state = state.copyWith(
      error: 'Failed to initialize camera: $e',
    );
  }
}

Future<bool> _requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status == PermissionStatus.granted;
}

Future<void> _initializeController() async {
  try {
    final cameras = state.availableCameras;
    if (cameras.isEmpty) return;

    final controller = CameraController(
      cameras[state.selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    await controller.setFlashMode(state.flashMode);

    state = state.copyWith(
      controller: controller,
      isInitialized: true,
      error: null,
    );
  } catch (e) {
    state = state.copyWith(
      error: 'Failed to initialize camera controller: $e',
    );
  }
}

Future<void> capturePhoto() async {
  if (!state.isInitialized || state.controller == null) return;

  state = state.copyWith(isCapturing: true, error: null);

  try {
    final image = await state.controller!.takePicture();
    
    // Save to app directory
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = path.join(
      directory.path,
      'snaptostore_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    
    await image.saveTo(imagePath);

    state = state.copyWith(
      isCapturing: false,
      capturedImagePath: imagePath,
    );
  } catch (e) {
    state = state.copyWith(
      isCapturing: false,
      error: 'Failed to capture photo: $e',
    );
  }
}

Future<void> toggleFlash() async {
  if (!state.isInitialized || state.controller == null) return;

  FlashMode newMode;
  switch (state.flashMode) {
    case FlashMode.auto:
      newMode = FlashMode.always;
      break;
    case FlashMode.always:
      newMode = FlashMode.off;
      break;
    case FlashMode.off:
      newMode = FlashMode.auto;
      break;
    case FlashMode.torch:
      newMode = FlashMode.auto;
      break;
  }

  try {
    await state.controller!.setFlashMode(newMode);
    state = state.copyWith(flashMode: newMode);
  } catch (e) {
    state = state.copyWith(error: 'Failed to toggle flash: $e');
  }
}

Future<void> switchCamera() async {
  if (state.availableCameras.length < 2) return;

  final newIndex = state.selectedCameraIndex == 0 ? 1 : 0;
  
  // Dispose current controller
  await state.controller?.dispose();
  
  state = state.copyWith(
    selectedCameraIndex: newIndex,
    isInitialized: false,
    controller: null,
  );

  await _initializeController();
}

void clearError() {
  state = state.copyWith(error: null);
}

void clearCapturedImage() {
  state = state.copyWith(capturedImagePath: null);
}

@override
void dispose() {
  state.controller?.dispose();
  super.dispose();
}
}

// Providers
final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
return CameraNotifier();
});

final cameraControllerProvider = Provider<CameraController?>((ref) {
return ref.watch(cameraProvider).controller;
});

final isCameraInitializedProvider = Provider<bool>((ref) {
return ref.watch(cameraProvider).isInitialized;
});