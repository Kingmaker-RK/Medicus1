import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AiGrisLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AiGrisLogo({Key? key, this.size = 100, this.showText = false})
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.2),
            child: Image.asset(
              'assets/images/aigris_hq.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'AI-GRIS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: size * 0.3,
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