import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/kundali_data.dart';
import 'kundali_painter.dart';

class KundaliChart extends StatelessWidget {
  final KundaliData kundaliData;
  final double? size;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? houseColor;
  final Color? houseFillColor;
  final Color? textColor;
  final Color? planetBadgeColor;
  final Color? planetTextColor;

  const KundaliChart({
    super.key,
    required this.kundaliData,
    this.size,
    this.backgroundColor,
    this.borderColor,
    this.houseColor,
    this.houseFillColor,
    this.textColor,
    this.planetBadgeColor,
    this.planetTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartSize = size ??
              (constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth - 32
                  : constraints.maxHeight - 32);
          final bg =
              backgroundColor ?? (isDark ? AppColors.cardDark : Colors.white);
          final border = borderColor ??
              (isDark ? AppColors.headerViolet : Colors.orange.shade700);
          final house = houseColor ??
              (isDark ? AppColors.accentViolet : Colors.orange.shade600);
          final houseFill = houseFillColor ??
              (isDark ? AppColors.cardDark : Colors.orange.shade50);
          final text = textColor ??
              (isDark ? AppColors.accentViolet : Colors.orange.shade900);
          final planetBadge = planetBadgeColor ??
              (isDark ? AppColors.accentViolet : Colors.yellow.shade600);
          final planetText = planetTextColor ?? colorScheme.onSurface;
          return SizedBox(
            width: chartSize,
            height: chartSize,
            child: CustomPaint(
              painter: KundaliPainter(
                kundaliData: kundaliData,
                backgroundColor: bg,
                borderColor: border,
                houseColor: house,
                houseFillColor: houseFill,
                textColor: text,
                planetBadgeColor: planetBadge,
                planetTextColor: planetText,
              ),
            ),
          );
        },
      ),
    );
  }
}
