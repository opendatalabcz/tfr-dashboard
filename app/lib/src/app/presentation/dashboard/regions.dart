import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:tfr_dashboard/src/app/app.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

class RegionsDashboard extends StatelessWidget {
  const RegionsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Vývoj podle státu'),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >=
                CustomTheme.of(context).sizes.widescreenThreshold) {
              return SizedBox(
                height: 317,
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
                  SizedBox(height: 300, child: DashboardTfrChart()),
                  SizedBox(height: 317, child: DashboardRegionDetailsCard())
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
        data: (data) => sortedRegions(data),
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

class DashboardTfrChart extends ConsumerStatefulWidget {
  const DashboardTfrChart({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardTfrChart> createState() => _DashboardTfrChartState();
}

class _DashboardTfrChartState extends ConsumerState<DashboardTfrChart> {
  TimeSeries? lastTfrValue;
  TimeSeries? lastTfrForecastValue;

  @override
  Widget build(BuildContext context) {
    final tfrAsyncValue = ref.watch(tfrForSelectedRegionProvider);
    final tfrForecastAsyncValue =
        ref.watch(tfrForecastForSelectedRegionProvider);

    final newTfrValue = tfrAsyncValue.when(
        data: ((data) => data), error: (_, __) => null, loading: () => null);
    if (newTfrValue != null) {
      lastTfrValue = newTfrValue;
    }

    final newTfrForecastValue = tfrForecastAsyncValue.when(
        data: ((data) => data), error: (_, __) => null, loading: () => null);
    if (newTfrForecastValue != null) {
      lastTfrForecastValue = newTfrForecastValue;
    }

    final Widget chart;
    if (lastTfrValue != null && lastTfrForecastValue != null) {
      final sortedTfrValues = lastTfrValue!.series.values.toList();
      sortedTfrValues.sort();
      num minValue = sortedTfrValues.first;
      num maxValue = sortedTfrValues.last;

      final sortedTfrForecastValues =
          lastTfrForecastValue!.series.values.toList();
      sortedTfrForecastValues.sort();
      minValue = min(minValue, sortedTfrForecastValues.first);
      maxValue = max(maxValue, sortedTfrForecastValues.last);

      final tfrConnectedList = lastTfrValue!.series.entries.toList();
      tfrConnectedList.add(lastTfrForecastValue!.series.entries.first);

      chart = SfCartesianChart(
        tooltipBehavior: TooltipBehavior(
          enable: true,
          decimalPlaces: 2,
          activationMode: ActivationMode.singleTap,
          animationDuration: 0,
          duration: 0,
        ),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          // Round to nearest tenth and add a padding of one tenth.
          minimum: (minValue * 10).roundToDouble() / 10 - 0.1,
          maximum: (maxValue * 10).roundToDouble() / 10 + 0.1,
        ),
        series: <LineSeries<MapEntry<String, num>, String>>[
          LineSeries<MapEntry<String, num>, String>(
            name: 'Minulá hodnota',
            dataSource: tfrConnectedList,
            xValueMapper: (entry, _) => entry.key,
            yValueMapper: (entry, _) => entry.value,
            color: CustomTheme.of(context).colors.tfrColor,
          ),
          LineSeries<MapEntry<String, num>, String>(
            name: 'Předpověď',
            dataSource: lastTfrForecastValue!.series.entries.toList(),
            xValueMapper: (entry, _) => entry.key,
            yValueMapper: (entry, _) => entry.value,
            color: CustomTheme.of(context).colors.otherSeriesColor,
          ),
        ],
        enableAxisAnimation: true,
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
            title: 'změna za minulé období',
            futureProvider: tfrDifferenceProvider(selectedRegion),
            fractionDigits: 2,
            positiveValueColor: CustomTheme.of(context).colors.okayIconColor,
            negativeValueColor: CustomTheme.of(context).colors.errorIconColor,
          ),
          NumberListTile(
            title: 'předpokládaná změna',
            futureProvider: tfrForecastDifferenceProvider(selectedRegion),
            fractionDigits: 2,
            positiveValueColor: CustomTheme.of(context).colors.okayIconColor,
            negativeValueColor: CustomTheme.of(context).colors.errorIconColor,
          ),
          NumberListTile(
            title: 'korelujících ukazatelů',
            futureProvider: correlationsInRegionCountProvider(selectedRegion),
          ),
          ListTile(
            title: const Text('Zobrazit ukazatele'),
            onTap: () {
              Navigator.of(context).pushNamed('/region/$selectedRegion');
            },
            trailing: const Icon(
              Icons.chevron_right,
            ),
          ),
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
