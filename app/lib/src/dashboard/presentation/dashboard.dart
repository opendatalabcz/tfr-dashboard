import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tfr_dashboard/src/config/config.dart';
import 'package:tfr_dashboard/src/dashboard/presentation/data_sources.dart';
import 'package:tfr_dashboard/src/dashboard/presentation/regions.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import 'numbers_strip.dart';

class Dashboard extends ConsumerWidget {
  static const String route = '/';

  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TFR Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(PreferencesPage.route());
            },
          ),
        ],
      ),
      body: Padding(
        padding: CustomTheme.of(context).sizes.halfPadding.copyWith(
              top: 0,
              bottom: 0,
            ),
        child: ListView(
          children: [
            Padding(
              padding: CustomTheme.of(context).sizes.halfPadding.copyWith(
                    top: 0,
                  ),
              child: Row(
                children: [
                  Text(
                    'Vývoj demografického ukazatele plodnosti  — ',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  TextButton(
                    child: Text(
                      'Co je TFR?',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context, builder: (_) => const TfrDialog());
                    },
                  ),
                ],
              ),
            ),
            const NumbersStrip(),
            const RegionsDashboard(),
            const DataSources(),
            SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
          ],
        ),
      ),
    );
  }
}

class TfrDialog extends StatelessWidget {
  const TfrDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Total fertility rate'),
      content: const SizedBox(
        width: 500.0,
        child: Text(
            'Total fertility rate (TFR) či česky úhrnná plodnost je demografický ukazatel popisujı́cı́ počet dětı́, které by se ve sledované společnosti mohly narodit jedné ženě. Aby se počet obyvatel dlouhodobě udržel na stejné hodnotě, TFR by mělo dosahovat hodnoty odhadované pro rozvinuté země na 2,1.'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zavřít'),
        ),
      ],
      // contentPadding: EdgeInsets.all(24),
    );
  }
}
