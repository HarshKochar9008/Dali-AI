import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

/// Widget to display Prokerala SVG charts
class ProkeralaChartWidget extends StatelessWidget {
  final String svgContent;
  final double? width;
  final double? height;

  const ProkeralaChartWidget({
    super.key,
    required this.svgContent,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (svgContent.isEmpty) {
      return const Center(
        child: Text('No chart data available'),
      );
    }

    try {
      // Decode SVG string to bytes
      final svgBytes = utf8.encode(svgContent);
      
      return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8),
        child: SvgPicture.string(
          svgContent,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading chart: $e',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
