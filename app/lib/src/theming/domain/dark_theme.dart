import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_theme.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: customDarkColors.primarySwatch,
  primaryColor: customDarkColors.primaryColor,
  toggleableActiveColor: customDarkColors.primaryColor,
  accentColor: customDarkColors.accentColor,
  cardColor: customDarkColors.containerColor,
  canvasColor: customDarkColors.containerColor,
  backgroundColor: customDarkColors.backgroundColor,
  scaffoldBackgroundColor: customDarkColors.backgroundColor,
  appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      color: Colors.transparent,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      iconTheme: IconThemeData(color: Colors.grey[200])),
  cardTheme: cardTheme.copyWith(color: Colors.grey.shade800),
);