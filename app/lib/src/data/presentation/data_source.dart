import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tfr_dashboard/src/app/presentation/common.dart';
import 'package:tfr_dashboard/src/data/application/api.dart';
import 'package:tfr_dashboard/src/data/application/app.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import '../domain/data.dart';

class DataSourcePage extends ConsumerWidget {
  final String dataSourceId;

  const DataSourcePage({
    Key? key,
    required this.dataSourceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSourceAsyncValue = ref.watch(dataSourceProvider(dataSourceId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          dataSourceAsyncValue.maybeWhen(
              data: (data) => data.name, orElse: () => 'Datový zdroj'),
        ),
      ),
      body: Padding(
        padding: CustomTheme.of(context).sizes.halfPadding.copyWith(
              top: 0,
              bottom: 0,
            ),
        child: ListView(
          children: [
            SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
            DataSourceDetailsCard(dataSourceId: dataSourceId),
            const SectionTitle(title: 'Ukazatele'),
            Datasets(dataSourceId: dataSourceId),
            const PageFooter(),
            SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
          ],
        ),
      ),
    );
  }
}

class DataSourceDetailsCard extends ConsumerWidget {
  final String dataSourceId;

  const DataSourceDetailsCard({
    Key? key,
    required this.dataSourceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSourceAsyncValue = ref.watch(dataSourceProvider(dataSourceId));

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(
              dataSourceAsyncValue.maybeWhen(
                data: (data) => data.description,
                orElse: () => '',
              ),
            ),
          ),
          dataSourceAsyncValue.maybeWhen(
            data: (data) => ListTile(
              leading: const Icon(Icons.link),
              title: Text(
                data.url,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                launch(data.url);
              },
            ),
            orElse: () => const ListTile(
              leading: Icon(Icons.link),
            ),
          ),
        ],
      ),
    );
  }
}

class Datasets extends ConsumerWidget {
  final String dataSourceId;

  const Datasets({
    Key? key,
    required this.dataSourceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetsAsyncValue =
        ref.watch(datasetsInDataSourceProvider(dataSourceId));
    final selectedDatasetId = ref.watch(selectedDatasetIdProvider);

    return LayoutBuilder(builder: ((context, constraints) {
      final datasetSelector = SelectorCard<Dataset>(
        isScrollable: false,
        items: datasetsAsyncValue.maybeWhen(
          data: (data) {
            data.sort((a, b) => a.name.compareTo(b.name));
            return data;
          },
          orElse: () => [],
        ),
        isSelected: (dataset) => dataset.id == selectedDatasetId,
        onSelected: (dataset) => ref
            .read(selectedDatasetIdProvider.notifier)
            .update((state) => dataset.id),
        titleSelector: (dataset) => dataset.name,
      );

      if (constraints.maxWidth >=
          CustomTheme.of(context).sizes.widescreenThreshold) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: min(constraints.maxWidth / 3, 400.0),
                child: datasetSelector),
            if (selectedDatasetId != null)
              Expanded(
                child: DatasetCard(
                  datasetId: selectedDatasetId,
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: CustomTheme.of(context).sizes.padding,
                  child: const Center(
                    child: Text('Vyberte ukazatel ze seznamu'),
                  ),
                ),
              ),
          ],
        );
      } else {
        return Column(
          children: [
            datasetSelector,
            if (selectedDatasetId != null)
              DatasetCard(
                datasetId: selectedDatasetId,
              )
            else
              Padding(
                padding: CustomTheme.of(context).sizes.padding,
                child: const Center(
                  child: Text('Vyberte ukazatel ze seznamu'),
                ),
              ),
          ],
        );
      }
    }));
  }
}

final selectedRegionNameProvider = FutureProvider((ref) async {
  final regionId = ref.watch(selectedRegionIdProvider);
  return await ref.watch(regionProvider(regionId).future);
});

final timeSeriesForSelectedRegionProvider =
    FutureProvider.family((ref, String datasetId) async {
  final regionId = ref.watch(selectedRegionIdProvider);
  return await ref.watch(timeSeriesProvider(
    TimeSeriesAddress(
      datasetId: datasetId,
      regionId: regionId,
    ),
  ).future);
});

class DatasetCard extends ConsumerWidget {
  final String datasetId;

  const DatasetCard({
    Key? key,
    required this.datasetId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetAsyncValue = ref.watch(datasetProvider(datasetId));
    final timeSeriesCountAsyncValue =
        ref.watch(timeSeriesInDatsetCountProvider(datasetId));
    final selectedRegionAsyncValue = ref.watch(selectedRegionNameProvider);

    final timeSeriesAsyncValue =
        ref.watch(timeSeriesForSelectedRegionProvider(datasetId));

    return Card(
      child: Column(
        children: [
          CardTitle(
            title: datasetAsyncValue.maybeWhen(
                data: (data) => data.name, orElse: () => ''),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(
              datasetAsyncValue.maybeWhen(
                  data: (data) => data.description, orElse: () => ''),
            ),
          ),
          datasetAsyncValue.maybeWhen(
            data: (data) => ListTile(
              leading: const Icon(Icons.link),
              title: Text(
                data.url,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                launch(data.url);
              },
            ),
            orElse: () => const ListTile(
              leading: Icon(Icons.link),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.insights),
            title: Text(timeSeriesCountAsyncValue.maybeWhen(
              data: (data) => 'Dostupné časové řady pro $data států',
              orElse: () => 'Jednotka',
            )),
          ),
          ListTile(
            leading: const Icon(Icons.numbers),
            title: Text(datasetAsyncValue.maybeWhen(
                data: (data) => 'Jednotka: ${data.unit}',
                orElse: () => 'Jednotka')),
          ),
          ListTile(
            leading: const Icon(Icons.poll),
            title: const Text('Vývoj ve zvoleném státě'),
            subtitle: selectedRegionAsyncValue.maybeWhen(
                data: (data) => Text(data.name), orElse: () => null),
          ),
          SizedBox(
            height: 300.0,
            child: Padding(
              padding: CustomTheme.of(context).sizes.padding,
              child: timeSeriesAsyncValue.when(
                data: (data) {
                  final sortedValues = data.series.values.toList();
                  sortedValues.sort();
                  final min = sortedValues.first;
                  final max = sortedValues.last;
                  final padding = ((max - min) / 20).roundToDouble();

                  return SfCartesianChart(
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
                      minimum: min.floorToDouble() - padding,
                      maximum: max.ceilToDouble() + padding,
                      numberFormat: NumberFormat.compact(locale: 'cs_CZ'),
                    ),
                    series: <LineSeries<MapEntry<String, num>, String>>[
                      LineSeries<MapEntry<String, num>, String>(
                        name: '',
                        dataSource: data.series.entries.toList(),
                        xValueMapper: (entry, _) => entry.key,
                        yValueMapper: (entry, _) => entry.value,
                        animationDelay: 0,
                        animationDuration: 0,
                        color: CustomTheme.of(context).colors.otherSeriesColor,
                      ),
                    ],
                    enableAxisAnimation: false,
                  );
                },
                error: (_, __) => const Center(
                  child: Text('Vývoj pro zvolený stát není dostupný'),
                ),
                loading: () => Container(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Zobrazit detaily a ostatní státy'),
            onTap: () {
              Navigator.pushNamed(context, '/dataset/$datasetId');
            },
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
