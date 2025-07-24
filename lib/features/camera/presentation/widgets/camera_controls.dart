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

class _CameraControlsState extends ConsumerState<CameraControls>
  with TickerProviderStateMixin {
late AnimationController _captureController;
late Animation<double> _captureScale;

@override
void initState() {
  super.initState();
  _captureController = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );
  _captureScale = Tween<double>(begin: 1.0, end: 0.9).animate(
    CurvedAnimation(parent: _captureController, curve: Curves.easeInOut),
  );
}

@override
void dispose() {
  _captureController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  final colorScheme = ref.watch(currentColorSchemeProvider);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Gallery Button
        _ControlButton(
          icon: Icons.photo_library_outlined,
          size: 48,
          onTap: widget.onGallery,
          backgroundColor: Colors.black.withOpacity(0.4),
          iconColor: Colors.white,
        ),

        // Capture Button
        AnimatedBuilder(
          animation: _captureController,
          builder: (context, child) {
            return Transform.scale(
              scale: _captureScale.value,
              child: GestureDetector(
                onTapDown: (_) => _captureController.forward(),
                onTapUp: (_) {
                  _captureController.reverse();
                  widget.onCapture();
                },
                onTapCancel: () => _captureController.reverse(),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: colorScheme.gradient,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Switch Camera Button
        _ControlButton(
          icon: Icons.flip_camera_ios_outlined,
          size: 48,
          onTap: widget.onSwitchCamera,
          backgroundColor: Colors.black.withOpacity(0.4),
          iconColor: Colors.white,
        ),
      ],
    ),
  );
}
}

class _ControlButton extends StatelessWidget {
final IconData icon;
final double size;
final VoidCallback onTap;
final Color backgroundColor;
final Color iconColor;

const _ControlButton({
  required this.icon,
  required this.size,
  required this.onTap,
  required this.backgroundColor,
  required this.iconColor,
});

@override
Widget build(BuildContext context) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.5,
        ),
      ),
    ),
  );
}
}