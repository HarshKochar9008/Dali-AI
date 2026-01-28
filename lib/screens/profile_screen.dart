import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'about_screen.dart';
import 'chart_display_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _tobController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  DateTime? _selectedDob;
  TimeOfDay? _selectedTob;
  String _gender = '';

  bool _loading = true;
  bool _saving = false;

  List<HistoryItem> _history = [];
  bool _historyLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _historyLoading = true;
    });

    final profile = await StorageService.getProfile();
    final history = await StorageService.getHistory();

    if (!mounted) return;

    _nameController.text = profile.fullName;
    _gender = profile.gender;

    _selectedDob = profile.dateOfBirth;
    _dobController.text = _selectedDob == null
        ? ''
        : DateFormat('dd/MM/yyyy').format(_selectedDob!);

    if (profile.timeOfBirth.isNotEmpty) {
      _tobController.text = profile.timeOfBirth;
      final parts = profile.timeOfBirth.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          _selectedTob = TimeOfDay(hour: h, minute: m);
        }
      }
    } else {
      _tobController.text = '';
      _selectedTob = null;
    }

    _locationController.text = profile.locationName;
    _latController.text = profile.latitude?.toString() ?? '';
    _lonController.text = profile.longitude?.toString() ?? '';

    setState(() {
      _history = history;
      _loading = false;
      _historyLoading = false;
    });
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickTob() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTob ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTob = picked;
        _tobController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter full name';
    return null;
  }

  String? _validateDob(String? v) {
    if (_selectedDob == null) return 'Please select date of birth';
    return null;
  }

  String? _validateTob(String? v) {
    if (v == null || v.isEmpty) return 'Please select time of birth';
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(v)) return 'Enter time in HH:MM (24-hour)';
    return null;
  }

  String? _validateLat(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final lat = double.tryParse(v.trim());
    if (lat == null) return 'Enter valid latitude';
    if (lat < -90 || lat > 90) return 'Latitude must be between -90 and 90';
    return null;
  }

  String? _validateLon(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final lon = double.tryParse(v.trim());
    if (lon == null) return 'Enter valid longitude';
    if (lon < -180 || lon > 180) return 'Longitude must be between -180 and 180';
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    setState(() => _saving = true);

    final lat = _latController.text.trim().isEmpty
        ? null
        : double.tryParse(_latController.text.trim());
    final lon = _lonController.text.trim().isEmpty
        ? null
        : double.tryParse(_lonController.text.trim());

    final profile = UserProfile(
      fullName: _nameController.text.trim(),
      gender: _gender,
      dateOfBirth: _selectedDob,
      timeOfBirth: _tobController.text.trim(),
      locationName: _locationController.text.trim(),
      latitude: lat,
      longitude: lon,
    );

    await StorageService.saveProfile(profile);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  Future<void> _deleteHistoryItem(int index) async {
    await StorageService.deleteHistoryItem(index);
    final history = await StorageService.getHistory();
    if (!mounted) return;
    setState(() => _history = history);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chart deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text(
          'This will delete all saved charts. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.clearHistory();
      final history = await StorageService.getHistory();
      if (!mounted) return;
      setState(() => _history = history);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All history cleared'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _saveProfile,
            tooltip: 'Save',
            icon: const Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Basic Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _gender.isEmpty ? null : _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? ''),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: _pickDob,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        validator: _validateDob,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tobController,
                        readOnly: true,
                        onTap: _pickTob,
                        decoration: const InputDecoration(
                          labelText: 'Time of Birth',
                          prefixIcon: Icon(Icons.access_time_outlined),
                        ),
                        validator: _validateTob,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Birth Place (City/Country)',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Latitude (optional)',
                              ),
                              validator: _validateLat,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lonController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Longitude (optional)',
                              ),
                              validator: _validateLon,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _saveProfile,
                          icon: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_rounded),
                          label: const Text('Save Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_history.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearAllHistory,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_historyLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_history.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No saved charts yet. Generate a kundali to see it here.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_history.length, (index) {
                final item = _history[index];
                final date = item.dateTime;
                final dateStr = '${date.day}/${date.month}/${date.year}';
                final timeStr =
                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChartDisplayScreen(
                            kundaliData: item.kundaliData,
                            birthDateTime: item.dateTime,
                            location: item.location,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kundali Chart',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                                        const SizedBox(width: 6),
                                        Text(
                                          dateStr,
                                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.access_time, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                                        const SizedBox(width: 6),
                                        Text(
                                          timeStr,
                                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                    if (item.location.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                                          const SizedBox(width: 6),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 180),
                                            child: Text(
                                              item.location,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteHistoryItem(index),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
            Text(
              'App',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.settings_rounded, color: colorScheme.primary),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                    title: const Text('About'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

