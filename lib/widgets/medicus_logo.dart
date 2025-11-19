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
              size: Size(size * 0.6, size * 0.6),
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
    final paint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw staff (vertical line)
    canvas.drawLine(
      Offset(center.dx, size.height * 0.1),
      Offset(center.dx, size.height * 0.9),
      paint,
    );

    // Draw wings at top
    final wingPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    // Left wing
    final leftWingPath = Path()
      ..moveTo(center.dx, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.1,
        size.width * 0.1,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.25,
        center.dx,
        size.height * 0.25,
      )
      ..close();
    canvas.drawPath(leftWingPath, wingPaint);

    // Right wing
    final rightWingPath = Path()
      ..moveTo(center.dx, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.1,
        size.width * 0.9,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.25,
        center.dx,
        size.height * 0.25,
      )
      ..close();
    canvas.drawPath(rightWingPath, wingPaint);

    // Draw intertwined serpents
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.06;

    // Left serpent
    final leftSerpentPath = Path()
      ..moveTo(center.dx - size.width * 0.15, size.height * 0.3)
      ..quadraticBezierTo(
        center.dx + size.width * 0.15,
        size.height * 0.4,
        center.dx - size.width * 0.15,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        center.dx + size.width * 0.15,
        size.height * 0.6,
        center.dx - size.width * 0.15,
        size.height * 0.7,
      );
    canvas.drawPath(leftSerpentPath, paint);

    // Right serpent
    final rightSerpentPath = Path()
      ..moveTo(center.dx + size.width * 0.15, size.height * 0.3)
      ..quadraticBezierTo(
        center.dx - size.width * 0.15,
        size.height * 0.4,
        center.dx + size.width * 0.15,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        center.dx - size.width * 0.15,
        size.height * 0.6,
        center.dx + size.width * 0.15,
        size.height * 0.7,
      );
    canvas.drawPath(rightSerpentPath, paint);

    // Draw serpent heads (small circles)
    final headPaint = Paint()
      ..color = AppColors.logoWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, size.height * 0.3),
      size.width * 0.05,
      headPaint,
    );

    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, size.height * 0.3),
      size.width * 0.05,
      headPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
