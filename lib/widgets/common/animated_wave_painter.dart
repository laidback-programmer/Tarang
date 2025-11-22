import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated wave painter for ocean-themed background effects
class AnimatedWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  AnimatedWavePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 10.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final x = i;
      final y = size.height -
          20 +
          math.sin((i / waveLength + animationValue) * 2 * math.pi) *
              waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final x = i;
      final y = size.height -
          15 +
          math.sin((i / waveLength - animationValue) * 2 * math.pi) *
              (waveHeight * 0.8);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(AnimatedWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Ripple painter for water droplet effect
class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int rippleCount;

  RipplePainter({
    required this.progress,
    required this.color,
    this.rippleCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < rippleCount; i++) {
      final rippleProgress = (progress - (i * 0.1)).clamp(0.0, 1.0);
      final radius = maxRadius * rippleProgress;
      final opacity = (1 - rippleProgress) * 0.5;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      if (rippleProgress > 0) {
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Bubble painter for floating bubbles effect
class BubblePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final List<BubbleData> bubbles;

  BubblePainter({
    required this.animationValue,
    required this.color,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final yOffset =
          (animationValue * bubble.speed * size.height) % (size.height + 20);
      final y = size.height - yOffset;

      if (y < size.height && y > -bubble.radius) {
        final paint = Paint()
          ..color = color.withOpacity(bubble.opacity)
          ..style = PaintingStyle.fill;

        final center = Offset(bubble.x * size.width, y);
        canvas.drawCircle(center, bubble.radius, paint);

        // Add shine effect
        final shinePaint = Paint()
          ..color = Colors.white.withOpacity(bubble.opacity * 0.6)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
              center.dx - bubble.radius * 0.3, center.dy - bubble.radius * 0.3),
          bubble.radius * 0.3,
          shinePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class BubbleData {
  final double x;
  final double radius;
  final double speed;
  final double opacity;

  BubbleData({
    required this.x,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}
