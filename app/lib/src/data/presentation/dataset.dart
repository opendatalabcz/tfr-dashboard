import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tfr_dashboard/src/data/application/app.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import '../../app/app.dart';

class DatasetPage extends ConsumerWidget {
  final String datasetId;

  const DatasetPage({
    Key? key,
    required this.datasetId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetAsyncValue = ref.watch(datasetProvider(datasetId));
    final dataSourceAsyncValue =
        ref.watch(dataSourceForDatasetProvider(datasetId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          datasetAsyncValue.maybeWhen(
              data: (data) => data.name, orElse: () => 'Neznámý ukazatel'),
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
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.source),
                    title: Text(
                      dataSourceAsyncValue.maybeWhen(
                          data: (data) => data.name, orElse: () => ''),
                    ),
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
                    leading: const Icon(Icons.numbers),
                    title: Text(datasetAsyncValue.maybeWhen(
                        data: (data) => 'Jednotka: ${data.unit}',
                        orElse: () => 'Jednotka')),
                  ),
                ],
              ),
            ),
            const SectionTitle(title: 'Korelace napříč regiony'),
            InterRegionDetailsCard(datasetId: datasetId),
            const SectionTitle(title: 'Vývoj v jednotlivých regionech'),
            const Expanded(child: SingleRegionDetails()),
            const PageFooter(),
            SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
          ],
        ),
      ),
    );
  }
}

class InterRegionDetailsCard extends ConsumerWidget {
  final String datasetId;

  const InterRegionDetailsCard({
    required this.datasetId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetAsyncValue = ref.watch(datasetProvider(datasetId));

    return datasetAsyncValue.when(
      data: (data) => Card(
        // child: Padding(
        // padding: CustomTheme.of(context).sizes.tilePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: CustomTheme.of(context).sizes.tilePadding,
              child: InterRegionCorrelationChart(dataset: data),
            ),
            SizedBox(height: CustomTheme.of(context).sizes.paddingSize),
            const CardTitle(title: 'Jak graf číst?'),
            Padding(
              padding:
                  CustomTheme.of(context).sizes.tilePadding.copyWith(top: 0),
              child: Text(
                'Graf popisuje vztah mezi hodnotami ukazatele a hodnotami TFR v každém roce napříč regiony. Korelace byla nalezena v těch časových úsecích, kde je plocha grafu podbarvená. Není-li graf podbarvený nikde, korelace ukazatele a TFR napříč regiony nalezena nebyla.',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: CustomTheme.of(context)
                  .sizes
                  .tilePadding
                  .copyWith(top: 0, bottom: 0),
              child: Text(
                'Pokud je hodnota korelačního koeficientu kladná, pak platí, že v regionech, kde má ukazatel vysokou hodnotu, je vysoké i TFR (pozitivní korelace). Je-li ale korelační koeficient záporný, pak v regionech, kde má ukazatel vysokou hodnotu, je naopak TFR nízké (negativní korelace).',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: CustomTheme.of(context).sizes.halfPadding,
              child: TextButton(
                child: const Text('Jak se korelace počítá?'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const TextDialog(
                      'Pro oveření korelace se používá jednak pearsonův korelační koeficient, jednak p hodnota statistického testu nenulovosti sklonu regresní přímky. Korelace platí, pokud je korelační koeficient dostatečně daleko od nuly (v absolutní hodnotě alespoň 0,4) a zároveň je p hodnota testu nižší než 0,05 (zamítáme na 95% hladině hypotézu, že regresní přímka má nulový sklon).',
                      title: 'Metoda výpočtu korelace',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // ),
      ),
      error: (_, __) => Card(
        child: Padding(
          padding: CustomTheme.of(context).sizes.tilePadding,
          child: const Center(
            child: Text('Data nejsou dostupná'),
          ),
        ),
      ),
      loading: () => Card(
        child: Padding(
          padding: CustomTheme.of(context).sizes.tilePadding,
        ),
      ),
    );
  }
}

class InterRegionCorrelationChart extends StatelessWidget {
  final Dataset dataset;

  const InterRegionCorrelationChart({
    Key? key,
    required this.dataset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
        enable: true,
        decimalPlaces: 3,
        activationMode: ActivationMode.singleTap,
        animationDuration: 0,
        duration: 0,
      ),
      legend: Legend(
        isVisible: true,
      ),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        // Round to nearest tenth and add a padding of one tenth.
        minimum: -1,
        maximum: 1,
        // numberFormat: NumberFormat.compact(locale: 'cs_CZ'),
      ),
      // isTransposed: true,
      series:
          // <LineSeries<MapEntry<String, double>, String>>
          <ChartSeries<dynamic, dynamic>>[
        AreaSeries<MapEntry<String, bool>, String>(
          name: 'ukazatel koreluje',
          legendIconType: LegendIconType.rectangle,
          dataSource: dataset.correlationValuesPerYear.entries
              // .map((e) => MapEntry(e.key, e.value ? 1.0 : 0.0))
              .toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value ? 1.0 : null,
          animationDelay: 0,
          animationDuration: 0,
          color: Theme.of(context).primaryColor,
          opacity: 0.2,
          enableTooltip: false,
        ),
        AreaSeries<MapEntry<String, bool>, String>(
          isVisibleInLegend: false,
          enableTooltip: false,
          dataSource: dataset.correlationValuesPerYear.entries
              // .map((e) => MapEntry(e.key, e.value ? 1.0 : 0.0))
              .toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value ? -1.0 : null,
          animationDelay: 0,
          animationDuration: 0,
          color: Theme.of(context).primaryColor,
          opacity: 0.2,
        ),
        LineSeries<MapEntry<String, double>, String>(
          name: 'p hodnota',
          dataSource: dataset.pValuesPerYear.entries.toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value,
          animationDelay: 0,
          animationDuration: 0,
          color: Colors.redAccent,
        ),
        LineSeries<MapEntry<String, double>, String>(
          name: 'korelační koeficient',
          dataSource: dataset.rValuesPerYear.entries.toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value,
          animationDelay: 0,
          animationDuration: 0,
          color: Colors.orangeAccent,
        ),
      ],
      enableAxisAnimation: false,
    );
  }
}

class SingleRegionDetails extends ConsumerWidget {
  const SingleRegionDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionsAsyncValue = ref.watch(regionsForSelectedDatasetProvider);
    final selectedRegionId = ref.watch(selectedRegionIdProvider);

    return LayoutBuilder(builder: ((context, constraints) {
      final datasetSelector = SelectorCard<Region>(
        isScrollable: false,
        items: regionsAsyncValue.maybeWhen(
          data: (data) => sortedRegions(data),
          orElse: () => [],
        ),
        isSelected: (dataset) => dataset.id == selectedRegionId,
        onSelected: (dataset) => ref
            .read(selectedRegionIdProvider.notifier)
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
            const Expanded(child: TimeSeriesCard())
          ],
        );
      } else {
        return Column(
          children: [
            datasetSelector,
            const TimeSeriesCard(),
          ],
        );
      }
    }));
  }
}

class TimeSeriesCard extends StatelessWidget {
  const TimeSeriesCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CardTitle(title: 'Vývoj v čase spolu s TFR'),
          CardTitle(title: 'Korelace s TFR'),
        ],
      ),
    );
  }
}
