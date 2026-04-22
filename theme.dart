import 'package:flutter/material.dart';

class AppTheme {
  static bool isDarkMode = false;

  // Background images
  static String get backgroundImage => isDarkMode
      ? 'assets/images/background_2.jpg' // dark
      : 'assets/images/background.jpg';  // light

  static Color get cardColor =>
      isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

  static Color get textColor =>
      isDarkMode ? Colors.white : Colors.black87;

  static Color get subtitleColor =>
      isDarkMode ? Colors.white70 : Colors.black54;

  
  static void toggleTheme() {
    isDarkMode = !isDarkMode;
  }
}