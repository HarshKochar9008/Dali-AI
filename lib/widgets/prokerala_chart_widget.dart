import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget to display Prokerala SVG charts
class ProkeralaChartWidget extends StatelessWidget {
  final String svgContent;
  final double? width;
  final double? height;
  /// Optional background color for the chart area (e.g. paper/cream).
  final Color? backgroundColor;

  const ProkeralaChartWidget({
    super.key,
    required this.svgContent,
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (svgContent.isEmpty) {
      return const Center(
        child: Text('No chart data available'),
      );
    }

    try {
      // Optionally replace dark SVG background with widget background for consistency
      String content = svgContent;
      if (backgroundColor != null) {
        final hex = backgroundColor!.value.toRadixString(16).padLeft(8, '0');
        final svgHex = '#${hex.substring(2)}';
        const darkBackgrounds = [
          '#121212', '#1e1e1e', '#1a1a1a', '#2d2d2d', '#1c1c1c',
          'rgb(18,18,18)', 'rgb(30,30,30)',
        ];
        for (final dark in darkBackgrounds) {
          if (content.contains('fill="$dark"') || content.contains("fill='$dark'")) {
            content = content
                .replaceAll('fill="$dark"', 'fill="$svgHex"')
                .replaceAll("fill='$dark'", "fill='$svgHex'");
          }
        }
      }

      return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8),
        color: backgroundColor,
        child: SvgPicture.string(
          content,
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
