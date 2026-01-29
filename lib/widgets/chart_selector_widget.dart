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
        _buildSectionTitle(context, 'Chart Type'),
        const SizedBox(height: 8),
        _buildChartTypeSelector(context),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Chart Style'),
        const SizedBox(height: 8),
        _buildChartStyleSelector(context),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildChartTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? colorScheme.outline : Colors.grey.shade300,
        ),
      ),
      child: DropdownButton<ChartType>(
        dropdownColor: theme.cardTheme.color ?? colorScheme.surface,
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

  Widget _buildChartStyleSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
                widget.onSelectionChanged(
                    _selectedChartType, _selectedChartStyle);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : (theme.cardTheme.color ?? colorScheme.surface),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : (isDark ? colorScheme.outline : Colors.grey.shade300),
                  ),
                ),
                child: Text(
                  style.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
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
