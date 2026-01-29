import 'package:flutter/material.dart';

/// Chart type options for Prokerala API
enum ChartType {
  rasi('rasi', 'Rasi'),
  navamsa('navamsa', 'Navamsa'),
  lagna('lagna', 'Lagna'),
  trimsamsa('trimsamsa', 'Trimsamsa'),
  drekkana('drekkana', 'Drekkana'),
  chaturthamsa('chaturthamsa', 'Chaturthamsa'),
  dasamsa('dasamsa', 'Dasamsa'),
  ashtamsa('ashtamsa', 'Ashtamsa'),
  dwadasamsa('dwadasamsa', 'Dwadasamsa'),
  shodasamsa('shodasamsa', 'Shodasamsa'),
  hora('hora', 'Hora'),
  akshavedamsa('akshavedamsa', 'Akshavedamsa'),
  shashtyamsa('shashtyamsa', 'Shashtyamsa'),
  panchamsa('panchamsa', 'Panchamsa'),
  khavedamsa('khavedamsa', 'Khavedamsa'),
  saptavimsamsa('saptavimsamsa', 'Saptavimsamsa'),
  shashtamsa('shashtamsa', 'Shashtamsa'),
  chaturvimsamsa('chaturvimsamsa', 'Chaturvimsamsa'),
  saptamsa('saptamsa', 'Saptamsa'),
  vimsamsa('vimsamsa', 'Vimsamsa'),
  upagraha('upagraha', 'Upagraha'),
  bhava('bhava', 'Bhava'),
  sun('sun', 'Sun'),
  moon('moon', 'Moon');

  final String value;
  final String label;

  const ChartType(this.value, this.label);
}

/// Chart style options for Prokerala API
enum ChartStyle {
  northIndian('north-indian', 'North Indian'),
  southIndian('south-indian', 'South Indian'),
  eastIndian('east-indian', 'East Indian');

  final String value;
  final String label;

  const ChartStyle(this.value, this.label);
}

/// Widget for selecting chart type and style
class ChartSelectorWidget extends StatefulWidget {
  final ChartType? selectedChartType;
  final ChartStyle? selectedChartStyle;
  final Function(ChartType, ChartStyle) onSelectionChanged;

  const ChartSelectorWidget({
    super.key,
    this.selectedChartType,
    this.selectedChartStyle,
    required this.onSelectionChanged,
  });

  @override
  State<ChartSelectorWidget> createState() => _ChartSelectorWidgetState();
}

class _ChartSelectorWidgetState extends State<ChartSelectorWidget> {
  late ChartType _selectedChartType;
  late ChartStyle _selectedChartStyle;

  @override
  void initState() {
    super.initState();
    _selectedChartType = widget.selectedChartType ?? ChartType.rasi;
    _selectedChartStyle = widget.selectedChartStyle ?? ChartStyle.northIndian;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chart Type'),
        const SizedBox(height: 8),
        _buildChartTypeSelector(),
        const SizedBox(height: 24),
        _buildSectionTitle('Chart Style'),
        const SizedBox(height: 8),
        _buildChartStyleSelector(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<ChartType>(
        value: _selectedChartType,
        isExpanded: true,
        underline: const SizedBox(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        items: ChartType.values.map((type) {
          return DropdownMenuItem<ChartType>(
            value: type,
            child: Text(type.label),
          );
        }).toList(),
        onChanged: (ChartType? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedChartType = newValue;
            });
            widget.onSelectionChanged(_selectedChartType, _selectedChartStyle);
          }
        },
      ),
    );
  }

  Widget _buildChartStyleSelector() {
    return Row(
      children: ChartStyle.values.map((style) {
        final isSelected = _selectedChartStyle == style;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: style != ChartStyle.values.last ? 8 : 0,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedChartStyle = style;
                });
                widget.onSelectionChanged(_selectedChartType, _selectedChartStyle);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  style.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
