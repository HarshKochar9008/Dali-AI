import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/kundali_data.dart';

class KundaliPainter extends CustomPainter {
  final KundaliData kundaliData;

  KundaliPainter({required this.kundaliData});

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 20.0;
    final availableWidth = size.width - (padding * 2);
    final availableHeight = size.height - (padding * 2);
    final chartSize = math.min(availableWidth, availableHeight);
    
    final startX = padding + (availableWidth - chartSize) / 2;
    final startY = padding + (availableHeight - chartSize) / 2;
    
    final houseWidth = chartSize / 4;
    final houseHeight = chartSize / 4;
    
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final houseBorderPaint = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final houseFillPaint = Paint()
      ..color = Colors.orange.shade50
      ..style = PaintingStyle.fill;

    final dividerPaint = Paint()
      ..color = Colors.orange.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(
      Rect.fromLTWH(startX, startY, chartSize, chartSize),
      backgroundPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(startX, startY, chartSize, chartSize),
      borderPaint,
    );

    final houseLayout = [
      [1, 0], [2, 0], [3, 0], [0, 0],
      [0, 1], [3, 1],
      [0, 2], [3, 2],
      [3, 3], [2, 3], [1, 3], [0, 3]
    ];
    
    final houseNumbers = [2, 3, 4, 5, 1, 6, 12, 7, 11, 10, 9, 8];

    for (int i = 0; i < 12; i++) {
      final houseNum = houseNumbers[i];
      final pos = houseLayout[i];
      final x = startX + pos[0] * houseWidth;
      final y = startY + pos[1] * houseHeight;
      
      final houseRect = Rect.fromLTWH(x, y, houseWidth, houseHeight);
      
      canvas.drawRect(houseRect, houseFillPaint);
      canvas.drawRect(houseRect, houseBorderPaint);

      final houseData = kundaliData.houses.firstWhere(
        (h) => h.houseNumber == houseNum,
        orElse: () => kundaliData.houses[houseNum - 1],
      );

      final houseCenterX = x + houseWidth / 2;
      final houseCenterY = y + houseHeight / 2;

      final houseNumberText = TextPainter(
        text: TextSpan(
          text: '$houseNum',
          style: TextStyle(
            color: Colors.orange.shade900,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      houseNumberText.layout();
      houseNumberText.paint(
        canvas,
        Offset(houseCenterX - houseNumberText.width / 2, houseCenterY - houseHeight / 2 + 5),
      );

      final signText = TextPainter(
        text: TextSpan(
          text: houseData.zodiacSign,
          style: TextStyle(
            color: Colors.orange.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      signText.layout();
      signText.paint(
        canvas,
        Offset(houseCenterX - signText.width / 2, houseCenterY - signText.height / 2 - 10),
      );

      final planetsInHouse = kundaliData.planets
          .where((planet) => planet.house == houseNum)
          .toList();

      if (planetsInHouse.isNotEmpty) {
        final planetStartY = houseCenterY + 15;
        final planetSpacing = 18.0;
        for (int j = 0; j < planetsInHouse.length; j++) {
          final planetY = planetStartY + (j * planetSpacing);
          
          final planetPaint = Paint()
            ..color = Colors.yellow.shade700
            ..style = PaintingStyle.fill;

          final planetCircleRadius = 14.0;
          canvas.drawCircle(
            Offset(houseCenterX, planetY),
            planetCircleRadius,
            planetPaint,
          );

          final planetBorderPaint = Paint()
            ..color = Colors.orange.shade900
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(
            Offset(houseCenterX, planetY),
            planetCircleRadius,
            planetBorderPaint,
          );

          final planetText = TextPainter(
            text: TextSpan(
              text: planetsInHouse[j].name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          planetText.layout();
          planetText.paint(
            canvas,
            Offset(houseCenterX - planetText.width / 2, planetY - planetText.height / 2),
          );
        }
      }
    }

    canvas.drawLine(
      Offset(startX + houseWidth, startY),
      Offset(startX + houseWidth, startY + chartSize),
      dividerPaint,
    );
    canvas.drawLine(
      Offset(startX + houseWidth * 2, startY),
      Offset(startX + houseWidth * 2, startY + chartSize),
      dividerPaint,
    );
    canvas.drawLine(
      Offset(startX + houseWidth * 3, startY),
      Offset(startX + houseWidth * 3, startY + chartSize),
      dividerPaint,
    );
    canvas.drawLine(
      Offset(startX, startY + houseHeight),
      Offset(startX + chartSize, startY + houseHeight),
      dividerPaint,
    );
    canvas.drawLine(
      Offset(startX, startY + houseHeight * 2),
      Offset(startX + chartSize, startY + houseHeight * 2),
      dividerPaint,
    );
    canvas.drawLine(
      Offset(startX, startY + houseHeight * 3),
      Offset(startX + chartSize, startY + houseHeight * 3),
      dividerPaint,
    );

    final centerRect = Rect.fromLTWH(
      startX + houseWidth,
      startY + houseHeight,
      houseWidth * 2,
      houseHeight * 2,
    );

    final centerPaint = Paint()
      ..color = Colors.yellow.shade100
      ..style = PaintingStyle.fill;

    final centerBorderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(centerRect, centerPaint);
    canvas.drawRect(centerRect, centerBorderPaint);

    final centerText = TextPainter(
      text: const TextSpan(
        text: 'Kundali',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 18,
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
