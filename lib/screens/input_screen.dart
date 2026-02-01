import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/prokerala_api.dart';
import '../models/prokerala_kundli_summary.dart';
import 'chart_display_screen.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileAndPrefill();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileAndPrefill() async {
    final profile = await StorageService.getProfile();
    if (!mounted) return;

    if (profile.dateOfBirth != null) {
      _selectedDate = profile.dateOfBirth;
      _dateController.text =
          DateFormat('dd/MM/yyyy').format(profile.dateOfBirth!);
    }
    if (profile.timeOfBirth.isNotEmpty) {
      final parts = profile.timeOfBirth.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 12 : 12;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
      _timeController.text =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    if (profile.latitude != null) {
      _latitudeController.text = profile.latitude!.toString();
    }
    if (profile.longitude != null) {
      _longitudeController.text = profile.longitude!.toString();
    }
    if (profile.locationName.isNotEmpty) {
      _locationController.text = profile.locationName;
    }
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter date of birth';
    }
    return null;
  }

  String? _validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter time of birth';
    }
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter time in HH:MM format (24-hour)';
    }
    return null;
  }

  String? _validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter latitude';
    }
    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Please enter a valid number';
    }
    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter longitude';
    }
    final lon = double.tryParse(value);
    if (lon == null) {
      return 'Please enter a valid number';
    }
    if (lon < -180 || lon > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  Future<void> _fetchKundali() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lat = double.parse(_latitudeController.text);
      final lon = double.parse(_longitudeController.text);

      final birthDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Fetch summary from Prokerala `/v2/astrology/kundli`.
      final prokeralaRaw = await ProkeralaApi.fetchKundli(
        birthDateTime: birthDateTime,
        latitude: lat,
        longitude: lon,
      );
      final prokeralaSummary =
          ProkeralaKundliSummary.fromApiResponse(prokeralaRaw);

      // Build chart data from Prokerala response (no FreeAstro API).
      final kundaliData = ProkeralaApi.toKundaliData(prokeralaRaw);

      // Auto-save to history
      final location = _locationController.text.isEmpty
          ? 'Lat: $lat, Lon: $lon'
          : _locationController.text;
      await StorageService.saveKundali(
        kundaliData,
        birthDateTime,
        location,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChartDisplayScreen(
              kundaliData: kundaliData,
              prokeralaSummary: prokeralaSummary,
              birthDateTime: birthDateTime,
              location: location,
              latitude: lat,
              longitude: lon,
            ),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.surfaceBlack,
      appBar: AppBar(
        title: Text(
          'Generate Kundali',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceBlack,
        foregroundColor: Colors.white,
        toolbarHeight: 48,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Birth details',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.accentViolet,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildInput(
                context: context,
                controller: _dateController,
                label: 'Date of Birth',
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: _validateDate,
              ),
              const SizedBox(height: 14),
              _buildInput(
                context: context,
                controller: _timeController,
                label: 'Time of Birth',
                icon: Icons.access_time_outlined,
                readOnly: true,
                onTap: () => _selectTime(context),
                validator: _validateTime,
              ),
              const SizedBox(height: 24),
              Text(
                'Place of birth',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.accentViolet,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildInput(
                context: context,
                controller: _latitudeController,
                label: 'Latitude',
                icon: Icons.location_on_outlined,
                hintText: 'e.g. 28.5355',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateLatitude,
              ),
              const SizedBox(height: 14),
              _buildInput(
                context: context,
                controller: _longitudeController,
                label: 'Longitude',
                icon: Icons.location_on_outlined,
                hintText: 'e.g. 77.2090',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateLongitude,
              ),
              const SizedBox(height: 14),
              _buildInput(
                context: context,
                controller: _locationController,
                label: 'Location (Optional)',
                hintText: 'e.g. New Delhi, India',
                dropdownItems: const [
                  'New Delhi, India',
                  'Mumbai, India',
                  'Bangalore, India',
                  'Chennai, India',
                  'Hyderabad, India',
                  'Kolkata, India',
                  'Pune, India',
                ],
                icon: Icons.place_outlined,
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _fetchKundali,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentViolet,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_outlined, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Generate Kundali',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.5)
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red.shade400,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<String>? dropdownItems,
    String? selectedDropdownItem,
    void Function(String?)? onDropdownChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.unselectedDark.withValues(alpha: 0.8)),
            labelStyle: TextStyle(color: AppColors.unselectedDark),
            prefixIcon: Icon(
              icon,
              color: AppColors.accentViolet.withValues(alpha: 0.9),
              size: 22,
            ),
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accentViolet,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
        if (dropdownItems != null && dropdownItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedDropdownItem,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.place_outlined),
            ),
            items: dropdownItems.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onDropdownChanged,
          ),
        ],
      ],
    );
  }
}