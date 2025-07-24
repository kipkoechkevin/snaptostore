import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraOverlay extends ConsumerWidget {
const CameraOverlay({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  return Stack(
    children: [
      // Grid Lines
      _GridLines(),
      
      // Focus Frame
      const _FocusFrame(),
      
      // Tips - Fixed positioning and constraints
      Positioned(
        top: MediaQuery.of(context).padding.top + 80,
        left: 24,
        right: 24, // ✅ Add right constraint
        child: _CameraTips(),
      ),
    ],
  );
}
}

class _GridLines extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return CustomPaint(
    size: Size.infinite,
    painter: _GridPainter(),
  );
}
}

class _GridPainter extends CustomPainter {
@override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = Colors.white.withOpacity(0.3)
    ..strokeWidth = 1;

  // Vertical lines
  final verticalSpacing = size.width / 3;
  for (int i = 1; i < 3; i++) {
    canvas.drawLine(
      Offset(verticalSpacing * i, 0),
      Offset(verticalSpacing * i, size.height),
      paint,
    );
  }

  // Horizontal lines
  final horizontalSpacing = size.height / 3;
  for (int i = 1; i < 3; i++) {
    canvas.drawLine(
      Offset(0, horizontalSpacing * i),
      Offset(size.width, horizontalSpacing * i),
      paint,
    );
  }
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FocusFrame extends StatefulWidget {
const _FocusFrame();

@override
State<_FocusFrame> createState() => _FocusFrameState();
}

class _FocusFrameState extends State<_FocusFrame>
  with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scaleAnimation;
Offset? _focusPoint;

@override
void initState() {
  super.initState();
  _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  _scaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
  );
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTapDown: (details) {
      setState(() {
        _focusPoint = details.localPosition;
      });
      _controller.forward(from: 0);
      
      // Hide focus point after animation
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _focusPoint = null;
          });
        }
      });
    },
    child: Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: _focusPoint != null
          ? Stack(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Positioned(
                      left: _focusPoint!.dx - 40,
                      top: _focusPoint!.dy - 40,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
    ),
  );
}
}

class _CameraTips extends ConsumerStatefulWidget {
@override
ConsumerState<_CameraTips> createState() => _CameraTipsState();
}

class _CameraTipsState extends ConsumerState<_CameraTips>
  with SingleTickerProviderStateMixin {
late AnimationController _tipController;
late Animation<double> _tipOpacity;
int _currentTip = 0;

// ✅ Shorter tips to prevent overflow
final List<String> _tips = [
  'Tap to focus on your product',
  'Use natural lighting for best results',
  'Keep the product centered',
  'Remove background clutter',
];

@override
void initState() {
  super.initState();
  _tipController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  _tipOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _tipController, curve: Curves.easeInOut),
  );

  _startTipRotation();
}

void _startTipRotation() {
  _tipController.forward();
  
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
      _tipController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentTip = (_currentTip + 1) % _tips.length;
          });
          _startTipRotation();
        }
      });
    }
  });
}

@override
void dispose() {
  _tipController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _tipController,
    builder: (context, child) {
      return Opacity(
        opacity: _tipOpacity.value,
        child: Center( // ✅ Center the tip
          child: Container(
            // ✅ Add constraints to prevent overflow
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 48,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // ✅ Important for centering
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.yellow.shade300,
                  size: 16,
                ),
                const SizedBox(width: 8),
                // ✅ Use Flexible instead of Expanded for better overflow handling
                Flexible(
                  child: Text(
                    _tips[_currentTip],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    // ✅ Add overflow handling
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}