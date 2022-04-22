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
    color: Colors.grey.shade300,
    elevation: 2.0,
    titleTextStyle: TextStyle(
      color: Colors.grey.shade800,
      fontSize: 32,
      fontWeight: FontWeight.w500,
    ),
    iconTheme: IconThemeData(color: Colors.grey.shade700),
  ),
  cardTheme: cardTheme,
);
