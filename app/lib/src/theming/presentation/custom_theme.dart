import 'package:flutter/material.dart';

import '../domain/themes.dart';

class CustomTheme extends InheritedWidget {
  final CustomThemeData customTheme;

  const CustomTheme({
    Key? key,
    required Widget child,
    required this.customTheme,
  }) : super(key: key, child: child);

  /// Depend on the nearest CustomTheme ancestor,
  /// obtaining the current CustomThemeData or a default value if no ancestor
  /// is present.
  static CustomThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CustomTheme>()?.customTheme ??
      customLightTheme;

  @override
  bool updateShouldNotify(covariant CustomTheme oldWidget) {
    return oldWidget.customTheme != customTheme;
  }
}
