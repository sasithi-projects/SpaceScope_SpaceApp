import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spacescope/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────── TEST 1 ─────────
  testWidgets('Settings screen loads', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
  });

  // ───────── TEST 2 ─────────
  testWidgets('Dark Mode toggle exists', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('Dark Mode'), findsOneWidget);
  });

  // ───────── TEST 3 ─────────
  testWidgets('Clear Starred Items option exists', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('Clear Starred Items'), findsOneWidget);
  });

  // ───────── TEST 4 ─────────
  testWidgets('Clear Reminders option exists', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('Clear Reminders'), findsOneWidget);
  });

  // ───────── TEST 5 ─────────
  testWidgets('About section exists', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('About'), findsOneWidget);
  });
}