import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_theme.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: customDarkColors.primaryColor,
  toggleableActiveColor: customDarkColors.primaryColor,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: customDarkColors.primarySwatch,
    accentColor: customDarkColors.accentColor,
    backgroundColor: customDarkColors.backgroundColor,
    brightness: Brightness.dark,
    cardColor: cardTheme.color,
    errorColor: customDarkColors.errorIconColor,
  ),
  cardColor: customDarkColors.containerColor,
  canvasColor: customDarkColors.containerColor,
  backgroundColor: customDarkColors.backgroundColor,
  scaffoldBackgroundColor: customDarkColors.backgroundColor,
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    color: Colors.transparent,
    elevation: 2.0,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    iconTheme: IconThemeData(color: Colors.grey.shade200),
  ),
  cardTheme: cardTheme.copyWith(color: Colors.grey.shade800),
);
