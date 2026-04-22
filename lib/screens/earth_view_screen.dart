import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/earth_epic_service.dart';
import '../widgets/space_background.dart';

class EarthViewScreen extends StatefulWidget {
  const EarthViewScreen({super.key});

  @override
  State<EarthViewScreen> createState() => _EarthViewScreenState();
}

class _EarthViewScreenState extends State<EarthViewScreen> {
  final _service = EarthEpicService();

  bool _loading = false;
  String? _error;
  bool _isOffline = false;

  List<Map<String, dynamic>> _items = [];
  int _currentIndex = 0;

  // safer default date
  DateTime _selectedDate = DateTime(2023, 10, 10);

  @override
  void initState() {
    super.initState();
    _loadByDate(_selectedDate);
  }

  void _showCustomDatePicker() {
    int selectedYear = _selectedDate.year;
    int selectedMonth = _selectedDate.month;
    int selectedDay = _selectedDate.day;

    int yearIndex = selectedYear - 2015;
    int monthIndex = selectedMonth - 1;
    int dayIndex = selectedDay - 1;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    int daysInMonth(int year, int month) {
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;
      return DateTime(nextYear, nextMonth, 0).day;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6), // dim background
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    height: 320,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        const Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Expanded(
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  // ───────── YEAR ─────────
                                  Expanded(
                                    child: ListWheelScrollView.useDelegate(
                                      itemExtent: 40,
                                      physics: const FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        setModalState(() {
                                          yearIndex = index;
                                          selectedYear = 2015 + index;

                                          final maxDays = daysInMonth(
                                            selectedYear,
                                            selectedMonth,
                                          );
                                          if (selectedDay > maxDays) {
                                            selectedDay = maxDays;
                                            dayIndex = maxDays - 1;
                                          }
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                            builder: (_, index) {
                                              final year = 2015 + index;
                                              final isSelected =
                                                  index == yearIndex;

                                              return Center(
                                                child: Text(
                                                  '$year',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.white38,
                                                    fontSize: isSelected
                                                        ? 20
                                                        : 14,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              );
                                            },
                                            childCount:
                                                DateTime.now().year - 2015 + 1,
                                          ),
                                    ),
                                  ),

                                  // ───────── MONTH  ─────────
                                  Expanded(
                                    child: ListWheelScrollView.useDelegate(
                                      itemExtent: 40,
                                      physics: const FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        setModalState(() {
                                          monthIndex = index;
                                          selectedMonth = index + 1;

                                          final maxDays = daysInMonth(
                                            selectedYear,
                                            selectedMonth,
                                          );
                                          if (selectedDay > maxDays) {
                                            selectedDay = maxDays;
                                            dayIndex = maxDays - 1;
                                          }
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                            builder: (_, index) {
                                              final isSelected =
                                                  index == monthIndex;

                                              return Center(
                                                child: Text(
                                                  months[index],
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.white38,
                                                    fontSize: isSelected
                                                        ? 20
                                                        : 14,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              );
                                            },
                                            childCount: 12,
                                          ),
                                    ),
                                  ),

                                  // ───────── DAY ─────────
                                  Expanded(
                                    child: ListWheelScrollView.useDelegate(
                                      itemExtent: 40,
                                      physics: const FixedExtentScrollPhysics(),
                                      onSelectedItemChanged: (index) {
                                        setModalState(() {
                                          dayIndex = index;
                                          selectedDay = index + 1;
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                            builder: (_, index) {
                                              final isSelected =
                                                  index == dayIndex;

                                              return Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.white38,
                                                    fontSize: isSelected
                                                        ? 20
                                                        : 14,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              );
                                            },
                                            childCount: daysInMonth(
                                              selectedYear,
                                              selectedMonth,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ───────── APPLY BUTTON ─────────
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: () async {
                              final newDate = DateTime(
                                selectedYear,
                                selectedMonth,
                                selectedDay,
                              );

                              Navigator.pop(context);

                              setState(() {
                                _selectedDate = newDate;
                              });

                              await _loadByDate(newDate);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Apply'),
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
      },
    );
  }

  Widget _offlinePill() {
    if (!_isOffline) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
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
    );
  }
  // ───────────────── Load data ─────────────────

  Future<void> _loadByDate(DateTime date) async {
    setState(() {
      _loading = true;
      _error = null;
      _items = [];
      _currentIndex = 0;
      _isOffline = false;
    });

    try {
      final formatted = DateFormat('yyyy-MM-dd').format(date);

      print(' SELECTED DATE → $formatted');

      final data = await _service.fetchByDate(formatted);

      if (data.isEmpty) {
        print('⚠️ No data for selected date → loading latest instead');

        setState(() {
          _error =
              'No images for selected date. Showing latest available images.';
        });

        await _loadLatest();
        return;
      }

      _items = data;
    } catch (e) {
      _error = 'Unable to load Earth imagery';
      _isOffline = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  // ───────────────── Load latest images ─────────────────

  Future<void> _loadLatest() async {
    try {
      final uri = Uri.parse('https://epic.gsfc.nasa.gov/api/natural');

      print('🌍 FALLBACK → Loading latest EPIC images');

      final response = await http.get(uri);

      final List<dynamic> data = jsonDecode(response.body);

      if (data.isEmpty) {
        setState(() {
          _items = [];
        });
        return;
      }

      _items = data.map((e) => Map<String, dynamic>.from(e)).toList();

      // update date to latest available
      final latestDate = _items.first['date'].split(' ').first;
      _selectedDate = DateTime.parse(latestDate);
    } catch (e) {
      print('❌ FALLBACK ERROR → $e');
      setState(() {
        _error = 'Failed to load latest images';
      });
    }
  }

  // ───────────────── Pull to refresh ─────────────────

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await _loadByDate(_selectedDate);
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final titleDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Earth View')),
      body: SpaceBackground(
        child: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Earth Image',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          GestureDetector(
                            onTap: _showCustomDatePicker,
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
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_selectedDate),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      Text(
                        titleDate,
                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 16),

                      // Image area
                      AspectRatio(
                        aspectRatio: 1,
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _items.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.public,
                                  size: 72,
                                  color: Colors.white24,
                                ),
                              )
                            : _buildImagePager(),
                      ),

                      const SizedBox(height: 14),

                      if (_items.isNotEmpty) _buildDetails(),

                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        _buildErrorPill(),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              _offlinePill(),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── Image pager ─────────────────

  Widget _buildImagePager() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: PageView.builder(
        itemCount: _items.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (_, index) {
          final imageUrl = _service.buildImageUrl(_items[index]);

          return Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              );
            },
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.public, size: 72, color: Colors.white24),
            ),
          );
        },
      ),
    );
  }

  // ───────────────── Details ─────────────────

  Widget _buildDetails() {
    final item = _items[_currentIndex];
    final caption = item['caption'];
    final coords = item['centroid_coordinates'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Text(
            'Latitude: ${coords['lat']}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Longitude: ${coords['lon']}',
            style: const TextStyle(color: Colors.white70),
          ),
          if (_items.length > 1) ...[
            const SizedBox(height: 10),
            Text(
              'Image ${_currentIndex + 1} of ${_items.length}',
              style: const TextStyle(color: Colors.white38),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────── Error pill ─────────────────

  Widget _buildErrorPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        _error ?? '',
        style: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
