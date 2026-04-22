import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

class SpaceBackground extends StatelessWidget {
  final Widget child;

  const SpaceBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(AppTheme.isDarkMode),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            AppTheme.backgroundImage,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),

          //  Dark overlay
          Container(color: Colors.black.withOpacity(0.45)),

          child,
        ],
      ),
    );
  }
}
