import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:tfr_dashboard/src/app/app.dart';
import 'package:tfr_dashboard/src/data/application/app.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

class RegionsDashboard extends StatelessWidget {
  const RegionsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Regiony'),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >=
                CustomTheme.of(context).sizes.widescreenThreshold) {
              return SizedBox(
                height: 290,
                child: Row(
                  children: const [
                    SizedBox(
                      width: 250,
                      child: DashboardRegionSelector(),
                    ),
                    Expanded(
                      child: DashboardTfrChart(),
                    ),
                    SizedBox(
                      width: 300,
                      child: DashboardRegionDetailsCard(),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: const [
                  SizedBox(height: 290, child: DashboardRegionSelector()),
                  SizedBox(height: 290, child: DashboardTfrChart()),
                  SizedBox(height: 290, child: DashboardRegionDetailsCard())
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

class DashboardRegionSelector extends ConsumerWidget {
  const DashboardRegionSelector({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(regionsProvider);
    final selectedRegionId = ref.watch(selectedRegionIdProvider);

    return SelectorCard<Region>(
      items: regions.maybeWhen(
        data: (data) {
          data.sort((a, b) => a.name.compareTo(b.name));
          // Put 'Whole world' and 'European Union' first.
          try {
            final wld = data.singleWhere((region) => region.id == 'wld');
            final euu = data.singleWhere((region) => region.id == 'euu');
            data.removeWhere(
                (region) => region.id == 'wld' || region.id == 'euu');
            data.insertAll(0, [wld, euu]);
            // ignore: empty_catches
          } on StateError {}
          return data;
        },
        orElse: () => [],
      ),
      isSelected: (region) => region.id == selectedRegionId,
      onSelected: (region) => ref
          .read(selectedRegionIdProvider.notifier)
          .update((state) => region.id),
      titleSelector: (region) => region.name,
    );
  }
}

class DashboardTfrChart extends ConsumerWidget {
  const DashboardTfrChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRegion = ref.watch(selectedRegionIdProvider);

    final Widget chart;
    if (selectedRegion != null) {
      final series = ref.watch(timeSeriesProvider(
          TimeSeriesAddress(datasetId: 'tfr', regionId: selectedRegion)));

      chart = series.when(
        data: (data) {
          final sortedValues = data.series.values.toList();
          sortedValues.sort();
          final min = sortedValues.first;
          final max = sortedValues.last;

          return SfCartesianChart(
            tooltipBehavior: TooltipBehavior(
              enable: true,
              decimalPlaces: 3,
              activationMode: ActivationMode.singleTap,
              animationDuration: 0,
              duration: 0,
            ),
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              // Round to nearest tenth and add a padding of one tenth.
              minimum: (min * 10).roundToDouble() / 10 - 0.1,
              maximum: (max * 10).roundToDouble() / 10 + 0.1,
            ),
            series: <LineSeries<MapEntry<String, double>, String>>[
              LineSeries<MapEntry<String, double>, String>(
                name: '',
                dataSource: data.series.entries.toList(),
                xValueMapper: (entry, _) => entry.key,
                yValueMapper: (entry, _) => entry.value,
              ),
            ],
            enableAxisAnimation: true,
          );
        },
        error: (_, __) => Container(),
        loading: () => Container(),
      );
    } else {
      chart = const Center(child: Text('Vyberte region ze seznamu vlevo'));
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: 'Total fertility rate'),
          Expanded(
            child: Padding(
              padding: CustomTheme.of(context).sizes.halfPadding.copyWith(
                    top: 0,
                    right: CustomTheme.of(context).sizes.paddingSize,
                  ),
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardRegionDetailsCard extends ConsumerWidget {
  const DashboardRegionDetailsCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRegion = ref.watch(selectedRegionIdProvider);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: 'Detaily'),
          NumberListTile(
            title: 'aktuální TFR',
            futureProvider: currentTfrInRegionProvider(selectedRegion),
            fractionDigits: 2,
          ),
          NumberListTile(
            title: 'změna za sledované období',
            futureProvider: tfrDifferenceProvider(selectedRegion),
            fractionDigits: 2,
            positiveValueColor: CustomTheme.of(context).colors.okayIconColor,
            negativeValueColor: CustomTheme.of(context).colors.errorIconColor,
          ),
          NumberListTile(
            title: 'korelujících ukazatelů',
            futureProvider: correlationsInRegionCountProvider(selectedRegion),
          ),
          ListTile(
            title: const Text('Zobrazit více'),
            onTap: () {},
            trailing: const Icon(
              Icons.chevron_right,
              // color: Theme.of(context).primaryColor,
            ),
            // textColor: Theme.of(context).primaryColor,
          ),
          // Text(
          //   'Související ukazatele',
          //   style: Theme.of(context).textTheme.headline5,
          // ),
          // SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
          // for (final color in [
          //   Colors.redAccent,
          //   Colors.orangeAccent,
          //   Colors.yellowAccent.shade400,
          // ])
          //   ListTile(
          //     leading: Container(
          //       width: CustomTheme.of(context).sizes.paddingSize,
          //       height: CustomTheme.of(context).sizes.paddingSize,
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: color,
          //       ),
          //     ),
          //     title: const Text('Ukazatel 1'),
          //   ),
          // TextButton(
          //   onPressed: () {},
          //   child: const Text('Zobrazit další'),
          // ),
        ],
      ),
      // ),
    );
  }
}

class NumberListTile extends ConsumerStatefulWidget {
  final String title;
  final FutureProvider futureProvider;
  final int fractionDigits;
  final Color? positiveValueColor;
  final Color? negativeValueColor;

  const NumberListTile({
    Key? key,
    required this.title,
    required this.futureProvider,
    this.fractionDigits = 0,
    this.positiveValueColor,
    this.negativeValueColor,
  }) : super(key: key);

  @override
  ConsumerState<NumberListTile> createState() => _NumberListTileState();
}

class _NumberListTileState extends ConsumerState<NumberListTile> {
  num? lastValue;

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(widget.futureProvider);

    final newValue = asyncValue.when(
        data: ((data) => data), error: (_, __) => null, loading: () => null);
    if (newValue != null) {
      lastValue = newValue;
    }

    TextStyle valueStyle = Theme.of(context)
        .textTheme
        .headline6!
        .copyWith(color: Theme.of(context).primaryColor);
    if (lastValue != null) {
      if (lastValue! > 0 && widget.positiveValueColor != null) {
        valueStyle = valueStyle.copyWith(color: widget.positiveValueColor);
      } else if (lastValue! < 0 && widget.negativeValueColor != null) {
        valueStyle = valueStyle.copyWith(color: widget.negativeValueColor);
      }
    }

    return ListTile(
      title: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: lastValue != null
                ? '${lastValue!.toStringAsFixed(widget.fractionDigits)} '
                : '? ',
            style: valueStyle,
          ),
          TextSpan(
            text: widget.title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ]),
      ),
    );
  }
}
