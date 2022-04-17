import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_theme.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: customLightColors.primaryColor,
  toggleableActiveColor: customLightColors.primaryColor,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: customLightColors.primarySwatch,
    accentColor: customLightColors.accentColor,
    backgroundColor: customLightColors.backgroundColor,
    brightness: Brightness.light,
    cardColor: cardTheme.color,
    errorColor: customLightColors.errorIconColor,
  ),
  cardColor: customLightColors.containerColor,
  canvasColor: customLightColors.containerColor,
  scaffoldBackgroundColor: customLightColors.backgroundColor,
  iconTheme: IconThemeData(
    color: customLightColors.accentColor,
  ),
  appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      color: Colors.transparent,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: Colors.grey[700])),
  cardTheme: cardTheme,
);
