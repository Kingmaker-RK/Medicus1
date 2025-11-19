import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom painted hospital-themed background with medical graphics
class HospitalBackground extends StatelessWidget {
  final Widget child;
  final double opacity;

  const HospitalBackground({
    Key? key,
    required this.child,
    this.opacity = 0.15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE3F2FD), // Light blue
                const Color(0xFFF1F8E9), // Light green
                Colors.white,
              ],
            ),
          ),
        ),

        // Medical graphics pattern
        CustomPaint(
          painter: HospitalGraphicsPainter(opacity: opacity),
          size: Size.infinite,
        ),

        // Semi-transparent overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
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
    // Medical blue and red colors
    final bluePaint = Paint()
      ..color = const Color(0xFF1976D2).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final redPaint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final greenPaint = Paint()
      ..color = const Color(0xFF43A047).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF1976D2).withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw medical crosses scattered across the background
    _drawMedicalCrosses(canvas, size, redPaint);

    // Draw hospital building silhouettes
    _drawHospitalBuildings(canvas, size, bluePaint, outlinePaint);

    // Draw heartbeat lines
    _drawHeartbeatLines(canvas, size, greenPaint);

    // Draw stethoscope graphics
    _drawStethoscopes(canvas, size, bluePaint);

    // Draw DNA helix pattern
    _drawDNAHelix(canvas, size, bluePaint, greenPaint);
  }

  void _drawMedicalCrosses(Canvas canvas, Size size, Paint paint) {
    final positions = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.1),
    ];

    for (final pos in positions) {
      _drawCross(canvas, pos, 25, paint);
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

  void _drawHospitalBuildings(Canvas canvas, Size size, Paint fillPaint, Paint outlinePaint) {
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
    paint.strokeWidth = 3;

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
    canvas.drawCircle(
      Offset(position.dx - 15, position.dy - 55),
      4,
      paint,
    );
    canvas.drawCircle(
      Offset(position.dx - 5, position.dy - 55),
      4,
      paint,
    );
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

  @override
  bool shouldRepaint(HospitalGraphicsPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
