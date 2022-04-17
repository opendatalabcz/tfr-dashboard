import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../../config/config.dart';

import 'theme_data.dart';
import 'theme_data_state.dart';
import '../domain/themes.dart';

/// Provides ThemeData and handles setting the system UI colors such as the
/// navigation bar color on theme change.
final themeProvider =
    StateNotifierProvider<ThemeDataNotifier, ThemeDataState>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  return ThemeDataNotifier(themeMode);
});

final themeDataProvider =
    Provider<ThemeData>((ref) => ref.watch(themeProvider).themeData);
final customThemeDataProvider =
    Provider<CustomThemeData>((ref) => ref.watch(themeProvider).customTheme);
