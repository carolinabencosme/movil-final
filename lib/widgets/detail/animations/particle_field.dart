import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Animated particle field background
class ParticleField extends StatelessWidget {
  const ParticleField({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: ParticlePainter(color),
      ),
    );
  }
}

/// Custom painter for particle field effect
class ParticlePainter extends CustomPainter {
  const ParticlePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = size.shortestSide;
    final baseRadius = shortestSide * 0.06;
    final blurPaint = Paint()
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);

    final clusters = <Offset>[
      Offset(size.width * 0.2, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.42),
      Offset(size.width * 0.65, size.height * 0.18),
      Offset(size.width * 0.35, size.height * 0.72),
      Offset(size.width * 0.55, size.height * 0.58),
    ];

    for (final offset in clusters) {
      final gradientPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ).createShader(
          Rect.fromCircle(center: offset, radius: baseRadius * 1.8),
        );

      canvas.drawCircle(offset, baseRadius * 1.6, gradientPaint);
      blurPaint.color = color.withOpacity(0.35);
      canvas.drawCircle(offset, baseRadius, blurPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
