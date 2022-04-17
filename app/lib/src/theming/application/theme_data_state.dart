import 'package:flutter/material.dart';

import '../domain/custom_theme.dart';

class ThemeDataState {
  final ThemeData themeData;
  final CustomThemeData customTheme;

  const ThemeDataState({
    required this.themeData,
    required this.customTheme,
  });

  ThemeDataState copyWith({
    ThemeData? themeData,
    CustomThemeData? customTheme,
  }) {
    return ThemeDataState(
      themeData: themeData ?? this.themeData,
      customTheme: customTheme ?? this.customTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeDataState &&
        other.themeData == themeData &&
        other.customTheme == customTheme;
  }

  @override
  int get hashCode => themeData.hashCode ^ customTheme.hashCode;
}
