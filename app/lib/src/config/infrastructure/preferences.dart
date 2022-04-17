import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/theme_mode.dart';

class PreferencesRepository {
  final SharedPreferences _sharedPrefs;

  static const String saveDirectoryPathKey = 'saveDirectoryPath';

  PreferencesRepository(this._sharedPrefs);

  ThemeMode getThemeMode() {
    switch (_sharedPrefs.getString(ThemeModeNames.themeMode)) {
      case ThemeModeNames.light:
        return ThemeMode.light;
      case ThemeModeNames.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        _sharedPrefs.setString(ThemeModeNames.themeMode, ThemeModeNames.light);
        break;
      case ThemeMode.dark:
        _sharedPrefs.setString(ThemeModeNames.themeMode, ThemeModeNames.dark);
        break;
      case ThemeMode.system:
        _sharedPrefs.setString(ThemeModeNames.themeMode, ThemeModeNames.system);
        break;
    }
  }
}
