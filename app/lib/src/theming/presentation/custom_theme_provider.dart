import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';
import 'custom_theme.dart';

/// Provides a [CustomTheme] [InheritedWidget] down the tree, allowing its
/// children to obtain [CustomThemeData].
///
/// Does not provide the standard [ThemeData]. Those are provided via the
/// [themeDataProvider].
class CustomThemeProvider extends ConsumerStatefulWidget {
  final Widget child;

  const CustomThemeProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _CustomThemeProviderState createState() => _CustomThemeProviderState();
}

class _CustomThemeProviderState extends ConsumerState<CustomThemeProvider>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    ref.read(themeProvider.notifier).platformBrightnessChanged();

    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = ref.watch(customThemeDataProvider);

    return CustomTheme(
      customTheme: customTheme,
      child: widget.child,
    );
  }
}
