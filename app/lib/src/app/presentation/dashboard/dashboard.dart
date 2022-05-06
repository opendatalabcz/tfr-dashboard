import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/app/presentation/common.dart';

import 'package:tfr_dashboard/src/config/config.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import 'data_sources.dart';
import 'numbers_strip.dart';
import 'regions.dart';

class Dashboard extends ConsumerWidget {
  static const String route = '/';

  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isApiAvailable = ref.watch(apiAvailableProvider);

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
          const SizedBox(width: 8.0),
        ],
      ),
      body: isApiAvailable.maybeWhen(
          data: (data) {
            if (data) {
              return _body(context);
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: CustomTheme.of(context).colors.errorIconColor,
                      size: 48.0,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Aplikace není dostupná',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(height: 8.0),
                    const Text('API server není dosažitelný'),
                  ],
                ),
              );
            }
          },
          orElse: () => _body(context)),
    );
  }

  Padding _body(BuildContext context) {
    return Padding(
      padding: CustomTheme.of(context).sizes.halfPadding.copyWith(
            top: 0,
            bottom: 0,
          ),
      child: ListView(
        children: [
          SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
          Padding(
            padding: CustomTheme.of(context).sizes.halfPadding,
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.subtitle1,
                children: [
                  const TextSpan(
                      text: 'Vývoj demografického ukazatele plodnosti — '),
                  TextSpan(
                    text: 'Co je TFR?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        showDialog(
                          context: context,
                          builder: (_) => const TextDialog(
                            'Total fertility rate (TFR) či česky úhrnná plodnost je demografický ukazatel popisujı́cı́ počet dětı́, které by se ve sledované společnosti mohly narodit jedné ženě. Aby se počet obyvatel dlouhodobě udržel na stejné hodnotě, TFR by mělo dosahovat hodnoty odhadované pro rozvinuté země na 2,1.',
                            title: 'Total fertility rate',
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
          const NumbersStrip(),
          const RegionsDashboard(),
          const DataSources(),
          const PageFooter(),
          SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
        ],
      ),
    );
  }
}
