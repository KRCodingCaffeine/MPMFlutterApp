import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double waveHeight;
  WavePainter(this.waveHeight);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.orange // Set the wave color
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Starting point of the wave
    path.moveTo(0, size.height * 0.7);

    // First wave
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.6, // Control point
      size.width * 0.5, size.height * 0.7, // End point
    );

    // Second wave
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.8, // Control point
      size.width, size.height * 0.7, // End point
    );

    // Close the shape at the bottom
    path.lineTo(size.width, size.height); // Bottom-right corner
    path.lineTo(0, size.height); // Bottom-left corner
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
