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
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.logoBlue,
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: Center(
            child: CustomPaint(
              size: Size(size * 0.9, size * 0.9),
              painter: CaduceusPainter(),
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.1),
          Text(
            'MEDICUS',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: AppColors.logoBlue,
              letterSpacing: 2,
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

    // Staff paint
    final staffPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    // Draw main staff (vertical line)
    canvas.drawLine(
      Offset(center.dx, size.height * 0.18),
      Offset(center.dx, size.height * 0.92),
      staffPaint,
    );

    // Draw orb at top of staff
    final orbPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, size.height * 0.15),
      size.width * 0.08,
      orbPaint,
    );

    // Enhanced wings with more detail
    final wingPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    // Left wing with feather detail
    final leftWingPath = Path()
      ..moveTo(center.dx, size.height * 0.18)
      ..cubicTo(
        size.width * 0.25, size.height * 0.12,
        size.width * 0.15, size.height * 0.15,
        size.width * 0.08, size.height * 0.24,
      )
      ..cubicTo(
        size.width * 0.12, size.height * 0.28,
        size.width * 0.20, size.height * 0.28,
        center.dx, size.height * 0.26,
      )
      ..close();
    canvas.drawPath(leftWingPath, wingPaint);

    // Inner left wing feather
    final leftWingInnerPath = Path()
      ..moveTo(center.dx, size.height * 0.20)
      ..cubicTo(
        size.width * 0.35, size.height * 0.16,
        size.width * 0.28, size.height * 0.19,
        size.width * 0.22, size.height * 0.26,
      )
      ..cubicTo(
        size.width * 0.26, size.height * 0.27,
        size.width * 0.32, size.height * 0.26,
        center.dx, size.height * 0.24,
      )
      ..close();
    canvas.drawPath(leftWingInnerPath, wingPaint);

    // Right wing with feather detail
    final rightWingPath = Path()
      ..moveTo(center.dx, size.height * 0.18)
      ..cubicTo(
        size.width * 0.75, size.height * 0.12,
        size.width * 0.85, size.height * 0.15,
        size.width * 0.92, size.height * 0.24,
      )
      ..cubicTo(
        size.width * 0.88, size.height * 0.28,
        size.width * 0.80, size.height * 0.28,
        center.dx, size.height * 0.26,
      )
      ..close();
    canvas.drawPath(rightWingPath, wingPaint);

    // Inner right wing feather
    final rightWingInnerPath = Path()
      ..moveTo(center.dx, size.height * 0.20)
      ..cubicTo(
        size.width * 0.65, size.height * 0.16,
        size.width * 0.72, size.height * 0.19,
        size.width * 0.78, size.height * 0.26,
      )
      ..cubicTo(
        size.width * 0.74, size.height * 0.27,
        size.width * 0.68, size.height * 0.26,
        center.dx, size.height * 0.24,
      )
      ..close();
    canvas.drawPath(rightWingInnerPath, wingPaint);

    // Serpent paint with gradient effect
    final serpentPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round;

    // Left serpent with improved curves
    final leftSerpentPath = Path()
      ..moveTo(center.dx - size.width * 0.18, size.height * 0.32)
      ..cubicTo(
        center.dx - size.width * 0.05, size.height * 0.38,
        center.dx + size.width * 0.10, size.height * 0.42,
        center.dx - size.width * 0.18, size.height * 0.50,
      )
      ..cubicTo(
        center.dx - size.width * 0.05, size.height * 0.58,
        center.dx + size.width * 0.10, size.height * 0.62,
        center.dx - size.width * 0.18, size.height * 0.70,
      )
      ..cubicTo(
        center.dx - size.width * 0.10, size.height * 0.75,
        center.dx - size.width * 0.05, size.height * 0.82,
        center.dx - size.width * 0.12, size.height * 0.88,
      );
    canvas.drawPath(leftSerpentPath, serpentPaint);

    // Right serpent with improved curves (mirror of left)
    final rightSerpentPath = Path()
      ..moveTo(center.dx + size.width * 0.18, size.height * 0.32)
      ..cubicTo(
        center.dx + size.width * 0.05, size.height * 0.38,
        center.dx - size.width * 0.10, size.height * 0.42,
        center.dx + size.width * 0.18, size.height * 0.50,
      )
      ..cubicTo(
        center.dx + size.width * 0.05, size.height * 0.58,
        center.dx - size.width * 0.10, size.height * 0.62,
        center.dx + size.width * 0.18, size.height * 0.70,
      )
      ..cubicTo(
        center.dx + size.width * 0.10, size.height * 0.75,
        center.dx + size.width * 0.05, size.height * 0.82,
        center.dx + size.width * 0.12, size.height * 0.88,
      );
    canvas.drawPath(rightSerpentPath, serpentPaint);

    // Draw serpent heads with more detail
    final headPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    // Left serpent head
    final leftHeadCenter = Offset(center.dx - size.width * 0.18, size.height * 0.32);
    canvas.drawCircle(leftHeadCenter, size.width * 0.07, headPaint);

    // Left serpent eye
    final eyePaint = Paint()
      ..color = AppColors.logoBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(leftHeadCenter.dx + size.width * 0.02, leftHeadCenter.dy),
      size.width * 0.02,
      eyePaint,
    );

    // Right serpent head
    final rightHeadCenter = Offset(center.dx + size.width * 0.18, size.height * 0.32);
    canvas.drawCircle(rightHeadCenter, size.width * 0.07, headPaint);

    // Right serpent eye
    canvas.drawCircle(
      Offset(rightHeadCenter.dx - size.width * 0.02, rightHeadCenter.dy),
      size.width * 0.02,
      eyePaint,
    );

    // Draw serpent tongues (small forked lines)
    final tonguePaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.018
      ..strokeCap = StrokeCap.round;

    // Left tongue
    canvas.drawLine(
      Offset(leftHeadCenter.dx - size.width * 0.06, leftHeadCenter.dy + size.width * 0.03),
      Offset(leftHeadCenter.dx - size.width * 0.09, leftHeadCenter.dy + size.width * 0.05),
      tonguePaint,
    );
    canvas.drawLine(
      Offset(leftHeadCenter.dx - size.width * 0.06, leftHeadCenter.dy + size.width * 0.03),
      Offset(leftHeadCenter.dx - size.width * 0.09, leftHeadCenter.dy + size.width * 0.01),
      tonguePaint,
    );

    // Right tongue
    canvas.drawLine(
      Offset(rightHeadCenter.dx + size.width * 0.06, rightHeadCenter.dy + size.width * 0.03),
      Offset(rightHeadCenter.dx + size.width * 0.09, rightHeadCenter.dy + size.width * 0.05),
      tonguePaint,
    );
    canvas.drawLine(
      Offset(rightHeadCenter.dx + size.width * 0.06, rightHeadCenter.dy + size.width * 0.03),
      Offset(rightHeadCenter.dx + size.width * 0.09, rightHeadCenter.dy + size.width * 0.01),
      tonguePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
