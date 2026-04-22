import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacescope/services/reminder_service.dart';

void main() {
  late ReminderService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = ReminderService();
  });

  // ───────── TEST 1 ─────────
  test('Add reminder', () async {
    final asteroid = {
      'name': 'Asteroid X',
      'date': '2026-01-01',
    };

    final added = await service.toggle(asteroid);

    expect(added, true);

    final isSaved = await service.isSaved(asteroid);
    expect(isSaved, true);
  });

  // ───────── TEST 2 ─────────
  test('Remove reminder', () async {
    final asteroid = {
      'name': 'Asteroid X',
      'date': '2026-01-01',
    };

    await service.toggle(asteroid); // add
    await service.toggle(asteroid); // remove

    final isSaved = await service.isSaved(asteroid);
    expect(isSaved, false);
  });

  // ───────── TEST 3 ─────────
  test('Clear all reminders', () async {
    final asteroid = {
      'name': 'Asteroid X',
      'date': '2026-01-01',
    };

    await service.toggle(asteroid);

    await service.clearAll();

    final all = await service.getAll();
    expect(all.isEmpty, true);
  });
}