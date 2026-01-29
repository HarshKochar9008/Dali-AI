import 'package:flutter/material.dart';
import '../models/kundali_data.dart';
import 'kundali_painter.dart';


class KundaliChart extends StatelessWidget {
  final KundaliData kundaliData;
  final double? size;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? houseColor;

  const KundaliChart({
    super.key,
    required this.kundaliData,
    this.size,
    this.backgroundColor,
    this.borderColor,
    this.houseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartSize = size ?? 
              (constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth - 32
                  : constraints.maxHeight - 32);
          
          return SizedBox(
            width: chartSize,
            height: chartSize,
            child: CustomPaint(
              painter: KundaliPainter(
                kundaliData: kundaliData,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                houseColor: houseColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
