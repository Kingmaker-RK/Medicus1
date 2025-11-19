import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom painted hospital-themed background with medical graphics
class HospitalBackground extends StatelessWidget {
  final Widget child;
  final double opacity;

  const HospitalBackground({Key? key, required this.child, this.opacity = 0.4})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // BOLD, VIBRANT gradient background - dramatically visible!
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1976D2), // BOLD deep blue
                const Color(0xFF00BCD4), // BRIGHT cyan
                const Color(0xFF4CAF50), // VIBRANT green
                const Color(0xFFFF9800), // BRIGHT orange
                const Color(0xFFE91E63), // BOLD pink
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
        ),

        // Medical graphics pattern with enhanced visuals
        CustomPaint(
          painter: HospitalGraphicsPainter(opacity: opacity),
          size: Size.infinite,
        ),

        // REDUCED overlay - let the vibrant colors show through!
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}

/// Custom painter for hospital-themed graphics
class HospitalGraphicsPainter extends CustomPainter {
  final double opacity;

  HospitalGraphicsPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    // SUPER BOLD, HIGH CONTRAST colors - extremely visible!
    final bluePaint = Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final redPaint = Paint()
      ..color = const Color(0xFFC62828).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final greenPaint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final purplePaint = Paint()
      ..color = const Color(0xFF6A1B9A).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final orangePaint = Paint()
      ..color = const Color(0xFFD84315).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF0D47A1).withValues(alpha: opacity * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Draw floating medical pills/capsules
    _drawMedicalPills(canvas, size, redPaint, bluePaint, greenPaint);

    // Draw beautiful hearts
    _drawHearts(canvas, size, redPaint);

    // Draw modern medical crosses
    _drawMedicalCrosses(canvas, size, redPaint);

    // Draw hospital building silhouettes (more modern)
    _drawHospitalBuildings(canvas, size, bluePaint, outlinePaint);

    // Draw smooth heartbeat lines
    _drawHeartbeatLines(canvas, size, greenPaint);

    // Draw stethoscopes
    _drawStethoscopes(canvas, size, purplePaint);

    // Draw DNA helix pattern
    _drawDNAHelix(canvas, size, bluePaint, greenPaint);

    // Draw medical shields (protection/care symbol)
    _drawMedicalShields(canvas, size, orangePaint);

    // Draw decorative circles/dots
    _drawDecorativeCircles(canvas, size, bluePaint, greenPaint, purplePaint);
  }

  void _drawMedicalCrosses(Canvas canvas, Size size, Paint paint) {
    // MUCH LARGER crosses - 3x bigger!
    final positions = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.5),
      Offset(size.width * 0.45, size.height * 0.65),
    ];

    for (final pos in positions) {
      _drawCross(canvas, pos, 70, paint); // 3x bigger!
    }
  }

  void _drawCross(Canvas canvas, Offset center, double size, Paint paint) {
    final horizontalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size * 1.5, height: size * 0.5),
      const Radius.circular(3),
    );
    final verticalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size * 0.5, height: size * 1.5),
      const Radius.circular(3),
    );

    canvas.drawRRect(horizontalRect, paint);
    canvas.drawRRect(verticalRect, paint);
  }

  void _drawHospitalBuildings(
    Canvas canvas,
    Size size,
    Paint fillPaint,
    Paint outlinePaint,
  ) {
    // Left building
    final building1 = Path()
      ..moveTo(size.width * 0.05, size.height * 0.4)
      ..lineTo(size.width * 0.05, size.height * 0.25)
      ..lineTo(size.width * 0.15, size.height * 0.2)
      ..lineTo(size.width * 0.25, size.height * 0.25)
      ..lineTo(size.width * 0.25, size.height * 0.4)
      ..close();

    canvas.drawPath(building1, fillPaint);
    canvas.drawPath(building1, outlinePaint);

    // Right building
    final building2 = Path()
      ..moveTo(size.width * 0.75, size.height * 0.6)
      ..lineTo(size.width * 0.75, size.height * 0.45)
      ..lineTo(size.width * 0.85, size.height * 0.4)
      ..lineTo(size.width * 0.95, size.height * 0.45)
      ..lineTo(size.width * 0.95, size.height * 0.6)
      ..close();

    canvas.drawPath(building2, fillPaint);
    canvas.drawPath(building2, outlinePaint);

    // Add H symbols on buildings
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'H',
        style: TextStyle(
          color: Colors.white.withValues(alpha: opacity * 2),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.13, size.height * 0.28));
    textPainter.paint(canvas, Offset(size.width * 0.83, size.height * 0.48));
  }

  void _drawHeartbeatLines(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6; // Double thickness!

    final path1 = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.25, size.height * 0.3)
      ..lineTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.5);

    final path2 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width * 0.65, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height * 0.8)
      ..lineTo(size.width * 0.75, size.height * 0.6)
      ..lineTo(size.width, size.height * 0.6);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    paint.style = PaintingStyle.fill;
  }

  void _drawStethoscopes(Canvas canvas, Size size, Paint paint) {
    // Stethoscope 1 (top right)
    _drawStethoscope(
      canvas,
      Offset(size.width * 0.8, size.height * 0.15),
      paint,
    );

    // Stethoscope 2 (bottom left)
    _drawStethoscope(
      canvas,
      Offset(size.width * 0.2, size.height * 0.85),
      paint,
    );
  }

  void _drawStethoscope(Canvas canvas, Offset position, Paint paint) {
    final strokePaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Chest piece (circle)
    canvas.drawCircle(position, 12, paint);

    // Tubing (curved line)
    final path = Path()
      ..moveTo(position.dx, position.dy)
      ..quadraticBezierTo(
        position.dx - 20,
        position.dy - 30,
        position.dx - 10,
        position.dy - 50,
      );

    canvas.drawPath(path, strokePaint);

    // Earpieces
    canvas.drawCircle(Offset(position.dx - 15, position.dy - 55), 4, paint);
    canvas.drawCircle(Offset(position.dx - 5, position.dy - 55), 4, paint);
  }

  void _drawDNAHelix(Canvas canvas, Size size, Paint paint1, Paint paint2) {
    final strokePaint1 = Paint()
      ..color = paint1.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final strokePaint2 = Paint()
      ..color = paint2.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw DNA helix pattern in corners
    _drawHelixPattern(
      canvas,
      Offset(size.width * 0.9, size.height * 0.5),
      strokePaint1,
      strokePaint2,
      vertical: true,
    );

    _drawHelixPattern(
      canvas,
      Offset(size.width * 0.1, size.height * 0.5),
      strokePaint1,
      strokePaint2,
      vertical: true,
    );
  }

  void _drawHelixPattern(
    Canvas canvas,
    Offset start,
    Paint paint1,
    Paint paint2, {
    bool vertical = true,
  }) {
    final path1 = Path();
    final path2 = Path();

    final length = 100.0;
    final amplitude = 15.0;
    final frequency = 4;

    for (double i = 0; i <= length; i += 2) {
      final progress = i / length;
      final angle = progress * math.pi * 2 * frequency;

      if (vertical) {
        final x1 = start.dx + math.sin(angle) * amplitude;
        final x2 = start.dx - math.sin(angle) * amplitude;
        final y = start.dy - length / 2 + i;

        if (i == 0) {
          path1.moveTo(x1, y);
          path2.moveTo(x2, y);
        } else {
          path1.lineTo(x1, y);
          path2.lineTo(x2, y);
        }
      }
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  void _drawMedicalPills(
    Canvas canvas,
    Size size,
    Paint paint1,
    Paint paint2,
    Paint paint3,
  ) {
    // MANY MORE colorful medical pills - double the quantity!
    final pills = [
      {'pos': Offset(size.width * 0.15, size.height * 0.2), 'paint': paint1, 'rotation': 0.3},
      {'pos': Offset(size.width * 0.75, size.height * 0.15), 'paint': paint2, 'rotation': -0.5},
      {'pos': Offset(size.width * 0.2, size.height * 0.75), 'paint': paint3, 'rotation': 0.8},
      {'pos': Offset(size.width * 0.85, size.height * 0.7), 'paint': paint1, 'rotation': -0.2},
      {'pos': Offset(size.width * 0.5, size.height * 0.2), 'paint': paint2, 'rotation': 0.6},
      {'pos': Offset(size.width * 0.4, size.height * 0.45), 'paint': paint3, 'rotation': 0.1},
      {'pos': Offset(size.width * 0.65, size.height * 0.6), 'paint': paint1, 'rotation': -0.7},
      {'pos': Offset(size.width * 0.3, size.height * 0.35), 'paint': paint2, 'rotation': 0.4},
      {'pos': Offset(size.width * 0.8, size.height * 0.5), 'paint': paint3, 'rotation': -0.3},
      {'pos': Offset(size.width * 0.55, size.height * 0.85), 'paint': paint1, 'rotation': 0.9},
    ];

    for (final pill in pills) {
      final pos = pill['pos'] as Offset;
      final paint = pill['paint'] as Paint;
      final rotation = pill['rotation'] as double;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rotation);

      // Draw MUCH BIGGER capsule shape - 3x larger!
      final capsuleRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-45, -15, 90, 30),
        const Radius.circular(15),
      );
      canvas.drawRRect(capsuleRect, paint);

      // Draw dividing line in middle (thicker)
      final linePaint = Paint()
        ..color = paint.color.withValues(alpha: paint.color.a * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawLine(const Offset(0, -15), const Offset(0, 15), linePaint);

      canvas.restore();
    }
  }

  void _drawHearts(Canvas canvas, Size size, Paint paint) {
    // MUCH BIGGER hearts - 4x larger!
    final hearts = [
      {'pos': Offset(size.width * 0.1, size.height * 0.3), 'size': 80.0},
      {'pos': Offset(size.width * 0.9, size.height * 0.4), 'size': 70.0},
      {'pos': Offset(size.width * 0.25, size.height * 0.9), 'size': 65.0},
      {'pos': Offset(size.width * 0.8, size.height * 0.85), 'size': 85.0},
      {'pos': Offset(size.width * 0.5, size.height * 0.5), 'size': 75.0},
      {'pos': Offset(size.width * 0.35, size.height * 0.2), 'size': 60.0},
    ];

    for (final heart in hearts) {
      final pos = heart['pos'] as Offset;
      final heartSize = heart['size'] as double;
      _drawHeart(canvas, pos, heartSize, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // Draw heart shape using bezier curves
    path.moveTo(center.dx, center.dy + size * 0.3);

    // Left half of heart
    path.cubicTo(
      center.dx - size * 0.5,
      center.dy + size * 0.3,
      center.dx - size * 0.5,
      center.dy - size * 0.1,
      center.dx - size * 0.25,
      center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx - size * 0.1,
      center.dy - size * 0.5,
      center.dx,
      center.dy - size * 0.4,
      center.dx,
      center.dy - size * 0.2,
    );

    // Right half of heart
    path.cubicTo(
      center.dx,
      center.dy - size * 0.4,
      center.dx + size * 0.1,
      center.dy - size * 0.5,
      center.dx + size * 0.25,
      center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.5,
      center.dy - size * 0.1,
      center.dx + size * 0.5,
      center.dy + size * 0.3,
      center.dx,
      center.dy + size * 0.3,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMedicalShields(Canvas canvas, Size size, Paint paint) {
    // MUCH BIGGER shields - 3x larger!
    final shields = [
      Offset(size.width * 0.05, size.height * 0.6),
      Offset(size.width * 0.95, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.05),
      Offset(size.width * 0.6, size.height * 0.75),
      Offset(size.width * 0.2, size.height * 0.5),
    ];

    for (final pos in shields) {
      _drawShield(canvas, pos, 75, paint); // 3x bigger!
    }
  }

  void _drawShield(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // Shield shape
    path.moveTo(center.dx, center.dy - size * 0.4);
    path.lineTo(center.dx + size * 0.35, center.dy - size * 0.2);
    path.lineTo(center.dx + size * 0.35, center.dy + size * 0.2);
    path.quadraticBezierTo(
      center.dx + size * 0.35,
      center.dy + size * 0.5,
      center.dx,
      center.dy + size * 0.6,
    );
    path.quadraticBezierTo(
      center.dx - size * 0.35,
      center.dy + size * 0.5,
      center.dx - size * 0.35,
      center.dy + size * 0.2,
    );
    path.lineTo(center.dx - size * 0.35, center.dy - size * 0.2);
    path.close();

    canvas.drawPath(path, paint);

    // Draw cross on shield
    final crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: paint.color.a * 1.5)
      ..style = PaintingStyle.fill;

    _drawCross(
      canvas,
      Offset(center.dx, center.dy + size * 0.05),
      size * 0.3,
      crossPaint,
    );
  }

  void _drawDecorativeCircles(
    Canvas canvas,
    Size size,
    Paint paint1,
    Paint paint2,
    Paint paint3,
  ) {
    // Draw small decorative circles/dots scattered throughout
    final circles = [
      {
        'pos': Offset(size.width * 0.12, size.height * 0.45),
        'radius': 4.0,
        'paint': paint1,
      },
      {
        'pos': Offset(size.width * 0.88, size.height * 0.55),
        'radius': 5.0,
        'paint': paint2,
      },
      {
        'pos': Offset(size.width * 0.3, size.height * 0.15),
        'radius': 3.5,
        'paint': paint3,
      },
      {
        'pos': Offset(size.width * 0.65, size.height * 0.25),
        'radius': 4.5,
        'paint': paint1,
      },
      {
        'pos': Offset(size.width * 0.18, size.height * 0.82),
        'radius': 3.0,
        'paint': paint2,
      },
      {
        'pos': Offset(size.width * 0.92, size.height * 0.65),
        'radius': 4.0,
        'paint': paint3,
      },
      {
        'pos': Offset(size.width * 0.45, size.height * 0.85),
        'radius': 3.5,
        'paint': paint1,
      },
      {
        'pos': Offset(size.width * 0.7, size.height * 0.08),
        'radius': 5.0,
        'paint': paint2,
      },
    ];

    for (final circle in circles) {
      final pos = circle['pos'] as Offset;
      final radius = circle['radius'] as double;
      final paint = circle['paint'] as Paint;

      canvas.drawCircle(pos, radius, paint);

      // Add a subtle white glow effect
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: paint.color.a * 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, radius * 0.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(HospitalGraphicsPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
