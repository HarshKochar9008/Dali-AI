import 'package:flutter/material.dart';
import '../models/kundali_data.dart';
import 'kundali_painter.dart';

class KundaliChart extends StatelessWidget {
  final KundaliData kundaliData;

  const KundaliChart({
    super.key,
    required this.kundaliData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ),
            painter: KundaliPainter(kundaliData: kundaliData),
          );
        },
      ),
    );
  }
}
