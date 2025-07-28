import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../../domain/models/camera_state.dart';

class CameraNotifier extends StateNotifier<CameraState> {
CameraNotifier() : super(const CameraState());

bool _isCapturing = false;
bool _isDisposing = false;

Future<void> initializeCamera() async {
  if (_isDisposing) return;
  
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
  if (_isDisposing) return;
  
  try {
    final cameras = state.availableCameras;
    if (cameras.isEmpty) return;

    // ✅ Dispose existing controller with proper cleanup
    await _safeDisposeController();

    // ✅ Add delay to ensure proper disposal
    await Future.delayed(const Duration(milliseconds: 500));

    final controller = CameraController(
      cameras[state.selectedCameraIndex],
      ResolutionPreset.medium, // ✅ Keep medium resolution
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // ✅ Initialize with timeout
    await controller.initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Camera initialization timeout');
      },
    );

    if (_isDisposing) {
      await controller.dispose();
      return;
    }

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

Future<void> _safeDisposeController() async {
  final controller = state.controller;
  if (controller != null) {
    try {
      if (controller.value.isInitialized) {
        await controller.dispose();
      }
    } catch (e) {
      print('Error disposing controller: $e');
    }
  }
  
  // ✅ Force garbage collection
  await Future.delayed(const Duration(milliseconds: 100));
}

Future<void> capturePhoto() async {
  // ✅ Multiple checks to prevent simultaneous captures
  if (_isCapturing || 
      _isDisposing ||
      !state.isInitialized || 
      state.controller == null || 
      state.isCapturing ||
      !state.controller!.value.isInitialized) {
    print('Capture blocked: _isCapturing=$_isCapturing, _isDisposing=$_isDisposing, isInitialized=${state.isInitialized}');
    return;
  }

  _isCapturing = true;
  state = state.copyWith(isCapturing: true, error: null);

  try {
    // ✅ Ensure controller is ready
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_isDisposing || !state.controller!.value.isInitialized) {
      throw Exception('Camera not ready for capture');
    }

    // ✅ Capture with timeout
    final image = await state.controller!.takePicture().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Capture timeout');
      },
    );
    
    // ✅ Save to app directory with unique filename
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imagePath = path.join(
      directory.path,
      'snaptostore_$timestamp.jpg',
    );
    
    // ✅ Save with error handling
    await image.saveTo(imagePath).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Save timeout');
      },
    );

    // ✅ Verify file was created
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Failed to save image file');
    }

    state = state.copyWith(
      isCapturing: false,
      capturedImagePath: imagePath,
    );
    
    print('Photo captured successfully: $imagePath');
  } catch (e) {
    print('Capture error: $e');
    state = state.copyWith(
      isCapturing: false,
      error: 'Failed to capture photo: $e',
    );
  } finally {
    _isCapturing = false;
  }
}

Future<void> toggleFlash() async {
  if (!state.isInitialized || state.controller == null || _isDisposing) return;

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
  if (state.availableCameras.length < 2 || _isDisposing) return;

  final newIndex = state.selectedCameraIndex == 0 ? 1 : 0;
  
  // ✅ Properly dispose current controller
  await _safeDisposeController();
  
  state = state.copyWith(
    selectedCameraIndex: newIndex,
    isInitialized: false,
    controller: null,
    isCapturing: false,
  );

  // ✅ Add delay before reinitializing
  await Future.delayed(const Duration(milliseconds: 1000));
  
  if (!_isDisposing) {
    await _initializeController();
  }
}

Future<void> disposeCamera() async {
  _isDisposing = true;
  _isCapturing = false;
  
  await _safeDisposeController();
  
  state = state.copyWith(
    controller: null,
    isInitialized: false,
    isCapturing: false,
    capturedImagePath: null,
  );
  
  print('Camera disposed');
}

Future<void> reinitializeCamera() async {
  await disposeCamera();
  _isDisposing = false;
  await Future.delayed(const Duration(milliseconds: 1000));
  await initializeCamera();
}

void clearError() {
  state = state.copyWith(error: null);
}

void clearCapturedImage() {
  state = state.copyWith(capturedImagePath: null);
}

@override
void dispose() {
  _isDisposing = true;
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