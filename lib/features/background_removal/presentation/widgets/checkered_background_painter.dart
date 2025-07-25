import 'package:flutter/material.dart';

class CheckeredBackgroundPainter extends CustomPainter {
final double squareSize;
final Color color1;
final Color color2;

CheckeredBackgroundPainter({
  this.squareSize = 10.0,
  this.color1 = const Color(0xFFE0E0E0),
  this.color2 = const Color(0xFFF5F5F5),
});

@override
void paint(Canvas canvas, Size size) {
  final paint1 = Paint()..color = color1;
  final paint2 = Paint()..color = color2;

  for (int i = 0; i < (size.width / squareSize).ceil(); i++) {
    for (int j = 0; j < (size.height / squareSize).ceil(); j++) {
      final rect = Rect.fromLTWH(
        i * squareSize,
        j * squareSize,
        squareSize,
        squareSize,
      );

      canvas.drawRect(
        rect,
        (i + j) % 2 == 0 ? paint1 : paint2,
      );
    }
  }
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}