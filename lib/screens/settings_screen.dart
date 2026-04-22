import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/theme.dart';
import '../widgets/space_background.dart';
import '../main_scaffold.dart';

import '../services/starred_service.dart';
import '../services/reminder_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Settings')),
      body: SpaceBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Appearance'),

            // DARK MODE TOGGLE
            _glassTile(
              title: 'Dark Mode',
              subtitle: AppTheme.isDarkMode ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: AppTheme.isDarkMode,
                onChanged: (_) {
                  HapticFeedback.selectionClick();

                  AppTheme.toggleTheme();

                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const MainScaffold(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            _section('Data'),

            _glassTile(
              title: 'Clear Starred Items',
              subtitle: 'Remove all saved favourites',
              trailing: const Icon(Icons.star_border),
              onTap: _confirmClearStarred,
            ),

            _glassTile(
              title: 'Clear Reminders',
              subtitle: 'Remove all asteroid reminders',
              trailing: const Icon(Icons.notifications_none),
              onTap: _confirmClearReminders,
            ),

            const SizedBox(height: 24),

            _section('About'),

            _glassTile(
              title: 'SpaceScope',
              subtitle: 'Version 1.0.0',
              trailing: const Icon(Icons.info_outline),
            ),

            _glassTile(
              title: 'Data Source',
              subtitle: 'NASA Open APIs',
              trailing: const Icon(Icons.public),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── Section Title ─────────

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white70,
        ),
      ),
    );
  }

  // ───────── Glass Tile ─────────

  Widget _glassTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // ───────── Clear Starred  ─────────

  Future<void> _confirmClearStarred() async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Clear starred items?'),
            content: const Text('This will remove all your saved favourites.'),
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
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;

    if (ok) {
      await StarredService().clearAll();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Starred items cleared'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    }
  }

  // ───────── Clear Reminders  ─────────

  Future<void> _confirmClearReminders() async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Clear reminders?'),
            content: const Text('This will remove all asteroid reminders.'),
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
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;

    if (ok) {
      await ReminderService().clearAll();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reminders cleared'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    }
  }
}
