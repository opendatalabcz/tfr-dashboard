import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/themes.dart';
import 'theme_data_state.dart';

/// Provides theme data based on platform brightness.
/// Could be extended to be based on other platform specific values,
/// such as screen size and requested visual density (providing different
/// CustomThemeData with different CustomSizes).
class ThemeDataNotifier extends StateNotifier<ThemeDataState>
    with WidgetsBindingObserver {
  final ThemeMode _themeMode;

  ThemeDataNotifier._(ThemeDataState themeDataState, this._themeMode)
      : super(themeDataState) {
    _setSystemUIOverlayStyle();
  }

  factory ThemeDataNotifier(ThemeMode themeMode) {
    final brightness = _getBrightness(themeMode);
    final themeData = _getThemeData(brightness);
    final customTheme = _getCustomTheme(brightness);
    return ThemeDataNotifier._(
      ThemeDataState(
        themeData: themeData,
        customTheme: customTheme,
      ),
      themeMode,
    );
  }

  static Brightness _getBrightness(ThemeMode themeMode) {
    Brightness brightness;

    switch (themeMode) {
      case ThemeMode.system:
        //final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
        brightness = WidgetsBinding.instance!.window.platformBrightness;
        break;
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
    }

    return brightness;
  }

  static ThemeData _getThemeData(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }

  /// Get custom theme data depending on current ThemeMode.
  static CustomThemeData _getCustomTheme(Brightness brightness) {
    return brightness == Brightness.light ? customLightTheme : customDarkTheme;
  }

  void _setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: state.themeData.backgroundColor,
      ),
    );
  }

  /// Notifies this notifier that the platform's brightness has changed.
  /// The notifier will provide new theme data.
  void platformBrightnessChanged() {
    final newBrightness = _getBrightness(_themeMode);

    state = state.copyWith(
      themeData: _getThemeData(newBrightness),
      customTheme: _getCustomTheme(newBrightness),
    );

    _setSystemUIOverlayStyle();
  }
}
