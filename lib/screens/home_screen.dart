import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../utils/zodiac_utils.dart';
import 'input_screen.dart';
import 'chart_display_screen.dart';
import 'profile_screen.dart';
import '../models/kundali_data.dart';
import '../models/user_profile.dart';
import '../models/prokerala_kundli_summary.dart';
import '../services/storage_service.dart' show StorageService, HistoryItem;
import '../services/prokerala_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  KundaliData? _latestKundali;
  List<HistoryItem> _history = [];
  UserProfile _profile = UserProfile.empty;
  bool _saveAndGenerateLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await StorageService.getProfile();
    final history = await StorageService.getHistory();
    if (mounted) {
      setState(() {
        _profile = profile;
        _history = history;
        _latestKundali = history.isNotEmpty ? history.first.kundaliData : null;
      });
    }
  }

  Future<void> _loadLatestKundali() async {
    await _loadData();
  }

  static String _firstName(String fullName) {
    final t = fullName.trim();
    if (t.isEmpty) return 'Guest';
    final parts = t.split(RegExp(r'\s+'));
    return parts.first;
  }

  /// Uses saved profile from onboarding to generate and save kundali, then shows chart.
  Future<void> _saveAndGenerateFromProfile() async {
    setState(() {
      _saveAndGenerateLoading = true;
    });

    try {
      final profile = await StorageService.getProfile();
      final hasRequired = profile.dateOfBirth != null &&
          profile.timeOfBirth.isNotEmpty &&
          profile.latitude != null &&
          profile.longitude != null;

      if (!hasRequired) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Complete your profile with date, time and location. Go to Generate to enter details.',
            ),
          ),
        );
        setState(() {
          _currentIndex = 1;
          _saveAndGenerateLoading = false;
        });
        return;
      }

      final parts = profile.timeOfBirth.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 12 : 12;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

      final birthDateTime = DateTime(
        profile.dateOfBirth!.year,
        profile.dateOfBirth!.month,
        profile.dateOfBirth!.day,
        hour,
        minute,
      );

      final lat = profile.latitude!;
      final lon = profile.longitude!;
      final prokeralaRaw = await ProkeralaApi.fetchKundli(
        birthDateTime: birthDateTime,
        latitude: lat,
        longitude: lon,
      );
      final prokeralaSummary =
          ProkeralaKundliSummary.fromApiResponse(prokeralaRaw);
      final kundaliData = ProkeralaApi.toKundaliData(prokeralaRaw);

      final location = profile.locationName.isNotEmpty
          ? profile.locationName
          : 'Lat: $lat, Lon: $lon';
      await StorageService.saveKundali(
        kundaliData,
        birthDateTime,
        location,
      );

      if (!mounted) return;
      await _loadLatestKundali();
      if (!mounted) return;
      Navigator.of(context).push(
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not generate chart: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saveAndGenerateLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          const InputScreen(),
          _latestKundali != null && _history.isNotEmpty
              ? ChartDisplayScreen(
                  kundaliData: _latestKundali!,
                  birthDateTime: _history.first.dateTime,
                  location: _history.first.location,
                )
              : _latestKundali != null
                  ? ChartDisplayScreen(kundaliData: _latestKundali!)
                  : _buildNoChartPlaceholder(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.borderDark,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) async {
            if (index == 2) {
              await _loadLatestKundali();
            }
            setState(() {
              _currentIndex = index;
            });
          },
          type: theme.bottomNavigationBarTheme.type,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ??
              colorScheme.primary,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor ??
                  colorScheme.onSurface.withOpacity(0.5),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: theme.bottomNavigationBarTheme.elevation ?? 0,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
              colorScheme.surface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Generate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'Chart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final dateTimeStr =
        '${DateFormat('MMMM, d yyyy').format(now)} - ${DateFormat('hh:mm a').format(now)}';
    final primarySign =
        ZodiacUtils.primarySignName(_latestKundali, _profile.dateOfBirth);
    final signAbbr =
        ZodiacUtils.primarySignAbbr(_latestKundali, _profile.dateOfBirth);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Greeting + date/time
              Text(
                'Hello, ${_firstName(_profile.fullName)}!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateTimeStr,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              // Profile / chart selector (horizontal)
              SizedBox(
                height: 88,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildProfileCircle(
                      label: _firstName(_profile.fullName),
                      isAdd: false,
                      isSelected: true,
                      onTap: () {},
                    ),
                    if (_history.isNotEmpty)
                      _buildProfileCircle(
                        label: 'Latest',
                        isAdd: false,
                        isSelected: false,
                        onTap: () {
                          setState(() => _currentIndex = 2);
                        },
                      ),
                    _buildProfileCircle(
                      label: 'Add',
                      isAdd: true,
                      isSelected: false,
                      onTap: () {
                        setState(() => _currentIndex = 1);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Main profile card
              _buildMainProfileCard(
                colorScheme: colorScheme,
                primarySign: primarySign,
                signAbbr: signAbbr,
              ),
              const SizedBox(height: 24),
              // Horoscope section
              _buildHoroscopeSection(colorScheme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCircle({
    required String label,
    required bool isAdd,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isAdd
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withOpacity(0.4),
                          colorScheme.primary,
                        ],
                      ),
                color: isAdd ? AppColors.borderDark : null,
                border: Border.all(
                  color:
                      isSelected ? colorScheme.primary : AppColors.borderDark,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Center(
                child: isAdd
                    ? Icon(Icons.add, color: colorScheme.onSurface, size: 28)
                    : Text(
                        label.isNotEmpty ? label[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainProfileCard({
    required ColorScheme colorScheme,
    required String primarySign,
    required String signAbbr,
  }) {
    final hasRising = _latestKundali != null &&
        ZodiacUtils.risingSignFromKundali(_latestKundali) != '—';
    final sunSign = ZodiacUtils.sunSignFromKundali(_latestKundali);
    final moonSign = ZodiacUtils.moonSignFromKundali(_latestKundali);
    final risingSign = ZodiacUtils.risingSignFromKundali(_latestKundali);
    final element = ZodiacUtils.element(signAbbr.isEmpty ? null : signAbbr);
    final polarity = ZodiacUtils.polarity(signAbbr.isEmpty ? null : signAbbr);
    final modality = ZodiacUtils.modality(signAbbr.isEmpty ? null : signAbbr);
    final status = _profile.gender.isNotEmpty ? _profile.gender : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _profile.fullName.trim().isEmpty
                ? 'Your profile'
                : _profile.fullName.trim(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$primarySign - $status',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAstroRow(
                        'SUN SIGN',
                        sunSign != '—'
                            ? sunSign
                            : ZodiacUtils.sunSignNameFromDob(
                                _profile.dateOfBirth)),
                    const SizedBox(height: 10),
                    _buildAstroRow('MOON SIGN', moonSign),
                    const SizedBox(height: 10),
                    _buildRisingRow(hasRising, risingSign),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildZodiacCircle(primarySign, colorScheme),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAstroRow('ELEMENT', element),
                    const SizedBox(height: 10),
                    _buildAstroRow('POLARITY', polarity),
                    const SizedBox(height: 10),
                    _buildAstroRow('MODALITY', modality),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndGenerateLoading
                  ? null
                  : () async {
                      if (_latestKundali != null) {
                        setState(() => _currentIndex = 2);
                      } else {
                        await _saveAndGenerateFromProfile();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.headerViolet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saveAndGenerateLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _latestKundali != null
                          ? 'More Details'
                          : 'Generate Chart',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstroRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildRisingRow(bool hasRising, String risingSign) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RISING SIGN',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 6),
        if (hasRising)
          Text(
            risingSign,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          )
        else
          OutlinedButton(
            onPressed: () {
              setState(() => _currentIndex = 1);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Find Out',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildZodiacCircle(String signName, ColorScheme colorScheme) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.3),
            colorScheme.primary,
            AppColors.headerViolet.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          signName.length >= 2 ? signName.substring(0, 2).toUpperCase() : '—',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHoroscopeSection(ColorScheme colorScheme) {
    final now = DateTime.now();
    final dateStr = DateFormat('MMM d yyyy, EEEE').format(now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your horoscope for today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.work_outline_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Work',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.34,
                    minHeight: 6,
                    backgroundColor: AppColors.borderDark,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '34%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Generate your Kundali chart to get personalized insights and daily horoscope. Your chart reveals planetary positions at birth and can guide you on career, relationships, and life purpose.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChartPlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.surfaceBlack,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    size: 48,
                    color: colorScheme.primary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No chart yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate a Kundali chart to view it here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onBackground.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 28),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  icon: Icon(Icons.add_circle_outline,
                      size: 20, color: colorScheme.primary),
                  label: Text(
                    'Generate Chart',
                    style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
