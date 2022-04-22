import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import 'dashboard/dashboard.dart';

class TfrApp extends ConsumerWidget {
  const TfrApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeDataProvider);

    return CustomThemeProvider(
      child: MaterialApp(
        title: 'TFR Dashboard',
        theme: themeData,
        initialRoute: Dashboard.route,
        routes: {
          Dashboard.route: (_) => const Dashboard(),
        },
        onGenerateRoute: (settings) {
          final home =
              MaterialPageRoute(builder: ((context) => const Dashboard()));

          // Go home if route unknown.
          if (settings.name == null) {
            return home;
          }

          // Handle two-level parameterized routes.
          final uri = Uri.parse(settings.name!);
          if (uri.pathSegments.length != 2) {
            return home;
          }
          switch (uri.pathSegments[0]) {
            case 'data-source':
              return MaterialPageRoute(
                builder: ((context) => DataSourcePage(
                      dataSourceId: uri.pathSegments[1],
                    )),
              );
            case 'dataset':
              return MaterialPageRoute(
                builder: ((context) => DatasetPage(
                      datasetId: uri.pathSegments[1],
                    )),
              );
            default:
              return home;
          }
        },
        // home: const Dashboard(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
