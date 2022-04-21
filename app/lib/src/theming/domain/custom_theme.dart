import 'package:flutter/material.dart';

class CustomSizes {
  // Spacing.
  final double paddingSize;
  final EdgeInsets padding;
  final double halfPaddingSize;
  final EdgeInsets halfPadding;

  /// Tiles.
  final Radius tileRadius;
  final BorderRadius tileBorderRadius;
  final EdgeInsets tilePadding;

  // Responsiveness.

  /// Minimum screen width to display widescreen layout.
  /// May not apply when a mobile device is in landscape mode.
  final double widescreenThreshold;

  const CustomSizes({
    required this.paddingSize,
    required this.padding,
    required this.halfPaddingSize,
    required this.halfPadding,
    required this.tileRadius,
    required this.tileBorderRadius,
    required this.tilePadding,
    required this.widescreenThreshold,
  });
}

class CustomColors {
  // General.
  final MaterialColor primarySwatch;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color containerColor;

  // State icons.
  final Color activeIconColor; // an open gate, a light turned on
  final Color processingIconColor; // a moving gate
  final Color inactiveIconColor; // e. g. a closed gate or a light turned off
  final Color okayIconColor;
  final Color errorIconColor;
  final Color unknownIconColor;

  const CustomColors({
    required this.primarySwatch,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.containerColor,
    required this.activeIconColor,
    required this.processingIconColor,
    required this.inactiveIconColor,
    required this.okayIconColor,
    required this.errorIconColor,
    required this.unknownIconColor,
  });
}

class CustomThemeData {
  final CustomSizes sizes;
  final CustomColors colors;

  const CustomThemeData({
    required this.sizes,
    required this.colors,
  });
}

const customSizes = CustomSizes(
  paddingSize: 16.0,
  padding: EdgeInsets.all(16.0),
  halfPaddingSize: 8.0,
  halfPadding: EdgeInsets.all(8.0),
  tileRadius: Radius.circular(12.0),
  tileBorderRadius: BorderRadius.all(Radius.circular(12.0)),
  tilePadding: EdgeInsets.all(16.0),
  widescreenThreshold: 800.0,
);

final customLightColors = CustomColors(
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue.shade700,
  accentColor: Colors.blueAccent,
  backgroundColor: Colors.grey.shade200,
  containerColor: Colors.white,
  activeIconColor: Colors.blue,
  processingIconColor: Colors.orange,
  inactiveIconColor: Colors.black,
  okayIconColor: Colors.green,
  errorIconColor: Colors.redAccent,
  unknownIconColor: Colors.grey,
);

final customDarkColors = CustomColors(
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue.shade400,
  accentColor: Colors.orange,
  backgroundColor: Colors.black,
  containerColor: Colors.grey.shade800,
  activeIconColor: Colors.blue,
  processingIconColor: Colors.orange,
  inactiveIconColor: Colors.grey.shade200,
  okayIconColor: Colors.green,
  errorIconColor: Colors.redAccent,
  unknownIconColor: Colors.grey,
);

final customLightTheme = CustomThemeData(
  sizes: customSizes,
  colors: customLightColors,
);

final customDarkTheme = CustomThemeData(
  sizes: customSizes,
  colors: customDarkColors,
);

const cardTheme = CardTheme(
  color: Colors.white,
  elevation: 0,
  margin: EdgeInsets.all(8.0),
);
