import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spacescope/widgets/bottom_nav_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────── TEST 1 ─────────
  testWidgets('Bottom nav bar loads', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(BottomNavBar), findsOneWidget);
  });

  // ───────── TEST 2 ─────────
  testWidgets('All nav items are displayed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Earth'), findsOneWidget);
    expect(find.text('Asteroids'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  // ───────── TEST 3 ─────────
  testWidgets('Tap changes index', (tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Earth'));
    await tester.pump();

    expect(tappedIndex, 1);
  });
}