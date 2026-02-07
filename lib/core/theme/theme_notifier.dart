import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

part 'theme_notifier.g.dart';

/// Theme Mode Options
enum ThemeModeOption {
  system,
  light,
  dark;

  /// Convert to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  /// Get display name
  String get displayName {
    switch (this) {
      case ThemeModeOption.light:
        return 'Light';
      case ThemeModeOption.dark:
        return 'Dark';
      case ThemeModeOption.system:
        return 'System';
    }
  }

  /// Get icon
  IconData get icon {
    switch (this) {
      case ThemeModeOption.light:
        return Icons.light_mode;
      case ThemeModeOption.dark:
        return Icons.dark_mode;
      case ThemeModeOption.system:
        return Icons.brightness_auto;
    }
  }
}

/// Theme Notifier - Manages theme switching
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _storageKey = StorageKeys.themeMode;

  @override
  ThemeModeOption build() {
    _loadThemeMode();
    return ThemeModeOption.light; // Default to light for now
  }

  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_storageKey);

      if (savedTheme != null) {
        state = ThemeModeOption.values.firstWhere(
          (e) => e.name == savedTheme,
          orElse: () => ThemeModeOption.light,
        );
      }
    } catch (e) {
      state = ThemeModeOption.light;
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeModeOption mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, mode.name);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    final newMode = state == ThemeModeOption.light
        ? ThemeModeOption.dark
        : ThemeModeOption.light;
    await setThemeMode(newMode);
  }
}
