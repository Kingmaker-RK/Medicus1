import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BenzeneIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? borderColor;

  const BenzeneIcon({
    Key? key,
    this.size = 60,
    this.color,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: BenzenePainter(
        color: color ?? AppColors.primary,
        borderColor: borderColor ?? Colors.white,
      ),
    );
  }
}

class BenzenePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  BenzenePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Draw hexagon (benzene ring shape)
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * 3.14159 / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill hexagon
    canvas.drawPath(path, paint);

    // Draw border
    canvas.drawPath(path, borderPaint);

    // Draw medical cross in center
    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final crossSize = size.width * 0.35;
    final crossThickness = size.width * 0.1;

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: crossThickness,
          height: crossSize,
        ),
        Radius.circular(crossThickness / 2),
      ),
      crossPaint,
    );

    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: crossSize,
          height: crossThickness,
        ),
        Radius.circular(crossThickness / 2),
      ),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  double cos(double radians) =>
      (radians == 0) ? 1 : ((radians.abs() - 1.5708).abs() < 0.01 ? 0 :
      _cosApprox(radians));

  double sin(double radians) => cos(radians - 1.5708);

  double _cosApprox(double x) {
    x = x % (2 * 3.14159);
    if (x < 0) x = -x;
    if (x > 3.14159) x = 2 * 3.14159 - x;

    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
  }
}
