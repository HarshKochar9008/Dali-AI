import 'package:flutter/material.dart';
import '../widgets/kundali_chart.dart';
import '../models/kundali_data.dart';
import '../models/prokerala_kundli_summary.dart';
import '../services/storage_service.dart';

class ChartDisplayScreen extends StatefulWidget {
  final KundaliData kundaliData;
  final ProkeralaKundliSummary? prokeralaSummary;
  final DateTime? birthDateTime;
  final String? location;

  const ChartDisplayScreen({
    super.key,
    required this.kundaliData,
    this.prokeralaSummary,
    this.birthDateTime,
    this.location,
  });

  @override
  State<ChartDisplayScreen> createState() => _ChartDisplayScreenState();
}

class _ChartDisplayScreenState extends State<ChartDisplayScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final history = await StorageService.getHistory();
    setState(() {
      _isSaved = history.any((item) => 
        item.kundaliData.planets.length == widget.kundaliData.planets.length);
    });
  }

  Future<void> _saveChart() async {
    await StorageService.saveKundali(
      widget.kundaliData,
      widget.birthDateTime ?? DateTime.now(),
      widget.location ?? 'Unknown',
    );
    setState(() {
      _isSaved = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chart saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundali Chart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (!_isSaved)
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: _saveChart,
              tooltip: 'Save Chart',
            )
          else
            IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chart already saved'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              tooltip: 'Saved',
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                ),
              );
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
              if (widget.birthDateTime != null || widget.location != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.birthDateTime != null)
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Birth Date',
                          '${widget.birthDateTime!.day}/${widget.birthDateTime!.month}/${widget.birthDateTime!.year}',
                        ),
                      if (widget.birthDateTime != null)
                        const SizedBox(height: 8),
                      if (widget.birthDateTime != null)
                        _buildInfoRow(
                          Icons.access_time,
                          'Birth Time',
                          '${widget.birthDateTime!.hour.toString().padLeft(2, '0')}:${widget.birthDateTime!.minute.toString().padLeft(2, '0')}',
                        ),
                      if (widget.location != null) ...[
                        if (widget.birthDateTime != null) const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.location_on,
                          'Location',
                          widget.location!,
                        ),
                      ],
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Kundali Chart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 500,
                        maxHeight: 700,
                      ),
                      child: KundaliChart(kundaliData: widget.kundaliData),
                    ),
                  ],
                ),
              ),
              if (widget.prokeralaSummary != null) ...[
                _buildProkeralaSummary(widget.prokeralaSummary!),
                const SizedBox(height: 20),
              ],
              _buildPlanetDetails(),
              const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProkeralaSummary(ProkeralaKundliSummary summary) {
    final nak = summary.nakshatraDetails?.nakshatra;
    final chandra = summary.nakshatraDetails?.chandraRasi;
    final soorya = summary.nakshatraDetails?.sooryaRasi;
    final zodiac = summary.nakshatraDetails?.zodiac;
    final mangal = summary.mangalDosha;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kundli Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (nak?.name != null)
            _buildInfoRow(
              Icons.star_outline,
              'Nakshatra',
              '${nak!.name}${nak.pada != null ? ' (Pada ${nak.pada})' : ''}',
            ),
          if (chandra?.name != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.circle_outlined, 'Chandra Rasi', chandra!.name!),
          ],
          if (soorya?.name != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.wb_sunny_outlined, 'Soorya Rasi', soorya!.name!),
          ],
          if (zodiac?.name != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.category_outlined, 'Zodiac', zodiac!.name!),
          ],
          if (mangal != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  mangal.hasDosha ? Icons.warning_amber_outlined : Icons.check_circle_outline,
                  size: 18,
                  color: mangal.hasDosha ? Colors.red.shade700 : Colors.green.shade700,
                ),
                const SizedBox(width: 10),
                Text(
                  mangal.hasDosha ? 'Mangal Dosha: Yes' : 'Mangal Dosha: No',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (mangal.description != null && mangal.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                mangal.description!,
                style: TextStyle(color: Colors.grey.shade700, height: 1.3),
              ),
            ],
          ],
          if (summary.yogaDetails.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Yoga Details',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...summary.yogaDetails.map((y) {
              final title = (y.name ?? '').trim();
              final desc = (y.description ?? '').trim();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    Expanded(
                      child: Text(
                        title.isEmpty ? desc : (desc.isEmpty ? title : '$title — $desc'),
                        style: TextStyle(color: Colors.grey.shade700, height: 1.25),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanetDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Planet Positions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.kundaliData.planets.map((planet) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        planet.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'House ${planet.house}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• ${planet.sign}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
