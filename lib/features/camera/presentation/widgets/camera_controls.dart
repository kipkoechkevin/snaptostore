import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';

class CameraControls extends ConsumerStatefulWidget {
final VoidCallback onCapture;
final VoidCallback onGallery;
final VoidCallback onSwitchCamera;

const CameraControls({
  super.key,
  required this.onCapture,
  required this.onGallery,
  required this.onSwitchCamera,
});

@override
ConsumerState<CameraControls> createState() => _CameraControlsState();
}

class _CameraControlsState extends ConsumerState<CameraControls> {
DateTime? _lastCaptureTime;

// ✅ Debounce capture button (prevent rapid taps)
void _debouncedCapture() {
  final now = DateTime.now();
  if (_lastCaptureTime != null && 
      now.difference(_lastCaptureTime!).inMilliseconds < 2000) {
    print('Capture debounced');
    return;
  }
  
  _lastCaptureTime = now;
  widget.onCapture();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Gallery Button
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: widget.onGallery,
              child: const Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        // Capture Button
        GestureDetector(
          onTap: _debouncedCapture, // ✅ Use debounced version
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: colorScheme.primary, width: 4),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

        // Switch Camera Button
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: widget.onSwitchCamera,
              child: const Icon(
                Icons.cameraswitch,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}