import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MedicusLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const MedicusLogo({Key? key, this.size = 100, this.showText = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow effect
            Container(
              width: size * 1.15,
              height: size * 1.15,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.logoBlue.withOpacity(0.3),
                    AppColors.logoBlue.withOpacity(0.0),
                  ],
                  stops: const [0.4, 1.0],
                ),
                shape: BoxShape.circle,
              ),
            ),
            // Main logo container with gradient and shadow
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.logoBlue,
                    AppColors.logoBlue.withBlue(200),
                  ],
                ),
                borderRadius: BorderRadius.circular(size * 0.25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.logoBlue.withOpacity(0.4),
                    blurRadius: size * 0.15,
                    spreadRadius: size * 0.02,
                    offset: Offset(0, size * 0.08),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: size * 0.05,
                    spreadRadius: -size * 0.02,
                    offset: Offset(-size * 0.02, -size * 0.02),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(size * 0.65, size * 0.65),
                  painter: CaduceusPainter(),
                ),
              ),
            ),
            // Inner highlight ring
            Container(
              width: size * 0.92,
              height: size * 0.92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.23),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: size * 0.01,
                ),
              ),
            ),
          ],
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          // Enhanced text with gradient effect
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.logoBlue, AppColors.logoBlue.withBlue(180)],
            ).createShader(bounds),
            child: Text(
              'MEDICUS',
              style: TextStyle(
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: AppColors.logoBlue.withOpacity(0.3),
                    blurRadius: size * 0.08,
                    offset: Offset(0, size * 0.02),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: size * 0.05),
          // Tagline
          Text(
            'Healthcare Without Barriers',
            style: TextStyle(
              fontSize: size * 0.10,
              fontWeight: FontWeight.w500,
              color: AppColors.logoBlue.withOpacity(0.7),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class CaduceusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw staff (vertical line) with slight gradient effect using multiple lines
    final staffPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, size.height * 0.08),
      Offset(center.dx, size.height * 0.92),
      staffPaint,
    );

    // Draw decorative orb at top of staff
    final orbPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, size.height * 0.08),
      size.width * 0.06,
      orbPaint,
    );

    // Draw wings at top with more detailed, elegant design
    final wingPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    // Left wing - more refined with multiple curves
    final leftWingPath = Path()
      ..moveTo(center.dx, size.height * 0.12)
      // Outer curve
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.08,
        size.width * 0.05,
        size.height * 0.18,
      )
      // Inner curve back
      ..quadraticBezierTo(
        size.width * 0.12,
        size.height * 0.20,
        center.dx * 0.85,
        size.height * 0.22,
      )
      // Second feather layer
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.15,
        center.dx,
        size.height * 0.18,
      )
      ..close();
    canvas.drawPath(leftWingPath, wingPaint);

    // Right wing - mirror of left wing
    final rightWingPath = Path()
      ..moveTo(center.dx, size.height * 0.12)
      // Outer curve
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.08,
        size.width * 0.95,
        size.height * 0.18,
      )
      // Inner curve back
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.20,
        center.dx * 1.15,
        size.height * 0.22,
      )
      // Second feather layer
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.15,
        center.dx,
        size.height * 0.18,
      )
      ..close();
    canvas.drawPath(rightWingPath, wingPaint);

    // Add wing details/feathers
    final featherPaint = Paint()
      ..color = AppColors.logoWhite.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015;

    // Left wing feathers
    for (var i = 0; i < 3; i++) {
      final featherPath = Path()
        ..moveTo(center.dx - size.width * 0.05, size.height * 0.14 + i * 0.02)
        ..lineTo(size.width * 0.15 - i * 0.05, size.height * 0.12 + i * 0.03);
      canvas.drawPath(featherPath, featherPaint);
    }

    // Right wing feathers
    for (var i = 0; i < 3; i++) {
      final featherPath = Path()
        ..moveTo(center.dx + size.width * 0.05, size.height * 0.14 + i * 0.02)
        ..lineTo(size.width * 0.85 + i * 0.05, size.height * 0.12 + i * 0.03);
      canvas.drawPath(featherPath, featherPaint);
    }

    // Draw intertwined serpents with more detail
    final serpentPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;

    // Left serpent - smoother curves with more coils
    final leftSerpentPath = Path()
      ..moveTo(center.dx - size.width * 0.18, size.height * 0.28)
      ..cubicTo(
        center.dx + size.width * 0.12,
        size.height * 0.35,
        center.dx + size.width * 0.15,
        size.height * 0.40,
        center.dx - size.width * 0.18,
        size.height * 0.48,
      )
      ..cubicTo(
        center.dx + size.width * 0.12,
        size.height * 0.55,
        center.dx + size.width * 0.15,
        size.height * 0.60,
        center.dx - size.width * 0.18,
        size.height * 0.68,
      )
      ..cubicTo(
        center.dx + size.width * 0.08,
        size.height * 0.73,
        center.dx + size.width * 0.10,
        size.height * 0.76,
        center.dx - size.width * 0.15,
        size.height * 0.82,
      );
    canvas.drawPath(leftSerpentPath, serpentPaint);

    // Right serpent - mirror curves
    final rightSerpentPath = Path()
      ..moveTo(center.dx + size.width * 0.18, size.height * 0.28)
      ..cubicTo(
        center.dx - size.width * 0.12,
        size.height * 0.35,
        center.dx - size.width * 0.15,
        size.height * 0.40,
        center.dx + size.width * 0.18,
        size.height * 0.48,
      )
      ..cubicTo(
        center.dx - size.width * 0.12,
        size.height * 0.55,
        center.dx - size.width * 0.15,
        size.height * 0.60,
        center.dx + size.width * 0.18,
        size.height * 0.68,
      )
      ..cubicTo(
        center.dx - size.width * 0.08,
        size.height * 0.73,
        center.dx - size.width * 0.10,
        size.height * 0.76,
        center.dx + size.width * 0.15,
        size.height * 0.82,
      );
    canvas.drawPath(rightSerpentPath, serpentPaint);

    // Draw serpent heads with more detail
    final headPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    // Left serpent head
    final leftHeadX = center.dx - size.width * 0.18;
    final leftHeadY = size.height * 0.28;

    // Head circle
    canvas.drawCircle(
      Offset(leftHeadX, leftHeadY),
      size.width * 0.055,
      headPaint,
    );

    // Eye
    final eyePaint = Paint()
      ..color = AppColors.logoBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(leftHeadX + size.width * 0.02, leftHeadY - size.width * 0.015),
      size.width * 0.015,
      eyePaint,
    );

    // Tongue (small triangular shape)
    final tonguePath = Path()
      ..moveTo(leftHeadX, leftHeadY + size.width * 0.04)
      ..lineTo(leftHeadX - size.width * 0.02, leftHeadY + size.width * 0.08)
      ..lineTo(leftHeadX + size.width * 0.02, leftHeadY + size.width * 0.08)
      ..close();

    final tonguePaint = Paint()
      ..color = AppColors.logoWhite.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawPath(tonguePath, tonguePaint);

    // Right serpent head
    final rightHeadX = center.dx + size.width * 0.18;
    final rightHeadY = size.height * 0.28;

    // Head circle
    canvas.drawCircle(
      Offset(rightHeadX, rightHeadY),
      size.width * 0.055,
      headPaint,
    );

    // Eye
    canvas.drawCircle(
      Offset(rightHeadX - size.width * 0.02, rightHeadY - size.width * 0.015),
      size.width * 0.015,
      eyePaint,
    );

    // Tongue
    final rightTonguePath = Path()
      ..moveTo(rightHeadX, rightHeadY + size.width * 0.04)
      ..lineTo(rightHeadX - size.width * 0.02, rightHeadY + size.width * 0.08)
      ..lineTo(rightHeadX + size.width * 0.02, rightHeadY + size.width * 0.08)
      ..close();
    canvas.drawPath(rightTonguePath, tonguePaint);

    // Add scale details on serpent bodies
    final scalePaint = Paint()
      ..color = AppColors.logoWhite.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012;

    // Scales on left serpent
    for (var i = 0; i < 6; i++) {
      final scaleY = size.height * (0.35 + i * 0.08);
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(center.dx - size.width * 0.10, scaleY),
          radius: size.width * 0.04,
        ),
        -0.5,
        1.0,
        false,
        scalePaint,
      );
    }

    // Scales on right serpent
    for (var i = 0; i < 6; i++) {
      final scaleY = size.height * (0.35 + i * 0.08);
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(center.dx + size.width * 0.10, scaleY),
          radius: size.width * 0.04,
        ),
        2.64,
        1.0,
        false,
        scalePaint,
      );
    }

    // Add decorative base at bottom of staff
    final basePaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    final basePath = Path()
      ..moveTo(center.dx - size.width * 0.08, size.height * 0.92)
      ..lineTo(center.dx - size.width * 0.12, size.height * 0.95)
      ..lineTo(center.dx + size.width * 0.12, size.height * 0.95)
      ..lineTo(center.dx + size.width * 0.08, size.height * 0.92)
      ..close();
    canvas.drawPath(basePath, basePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
