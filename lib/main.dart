import 'package:flutter/material.dart';

import 'screens/home_screen.dart';


void main() {
  runApp(const SpaceScopeApp());
}

class SpaceScopeApp extends StatefulWidget {
  const SpaceScopeApp({super.key});

  @override
  State<SpaceScopeApp> createState() => _SpaceScopeAppState();
}

class _SpaceScopeAppState extends State<SpaceScopeApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}