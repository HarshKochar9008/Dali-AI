import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/kundali_data.dart';

/// CustomPainter for rendering the kundali chart
/// 
/// Implements a clean, readable, and scalable layout with:
/// - 12 houses arranged in traditional North Indian style
/// - Zodiac signs displayed per house
/// - Planet abbreviations inside houses
class KundaliPainter extends CustomPainter {
  final KundaliData kundaliData;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? houseColor;

  KundaliPainter({
    required this.kundaliData,
    this.backgroundColor,
    this.borderColor,
    this.houseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 8.0;
    final chartSize = math.min(size.width, size.height) - (padding * 2);
    final startX = (size.width - chartSize) / 2;
    final startY = (size.height - chartSize) / 2;

    // Calculate house dimensions
    final houseWidth = chartSize / 4;
    final houseHeight = chartSize / 4;

    // Define colors
    final bgColor = backgroundColor ?? Colors.white;
    final borderPaint = Paint()
      ..color = borderColor ?? Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final houseBorderPaint = Paint()
      ..color = houseColor ?? Colors.orange.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final houseFillPaint = Paint()
      ..color = Colors.orange.shade50
      ..style = PaintingStyle.fill;

    final dividerPaint = Paint()
      ..color = Colors.orange.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw background
    final backgroundRect = Rect.fromLTWH(startX, startY, chartSize, chartSize);
    canvas.drawRect(backgroundRect, Paint()..color = bgColor);
    canvas.drawRect(backgroundRect, borderPaint);

    // Traditional North Indian Kundali Layout:
    // Houses arranged in a 4x4 grid with center 2x2 empty
    // House 1 is at top center (position [1,0])
    // Houses arranged clockwise: 2,3,4,5,6,7,8,9,10,11,12
    
    // House positions: [column, row] in 4x4 grid
    // House numbers in traditional order
    final housePositions = [
      [1, 0], // House 1 (Lagna) - Top center
      [2, 0], // House 2
      [3, 0], // House 3
      [3, 1], // House 4
      [3, 2], // House 5
      [3, 3], // House 6
      [2, 3], // House 7
      [1, 3], // House 8
      [0, 3], // House 9
      [0, 2], // House 10
      [0, 1], // House 11
      [0, 0], // House 12
    ];

    final houseNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    // Draw all 12 houses
    for (int i = 0; i < 12; i++) {
      final houseNum = houseNumbers[i];
      final pos = housePositions[i];
      final x = startX + pos[0] * houseWidth;
      final y = startY + pos[1] * houseHeight;

      final houseRect = Rect.fromLTWH(x, y, houseWidth, houseHeight);

      // Draw house background
      canvas.drawRect(houseRect, houseFillPaint);
      canvas.drawRect(houseRect, houseBorderPaint);

      // Get house data
      final houseData = kundaliData.houses.firstWhere(
        (h) => h.houseNumber == houseNum,
        orElse: () => kundaliData.houses.isNotEmpty
            ? kundaliData.houses[houseNum - 1]
            : HouseData(houseNumber: houseNum, zodiacSign: ''),
      );

      final houseCenterX = x + houseWidth / 2;
      final houseCenterY = y + houseHeight / 2;

      // Draw house number at top
      final houseNumberText = TextPainter(
        text: TextSpan(
          text: '$houseNum',
          style: TextStyle(
            color: Colors.orange.shade900,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      houseNumberText.layout();
      houseNumberText.paint(
        canvas,
        Offset(
          houseCenterX - houseNumberText.width / 2,
          y + 4,
        ),
      );

      // Draw zodiac sign below house number
      if (houseData.zodiacSign.isNotEmpty) {
        final signText = TextPainter(
          text: TextSpan(
            text: houseData.zodiacSign,
            style: TextStyle(
              color: Colors.orange.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        signText.layout();
        signText.paint(
          canvas,
          Offset(
            houseCenterX - signText.width / 2,
            y + 22,
          ),
        );
      }

      // Get planets in this house
      final planetsInHouse = kundaliData.planets
          .where((planet) => planet.house == houseNum)
          .toList();

      // Draw planets
      if (planetsInHouse.isNotEmpty) {
        final planetStartY = y + 42;
        final planetSpacing = 16.0;
        final maxPlanetsPerRow = 2;
        
        for (int j = 0; j < planetsInHouse.length; j++) {
          final row = j ~/ maxPlanetsPerRow;
          final col = j % maxPlanetsPerRow;
          
          final planetX = houseCenterX + 
              (col == 0 ? -houseWidth / 4 : houseWidth / 4) - 12;
          final planetY = planetStartY + (row * planetSpacing);

          // Draw planet badge
          final planetPaint = Paint()
            ..color = Colors.yellow.shade600
            ..style = PaintingStyle.fill;

          final planetBorderPaint = Paint()
            ..color = Colors.orange.shade900
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;

          final planetRadius = 12.0;
          canvas.drawCircle(
            Offset(planetX, planetY),
            planetRadius,
            planetPaint,
          );
          canvas.drawCircle(
            Offset(planetX, planetY),
            planetRadius,
            planetBorderPaint,
          );

          // Draw planet abbreviation
          final planetText = TextPainter(
            text: TextSpan(
              text: planetsInHouse[j].name,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          );
          planetText.layout();
          planetText.paint(
            canvas,
            Offset(
              planetX - planetText.width / 2,
              planetY - planetText.height / 2,
            ),
          );
        }
      }
    }

    // Draw vertical dividers
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(startX + i * houseWidth, startY),
        Offset(startX + i * houseWidth, startY + chartSize),
        dividerPaint,
      );
    }

    // Draw horizontal dividers
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(startX, startY + i * houseHeight),
        Offset(startX + chartSize, startY + i * houseHeight),
        dividerPaint,
      );
    }

    // Draw center square (empty space in traditional layout)
    final centerRect = Rect.fromLTWH(
      startX + houseWidth,
      startY + houseHeight,
      houseWidth * 2,
      houseHeight * 2,
    );

    final centerPaint = Paint()
      ..color = Colors.yellow.shade50
      ..style = PaintingStyle.fill;

    final centerBorderPaint = Paint()
      ..color = Colors.orange.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(centerRect, centerPaint);
    canvas.drawRect(centerRect, centerBorderPaint);

    // Optional: Add title in center
    final centerText = TextPainter(
      text: const TextSpan(
        text: 'Kundali',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    centerText.layout();
    centerText.paint(
      canvas,
      Offset(
        centerRect.center.dx - centerText.width / 2,
        centerRect.center.dy - centerText.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! KundaliPainter) return true;
    return oldDelegate.kundaliData != kundaliData ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.houseColor != houseColor;
  }
}
