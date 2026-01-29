import 'package:flutter/material.dart';
import '../widgets/prokerala_chart_widget.dart';
import '../widgets/chart_selector_widget.dart';
import '../models/kundali_data.dart';
import '../models/prokerala_kundli_summary.dart';
import '../models/planet_position.dart';
import '../services/storage_service.dart';
import '../services/prokerala_api.dart';

class ChartDisplayScreen extends StatefulWidget {
  final KundaliData kundaliData;
  final ProkeralaKundliSummary? prokeralaSummary;
  final DateTime? birthDateTime;
  final String? location;
  final double? latitude;
  final double? longitude;

  const ChartDisplayScreen({
    super.key,
    required this.kundaliData,
    this.prokeralaSummary,
    this.birthDateTime,
    this.location,
    this.latitude,
    this.longitude,
  });

  @override
  State<ChartDisplayScreen> createState() => _ChartDisplayScreenState();
}

class _ChartDisplayScreenState extends State<ChartDisplayScreen> {
  bool _isSaved = false;
  String? _prokeralaChartSvg;
  bool _isLoadingChart = false;
  ChartType _selectedChartType = ChartType.rasi;
  ChartStyle _selectedChartStyle = ChartStyle.northIndian;
  PlanetPositionResult? _planetPositionResult;
  bool _isLoadingPlanetPosition = false;
  String? _planetPositionError;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    // Load planet positions if coordinates are available
    if (widget.birthDateTime != null &&
        widget.latitude != null &&
        widget.longitude != null) {
      _loadPlanetPositions();
    }
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


  Future<void> _loadProkeralaChartWithCoords(double latitude, double longitude) async {
    if (widget.birthDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Birth date/time is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingChart = true;
    });

    try {
      final svgContent = await ProkeralaApi.fetchChart(
        birthDateTime: widget.birthDateTime!,
        latitude: latitude,
        longitude: longitude,
        chartType: _selectedChartType.value,
        chartStyle: _selectedChartStyle.value,
        ayanamsa: 1, // Default to Lahiri
      );

      if (mounted) {
        setState(() {
          _prokeralaChartSvg = svgContent;
          _isLoadingChart = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingChart = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPlanetPositions() async {
    if (widget.birthDateTime == null ||
        widget.latitude == null ||
        widget.longitude == null) {
      return;
    }

    setState(() {
      _isLoadingPlanetPosition = true;
      _planetPositionError = null;
    });

    try {
      final rawResponse = await ProkeralaApi.fetchPlanetPosition(
        birthDateTime: widget.birthDateTime!,
        latitude: widget.latitude!,
        longitude: widget.longitude!,
        ayanamsa: 1, // Default to Lahiri
      );

      if (mounted) {
        setState(() {
          _planetPositionResult = PlanetPositionResult.fromApiResponse(rawResponse);
          _isLoadingPlanetPosition = false;
          _planetPositionError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPlanetPosition = false;
          _planetPositionError = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load planet positions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onChartSelectionChanged(ChartType chartType, ChartStyle chartStyle) {
    setState(() {
      _selectedChartType = chartType;
      _selectedChartStyle = chartStyle;
      _prokeralaChartSvg = null; // Reset chart when selection changes
    });
    
    // Auto-load chart if coordinates are available
    if (widget.birthDateTime != null &&
        widget.latitude != null &&
        widget.longitude != null) {
      _loadProkeralaChartWithCoords(
        widget.latitude!,
        widget.longitude!,
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
      body: _buildProkeralaChartTab(),
    );
  }

  Widget _buildProkeralaChartTab() {
    return SingleChildScrollView(
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
            child: ChartSelectorWidget(
              selectedChartType: _selectedChartType,
              selectedChartStyle: _selectedChartStyle,
              onSelectionChanged: _onChartSelectionChanged,
            ),
          ),
          if (_isLoadingChart)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else if (_prokeralaChartSvg != null)
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
                  Text(
                    '${_selectedChartType.label} Chart (${_selectedChartStyle.label})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProkeralaChartWidget(
                    svgContent: _prokeralaChartSvg!,
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select chart type and style, then load chart',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: (widget.birthDateTime != null &&
                            widget.latitude != null &&
                            widget.longitude != null)
                        ? () {
                            _loadProkeralaChartWithCoords(
                              widget.latitude!,
                              widget.longitude!,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load Chart'),
                  ),
                  if (widget.birthDateTime == null ||
                      widget.latitude == null ||
                      widget.longitude == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        widget.birthDateTime == null
                            ? 'Birth date/time is required'
                            : 'Location coordinates are required. Please regenerate chart with coordinates.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
          _buildDetailedPlanetPositionsSection(),
          const SizedBox(height: 20),
        ],
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
            'Planet Placements',
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

  Widget _buildDetailedPlanetPositionsSection() {
    // Show loading state
    if (_isLoadingPlanetPosition) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading planet positions...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show error state with retry button
    if (_planetPositionError != null) {
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
              'Detailed Planet Positions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Error: $_planetPositionError',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadPlanetPositions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show data if available
    if (_planetPositionResult != null && _planetPositionResult!.planets.isNotEmpty) {
      return _buildPlanetPositionDetails(_planetPositionResult!);
    }

    // Show button to load planet positions
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
            'Detailed Planet Positions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Get detailed planet positions including longitude, latitude, nakshatra, and more.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: (widget.birthDateTime != null &&
                    widget.latitude != null &&
                    widget.longitude != null)
                ? _loadPlanetPositions
                : null,
            icon: const Icon(Icons.visibility),
            label: const Text('Load Planet Positions'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          if (widget.birthDateTime == null ||
              widget.latitude == null ||
              widget.longitude == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.birthDateTime == null
                    ? 'Birth date/time is required'
                    : 'Location coordinates are required',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanetPositionDetails(PlanetPositionResult result) {
    if (result.planets.isEmpty) {
      return const SizedBox.shrink();
    }

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
          Row(
            children: [
              const Text(
                'Detailed Planet Positions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _loadPlanetPositions,
                tooltip: 'Refresh',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.planets.map((planet) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          planet.name ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (planet.isRetrograde == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'R',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (planet.sign != null)
                    _buildDetailRow('Sign', planet.sign!.name ?? planet.sign!.vedicName ?? 'N/A'),
                  if (planet.house != null)
                    _buildDetailRow('House', planet.house!.name ?? 'N/A'),
                  if (planet.nakshatra != null) ...[
                    _buildDetailRow(
                      'Nakshatra',
                      '${planet.nakshatra!.name ?? 'N/A'}${planet.nakshatra!.pada != null ? ' (Pada ${planet.nakshatra!.pada})' : ''}',
                    ),
                    if (planet.nakshatra!.lord != null)
                      _buildDetailRow(
                        'Nakshatra Lord',
                        planet.nakshatra!.lord!.name ?? planet.nakshatra!.lord!.vedicName ?? 'N/A',
                      ),
                  ],
                  if (planet.longitude != null)
                    _buildDetailRow('Longitude', planet.longitudeFormatted),
                  if (planet.latitude != null)
                    _buildDetailRow('Latitude', planet.latitudeFormatted),
                  if (planet.distance != null)
                    _buildDetailRow(
                      'Distance',
                      '${planet.distance!.toStringAsFixed(2)} AU',
                    ),
                  if (planet.altitude != null)
                    _buildDetailRow(
                      'Altitude',
                      '${planet.altitude!.toStringAsFixed(2)}°',
                    ),
                  if (planet.azimuth != null)
                    _buildDetailRow(
                      'Azimuth',
                      '${planet.azimuth!.toStringAsFixed(2)}°',
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
