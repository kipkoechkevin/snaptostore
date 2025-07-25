import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../core/core.dart';
import '../presentation/providers/camera_provider.dart';
import '../presentation/widgets/camera_controls.dart';
import '../presentation/widgets/camera_overlay.dart';
import '../../background_removal/presentation/background_removal_screen.dart';

class CameraScreen extends ConsumerStatefulWidget {
const CameraScreen({super.key});

@override
ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
  with TickerProviderStateMixin {
late AnimationController _overlayController;
late Animation<double> _overlayAnimation;

@override
void initState() {
  super.initState();
  _overlayController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  _overlayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _overlayController, curve: Curves.easeOut),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(cameraProvider.notifier).initializeCamera();
    _overlayController.forward();
  });
}

@override
void dispose() {
  _overlayController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final cameraState = ref.watch(cameraProvider);
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // Camera Preview
        if (cameraState.controller != null && cameraState.isInitialized)
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: cameraState.controller!.value.aspectRatio,
              child: CameraPreview(cameraState.controller!),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),

        // Camera Overlay
        if (cameraState.isInitialized)
          FadeTransition(
            opacity: _overlayAnimation,
            child: const CameraOverlay(),
          ),

        // Top Controls
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Flash Toggle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => ref.read(cameraProvider.notifier).toggleFlash(),
                    child: Icon(
                      _getFlashIcon(cameraState.flashMode),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Controls
        if (cameraState.isInitialized)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: CameraControls(
              onCapture: () => _capturePhoto(),
              onGallery: () => _openGallery(),
              onSwitchCamera: () => ref.read(cameraProvider.notifier).switchCamera(),
            ),
          ),

        // Loading Overlay
        if (cameraState.isCapturing)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Capturing...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

IconData _getFlashIcon(FlashMode flashMode) {
  switch (flashMode) {
    case FlashMode.auto:
      return Icons.flash_auto;
    case FlashMode.always:
      return Icons.flash_on;
    case FlashMode.off:
      return Icons.flash_off;
    case FlashMode.torch:
      return Icons.flashlight_on;
  }
}

// Update the _capturePhoto method:
Future<void> _capturePhoto() async {
try {
  await ref.read(cameraProvider.notifier).capturePhoto();
  
  final cameraState = ref.read(cameraProvider);
  if (cameraState.capturedImagePath != null && mounted) {
    // Navigate to background removal screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BackgroundRemovalScreen(
          imagePath: cameraState.capturedImagePath!,
        ),
      ),
    );
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to capture photo: $e')),
  );
}
}

void _openGallery() {
  // TODO: Implement gallery picker
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Gallery picker coming soon!')),
  );
}
}