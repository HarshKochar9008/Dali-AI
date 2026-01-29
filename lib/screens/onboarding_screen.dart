import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/app_colors.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _totalSteps = 5;
  static const List<String> _stepTitles = [
    'Your Name',
    'Date of Birth',
    'Birth of Time',
    'Your Location',
    'Your Gender',
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  String _name = '';
  DateTime? _dateOfBirth;
  TimeOfDay? _timeOfBirth;
  double? _latitude;
  double? _longitude;
  String _locationName = '';
  String _gender = '';

  bool _locationLoading = false;
  String? _locationError;

  double get _progress => (_currentStep + 1) / _totalSteps;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final timeOfBirthStr = _timeOfBirth != null
        ? '${_timeOfBirth!.hour.toString().padLeft(2, '0')}:${_timeOfBirth!.minute.toString().padLeft(2, '0')}'
        : '';

    String locationName = _locationName;
    if (locationName.isEmpty && _latitude != null && _longitude != null) {
      locationName =
          'Lat: ${_latitude!.toStringAsFixed(5)}, Lon: ${_longitude!.toStringAsFixed(5)}';
    }

    final profile = UserProfile(
      fullName: _name.trim(),
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      timeOfBirth: timeOfBirthStr,
      locationName: locationName,
      latitude: _latitude,
      longitude: _longitude,
      phone: '',
    );
    await StorageService.saveProfile(profile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _next();
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back, title, progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: colorScheme.onBackground,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _stepTitles[_currentStep],
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  backgroundColor: AppColors.borderDark,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.accentViolet.withOpacity(0.9),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24, top: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(_progress * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.unselectedDark,
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildNameStep(theme, colorScheme),
                  _buildDateStep(theme, colorScheme),
                  _buildTimeStep(theme, colorScheme),
                  _buildLocationStep(theme, colorScheme),
                  _buildGenderStep(theme, colorScheme),
                ],
              ),
            ),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: _skip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentViolet,
                      side: const BorderSide(color: AppColors.accentViolet),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Skip!'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _currentStep < _totalSteps - 1 ? 'Next' : 'Get Started',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tell us about yourself so that we can make a more personalised prediction.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.unselectedDark,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _name = v),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: AppColors.unselectedDark),
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
              filled: true,
              fillColor: AppColors.cardDark,
            ),
            style: TextStyle(color: colorScheme.onBackground),
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              LengthLimitingTextInputFormatter(80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateStep(ThemeData theme, ColorScheme colorScheme) {
    final initialDate = _dateOfBirth ?? DateTime.now();
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Date is important for determining your sun sign, numerology and compatibility.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.unselectedDark,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildZodiacDecoration(),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: colorScheme.copyWith(
                          surface: AppColors.cardDark,
                          onSurface: colorScheme.onBackground,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _dateOfBirth = picked);
              },
              icon: const Icon(Icons.calendar_today_rounded),
              label: Text(
                _dateOfBirth != null
                    ? '${_dateOfBirth!.day} ${_monthName(_dateOfBirth!.month)} ${_dateOfBirth!.year}'
                    : 'Pick date',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentViolet,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStep(ThemeData theme, ColorScheme colorScheme) {
    final initialTime = _timeOfBirth ?? const TimeOfDay(hour: 12, minute: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Time is important for determining your houses, rising sign, and exact moon position.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.unselectedDark,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildZodiacDecoration(),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: colorScheme.copyWith(
                          surface: AppColors.cardDark,
                          onSurface: colorScheme.onBackground,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _timeOfBirth = picked);
              },
              icon: const Icon(Icons.access_time_rounded),
              label: Text(
                _timeOfBirth != null ? _formatTime(_timeOfBirth!) : 'Pick time',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentViolet,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocation() async {
    if (_locationLoading) return;
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });

    try {
      // On web, isLocationServiceEnabled/checkPermission/requestPermission
      // are not implemented (MissingPluginException). The browser will prompt
      // when getCurrentPosition is called.
      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (!mounted) return;
          setState(() {
            _locationLoading = false;
            _locationError =
                'Location services are disabled. Please enable them in settings.';
          });
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _locationLoading = false;
            _locationError = 'Location access was denied.';
          });
          return;
        }
        if (permission == LocationPermission.deniedForever) {
          if (!mounted) return;
          setState(() {
            _locationLoading = false;
            _locationError =
                'Location access is permanently denied. Enable it in app settings.';
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName = _locationName.isEmpty
            ? 'Lat: ${position.latitude.toStringAsFixed(5)}, Lon: ${position.longitude.toStringAsFixed(5)}'
            : _locationName;
        _locationLoading = false;
        _locationError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationLoading = false;
        _locationError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _buildLocationStep(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your birth place coordinates help us calculate your exact kundali. Allow access to use your current location or skip to enter later.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.unselectedDark,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentViolet.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: AppColors.accentViolet.withOpacity(0.5),
                  width: 2,
                ),
                color: AppColors.cardDark.withOpacity(0.6),
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 64,
                color: AppColors.accentViolet.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_locationError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _locationError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_latitude != null && _longitude != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorderDark),
                ),
                child: Column(
                  children: [
                    Text(
                      'Location saved',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.accentViolet,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onBackground,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _locationLoading ? null : _requestLocation,
              icon: _locationLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(_locationLoading
                  ? 'Getting location…'
                  : 'Allow location access'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStep(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'It will reveal the balance of your masculine and feminine energy.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.unselectedDark,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildGenderIcon(),
          const SizedBox(height: 32),
          _genderOption('Male', theme, colorScheme),
          const SizedBox(height: 12),
          _genderOption('Female', theme, colorScheme),
          const SizedBox(height: 12),
          _genderOption('Other', theme, colorScheme),
        ],
      ),
    );
  }

  Widget _genderOption(String value, ThemeData theme, ColorScheme colorScheme) {
    final isSelected = _gender == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _gender = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentViolet
                  : AppColors.inputBorderDark,
              width: isSelected ? 1.5 : 1,
            ),
            color: AppColors.cardDark,
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentViolet
                        : AppColors.unselectedDark,
                    width: 2,
                  ),
                  color:
                      isSelected ? AppColors.accentViolet : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZodiacDecoration() {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.headerViolet.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppColors.accentViolet.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: AppColors.accentViolet.withOpacity(0.5),
            width: 2,
          ),
          color: AppColors.cardDark.withOpacity(0.6),
        ),
        child: Center(
          child: Icon(
            Icons.nightlight_round,
            size: 64,
            color: AppColors.accentViolet.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderIcon() {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentViolet.withOpacity(0.3),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
          gradient: RadialGradient(
            colors: [
              AppColors.accentViolet.withOpacity(0.3),
              AppColors.headerViolet.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Icon(
          Icons.person_rounded,
          size: 80,
          color: AppColors.accentViolet.withOpacity(0.9),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour : ${t.minute.toString().padLeft(2, '0')} $ampm';
  }
}
