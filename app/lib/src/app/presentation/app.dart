import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import 'home.dart';

class TfrApp extends ConsumerWidget {
  const TfrApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeDataProvider);

    return CustomThemeProvider(
      child: MaterialApp(
        theme: themeData,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
