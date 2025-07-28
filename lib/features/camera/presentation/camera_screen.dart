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
  with TickerProviderStateMixin, WidgetsBindingObserver { // ✅ Added WidgetsBindingObserver
late AnimationController _overlayController;
late Animation<double> _overlayAnimation;

@override
void initState() {
  super.initState();
  
  // ✅ Add app lifecycle observer
  WidgetsBinding.instance.addObserver(this);
  
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
// ✅ Store the provider reference BEFORE disposal
final cameraNotifier = ref.read(cameraProvider.notifier);

// Remove observer and dispose animations first
WidgetsBinding.instance.removeObserver(this);
_overlayController.dispose();

// Call super.dispose() first to clean up the widget
super.dispose();

// ✅ Now dispose camera using the stored reference
Future(() {
  cameraNotifier.disposeCamera();
});
}

// ✅ Handle app lifecycle changes
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
final cameraController = ref.read(cameraProvider).controller;
if (cameraController == null || !cameraController.value.isInitialized) {
  return;
}

// ✅ Store provider reference to avoid disposal issues
final cameraNotifier = ref.read(cameraProvider.notifier);

if (state == AppLifecycleState.inactive) {
  // App is inactive, dispose camera
  Future(() {
    cameraNotifier.disposeCamera();
  });
} else if (state == AppLifecycleState.resumed) {
  // App resumed, reinitialize camera
  Future(() {
    cameraNotifier.initializeCamera();
  });
}
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

        // ✅ Show error message if any
        if (cameraState.error != null)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    cameraState.error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // ✅ Wrap in Future to avoid build-time modification
                      Future(() {
                        ref.read(cameraProvider.notifier).clearError();
                        ref.read(cameraProvider.notifier).initializeCamera();
                      });
                    },
                    child: const Text('Retry'),
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

// ✅ Updated capture method with proper disposal and navigation
Future<void> _capturePhoto() async {
  final cameraState = ref.read(cameraProvider);
  
  if (cameraState.isCapturing) {
    print('Already capturing, ignoring');
    return;
  }
  
  try {
    print('Starting capture...');
    await ref.read(cameraProvider.notifier).capturePhoto();
    
    final updatedState = ref.read(cameraProvider);
    
    if (updatedState.error != null) {
      print('Capture error: ${updatedState.error}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updatedState.error!),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                // ✅ Wrap in Future to avoid build-time modification
                Future(() {
                  ref.read(cameraProvider.notifier).clearError();
                  ref.read(cameraProvider.notifier).reinitializeCamera();
                });
              },
            ),
          ),
        );
      }
      return;
    }
    
    if (updatedState.capturedImagePath != null && mounted) {
      final imagePath = updatedState.capturedImagePath!;
      
      print('Image captured, preparing for navigation...');
      
      // ✅ Use Future to defer provider modifications
      Future(() async {
        try {
          // Clear state first
          ref.read(cameraProvider.notifier).clearCapturedImage();
          
          // Dispose camera properly before navigation
          await ref.read(cameraProvider.notifier).disposeCamera();
          
          // Add delay to ensure camera is fully disposed
          await Future.delayed(const Duration(milliseconds: 500));
          
          print('Camera disposed, navigating to background removal...');
          
          // Navigate after camera is disposed
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BackgroundRemovalScreen(
                  imagePath: imagePath,
                ),
              ),
            ).then((_) {
              // ✅ Reinitialize camera when returning - also wrapped in Future
              if (mounted) {
                Future(() {
                  ref.read(cameraProvider.notifier).initializeCamera();
                });
              }
            });
          }
        } catch (e) {
          print('Navigation error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigation failed: $e')),
            );
          }
        }
      });
    }
  } catch (e) {
    print('Capture exception: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture failed: $e'),
          action: SnackBarAction(
            label: 'Reinitialize',
            onPressed: () {
              // ✅ Wrap in Future
              Future(() {
                ref.read(cameraProvider.notifier).reinitializeCamera();
              });
            },
          ),
        ),
      );
    }
  }
}

void _openGallery() {
  // TODO: Implement gallery picker
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Gallery picker coming soon!')),
  );
}
}