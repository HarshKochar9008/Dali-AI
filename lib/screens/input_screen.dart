import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/prokerala_api.dart';
import '../models/prokerala_kundli_summary.dart';
import 'chart_display_screen.dart';
import '../services/storage_service.dart';

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
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _locationController.dispose();
    super.dispose();
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
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
      final prokeralaSummary = ProkeralaKundliSummary.fromApiResponse(prokeralaRaw);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Kundali'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: _validateDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Time of Birth',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(Icons.access_time_outlined),
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  validator: _validateTime,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _latitudeController,
                  decoration: InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateLatitude,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudeController,
                  decoration: InputDecoration(
                    labelText: 'Longitude',
                    hintText: '77.2090',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateLongitude,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location (Optional)',
                    hintText: 'New Delhi, India',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchKundali,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_outlined, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Generate',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
    );
  }
}
