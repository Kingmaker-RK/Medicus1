import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../constants/colors.dart';

class HandwritingInputWidget extends StatefulWidget {
  final Function(Uint8List) onHandwritingCaptured;

  const HandwritingInputWidget({
    Key? key,
    required this.onHandwritingCaptured,
  }) : super(key: key);

  @override
  State<HandwritingInputWidget> createState() => _HandwritingInputWidgetState();
}

class _HandwritingInputWidgetState extends State<HandwritingInputWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  final GlobalKey _globalKey = GlobalKey();

  void _startStroke(Offset point) {
    setState(() {
      _currentStroke = [point];
      _strokes.add(_currentStroke);
    });
  }

  void _continueStroke(Offset point) {
    setState(() {
      _currentStroke.add(point);
    });
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  Future<void> _captureAndSubmit() async {
    if (_strokes.isEmpty) {
      Navigator.pop(context);
      return;
    }

    try {
      final boundary = _globalKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      
      // Increased pixel ratio for better quality for the LLM
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        widget.onHandwritingCaptured(byteData.buffer.asUint8List());
      }
    } catch (e) {
      print('Error capturing handwriting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Write Input',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: RepaintBoundary(
                key: _globalKey,
                child: GestureDetector(
                  onPanStart: (details) {
                    _startStroke(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _continueStroke(details.localPosition);
                  },
                  child: CustomPaint(
                    painter: HandwritingPainter(
                      strokes: _strokes,
                      color: Colors.black,
                      strokeWidth: 3.0,
                    ),
                    size: Size.infinite,
                    child: Container(
                      color: Colors.white, // Background for the image
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _captureAndSubmit,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  HandwritingPainter({
    required this.strokes,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) {
        // Draw a dot if it's just a tap
        if (stroke.isNotEmpty) {
          canvas.drawPoints(ui.PointMode.points, stroke, paint);
        }
        continue;
      }

      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HandwritingPainter oldDelegate) {
    return true;
  }
}
