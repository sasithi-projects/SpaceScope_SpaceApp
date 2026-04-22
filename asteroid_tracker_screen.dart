import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/asteroid_service.dart';
import '../services/reminder_service.dart';
import '../widgets/space_background.dart';

class AsteroidTrackerScreen extends StatefulWidget {
  final bool resetReminders;

  const AsteroidTrackerScreen({super.key, this.resetReminders = false});

  @override
  State<AsteroidTrackerScreen> createState() => _AsteroidTrackerScreenState();
}

class _AsteroidTrackerScreenState extends State<AsteroidTrackerScreen> {
  final _service = AsteroidService();
  final _reminderService = ReminderService();

  bool _loading = false;
  bool _isReminderMode = false;
  bool _isOffline = false;

  List<Map<String, dynamic>> _asteroids = [];
  List<Map<String, dynamic>> _savedReminders = [];
  Widget _offlinePill() {
    if (!_isOffline) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 18, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'You are offline',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePickerPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      isScrollControlled: true,

      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ..._dateOptions.map((date) {
                        final isSelected = date == _selectedDate;

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);

                            setState(() {
                              _selectedDate = date;
                            });

                            _loadAsteroids();
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white24
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              _formatDate(date),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();

    if (widget.resetReminders) {
      _isReminderMode = false;
    }

    _loadAsteroids();
  }

  List<DateTime> get _dateOptions {
    final now = DateTime.now();

    return List.generate(7, (i) {
      final d = now.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }

    final tomorrow = today.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }

    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _loadAsteroids() async {
    setState(() {
      _loading = true;
      _isOffline = false;
    });

    try {
      final data = await _service.fetchAsteroids(_selectedDate);
      _savedReminders = await _reminderService.getAll();

      for (var a in data) {
        a['reminder'] = await _reminderService.isSaved(a);
      }

      _asteroids = data;
    } catch (_) {
      _isOffline = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<bool> _confirmRemoval() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Remove reminder?'),
            content: const Text(
              'Do you want to remove this asteroid reminder?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _toggleReminder(int index) async {
    final asteroid = _asteroids[index];
    final isCurrentlySaved = asteroid['reminder'] == true;

    if (isCurrentlySaved) {
      final ok = await _confirmRemoval();
      if (!ok) return;
    }

    final isNowSaved = await _reminderService.toggle(asteroid);

    HapticFeedback.lightImpact();

    setState(() {
      asteroid['reminder'] = isNowSaved;
    });

    _showSnack(
      isNowSaved ? 'Reminder added' : 'Reminder removed',
      isNowSaved ? Colors.green : Colors.redAccent,
    );
  }

  Future<void> _toggleReminderDirect(Map<String, dynamic> asteroid) async {
    final isCurrentlySaved = await _reminderService.isSaved(asteroid);

    if (isCurrentlySaved) {
      final ok = await _confirmRemoval();
      if (!ok) return;
    }

    final isNowSaved = await _reminderService.toggle(asteroid);

    HapticFeedback.lightImpact();

    setState(() {
      asteroid['reminder'] = isNowSaved;
    });

    _showSnack(
      isNowSaved ? 'Reminder added' : 'Reminder removed',
      isNowSaved ? Colors.green : Colors.redAccent,
    );

    _savedReminders = await _reminderService.getAll();
  }

  void _openDetails(Map<String, dynamic> asteroid, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 100, 16, 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asteroid['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _detail('Date', asteroid['date']),
                    _detail('Distance', asteroid['distance']),
                    _detail('Estimated size', asteroid['size']),
                    const SizedBox(height: 8),
                    Text(
                      asteroid['hazardous']
                          ? '⚠️ Potentially hazardous'
                          : 'Not hazardous',
                      style: TextStyle(
                        color: asteroid['hazardous']
                            ? Colors.redAccent
                            : Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          if (_isReminderMode) {
                            _toggleReminderDirect(asteroid);
                          } else {
                            _toggleReminder(index);
                          }
                        },
                        icon: Icon(
                          asteroid['reminder']
                              ? Icons.notifications_off
                              : Icons.notifications_active,
                        ),
                        label: Text(
                          asteroid['reminder']
                              ? 'Remove reminder'
                              : 'Set reminder',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_isReminderMode ? 'Reminders' : 'Asteroids'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isReminderMode = !_isReminderMode);
              },
              child: _reminderPill(),
            ),
          ),
        ],
      ),
      body: SpaceBackground(
        child: Stack(
          children: [
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _isReminderMode
                ? _buildReminders()
                : _buildAsteroids(),

            _offlinePill(),
          ],
        ),
      ),
    );
  }

  Widget _reminderPill() {
    final active = _isReminderMode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? Colors.redAccent.withOpacity(0.9)
            : Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? Colors.redAccent : Colors.white24),
      ),
      child: Row(
        children: const [
          Icon(Icons.notifications, size: 18),
          SizedBox(width: 6),
          Text(
            'Reminders',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAsteroids() {
    if (_asteroids.isEmpty) {
      return const Center(
        child: Text(
          'No asteroid data available !',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAsteroids,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Closest Approach'),
          _closestAsteroidCard(_asteroids.first, 0),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('All Asteroids'),

              GestureDetector(
                onTap: _showDatePickerPopup,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          ..._asteroids.asMap().entries.map(
            (e) => _asteroidCard(e.value, e.key),
          ),
        ],
      ),
    );
  }

  Widget _buildReminders() {
    if (_savedReminders.isEmpty) {
      return const Center(
        child: Text(
          'No reminders yet',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAsteroids,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _savedReminders.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;

          // force reminder state
          final fixed = Map<String, dynamic>.from(a);
          fixed['reminder'] = true;

          return _asteroidCard(fixed, i);
        }).toList(),
      ),
    );
  }

  Widget _closestAsteroidCard(Map<String, dynamic> asteroid, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  asteroid['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleReminder(index),
                child: Icon(
                  asteroid['reminder']
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _detail('Date', asteroid['date']),
          _detail('Distance', asteroid['distance']),
          _detail('Size', asteroid['size']),
          const SizedBox(height: 8),
          Text(
            asteroid['hazardous']
                ? '⚠️ Potentially hazardous'
                : 'Not hazardous',
            style: TextStyle(
              color: asteroid['hazardous']
                  ? Colors.redAccent
                  : Colors.greenAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _asteroidCard(Map<String, dynamic> asteroid, int index) {
    Color tintColor;

    if (asteroid['hazardous'] == true) {
      tintColor = Colors.redAccent;
    } else {
      tintColor = Colors.greenAccent;
    }

    return GestureDetector(
      onTap: () => _openDetails(asteroid, index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tintColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tintColor.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asteroid['name'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    asteroid['distance'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                if (_isReminderMode) {
                  _toggleReminderDirect(asteroid);
                } else {
                  _toggleReminder(index);
                }
              },
              child: Icon(
                asteroid['reminder']
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: tintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}
