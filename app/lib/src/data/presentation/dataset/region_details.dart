import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/app/app.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import '../../data.dart';
import '../../infrastructure/api.dart';
import 'charts.dart';

class RegionDetails extends ConsumerWidget {
  final String datasetId;
  final AutoDisposeFutureProviderFamily<List<Region>, String> regionsProvider;
  final StateProvider<String?> selectedRegionIdProviderOverride;

  const RegionDetails({
    Key? key,
    required this.datasetId,
    required this.regionsProvider,
    required this.selectedRegionIdProviderOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionsAsyncValue = ref.watch(regionsProvider(datasetId));
    final selectedRegionId = ref.watch(selectedRegionIdProviderOverride);

    return LayoutBuilder(builder: ((context, constraints) {
      final datasetSelector = SelectorCard<Region>(
        isScrollable: false,
        items: regionsAsyncValue.maybeWhen(
          data: (data) => sortedRegions(data),
          orElse: () => [],
        ),
        isSelected: (dataset) => dataset.id == selectedRegionId,
        onSelected: (dataset) => ref
            .read(selectedRegionIdProviderOverride.notifier)
            .update((state) => dataset.id),
        titleSelector: (dataset) => dataset.name,
      );
      final address =
          TimeSeriesAddress(datasetId: datasetId, regionId: selectedRegionId);

      if (constraints.maxWidth >=
          CustomTheme.of(context).sizes.widescreenThreshold) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: min(constraints.maxWidth / 4, 400.0),
                child: datasetSelector),
            Expanded(child: TimeSeriesCard(address: address))
          ],
        );
      } else {
        return Column(
          children: [
            datasetSelector,
            TimeSeriesCard(address: address),
          ],
        );
      }
    }));
  }
}

class _TimeSeriesWithTfr {
  final TimeSeries series;
  final TimeSeries tfr;

  const _TimeSeriesWithTfr(this.series, this.tfr);
}

final timeSeriesWithTfrProvider =
    FutureProvider.family((ref, TimeSeriesAddress address) async {
  final series = await ref.watch(timeSeriesProvider(address).future);
  final tfr = await ref.watch(timeSeriesProvider(
    address.copyWith(datasetId: TfrApi.tfrDatasetId),
  ).future);
  return _TimeSeriesWithTfr(series, tfr);
});

class TimeSeriesCard extends ConsumerWidget {
  final TimeSeriesAddress address;

  const TimeSeriesCard({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(timeSeriesWithTfrProvider(address));

    return asyncValue.when(
      data: (data) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CardTitle(title: 'Vývoj v čase spolu s TFR'),
              TimeSeriesWithTfrChart(
                series: data.series,
                tfr: data.tfr,
              ),
              const CardTitle(title: 'Korelace s TFR'),
              if (data.series.lag != null &&
                  data.series.processedSeries != null) ...[
                SizedBox(
                  height: 350,
                  child: TimeSeriesCorrelationChart(
                    series: data.series,
                    tfr: data.tfr,
                  ),
                ),
                Padding(
                  padding: CustomTheme.of(context).sizes.tilePadding,
                  child: const Text(
                      'Korelace je zjišťována porovnáním diferencovaných dat. Neporovnávají se tedy přímo hodnoty v daném roce, ale jejich rozdíl proti hodnotě z minulého roku. Výsledkem je tak zjištění závislosti mezi změnami ve vývoji, nikoli mezi celkovým trendem.' //, kde by závislosti mohly být silně zavádějící.',
                      ),
                ),
              ],
              data.series.correlation
                  ? ListTile(
                      leading: Icon(
                        Icons.done,
                        color: CustomTheme.of(context).colors.okayIconColor,
                      ),
                      title: Text((data.series.rValue! >= 0
                              ? 'Pozitivní'
                              : 'Negativní') +
                          ' korelace byla potvrzena následujícími parametry.'),
                    )
                  : ListTile(
                      leading: Icon(
                        Icons.close,
                        color: CustomTheme.of(context).colors.errorIconColor,
                      ),
                      title: Text(data.series.lag != null
                          ? 'Korelace nebyla potvrzena, nejlepší byly následující parametry.'
                          : 'Korelace nebyla potvrzena, chybí data.'),
                    ),
              ..._correlationDetails(context, data)
            ],
          ),
        );
      },
      loading: () => const Card(
        child: SizedBox(
          height: 1146.0, // Prevent flickering due to page height changes.
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => Padding(
        padding: CustomTheme.of(context).sizes.padding,
        child: const Center(
          child: Text('Vyberte region ze seznamu'),
        ),
      ),
    );
  }

  /// Build correlation detail ListTiles only if the details are non-null.
  List<Widget> _correlationDetails(
      BuildContext context, _TimeSeriesWithTfr data) {
    if (data.series.lag == null ||
        data.series.rValue == null ||
        data.series.pValue == null ||
        data.series.slope == null ||
        data.series.intercept == null) return [];

    String lagUnit = 'let';
    if (data.series.lag?.abs() == 1) lagUnit = 'rok';
    if ((data.series.lag?.abs() ?? 1) >= 2 &&
        (data.series.lag?.abs() ?? 5) <= 4) {
      lagUnit = 'roky';
    }
    return [
      ListTile(
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              const TextSpan(
                text: 'Zpoždění: ',
              ),
              TextSpan(
                text: '${data.series.lag} $lagUnit',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: CustomTheme.of(context)
            .sizes
            .tilePadding
            .copyWith(top: 0, bottom: 0),
        child: const Text(
            'Při ověřování korelace se hledá souvislost nejen mezi dvojicemi hodnot pro každý rok, ale časové řady se také zkouší vzájemně posouvat v čase. Při kladném zpoždění TFR na změnu hodnoty ukazatele reaguje opožděně. Pokud je naopak zpoždění záporné, změny v TFR předchází změnám ve sledovaném ukazateli.'),
      ),
      ListTile(
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              const TextSpan(
                text: 'Korelační koeficient: ',
              ),
              TextSpan(
                text: data.series.rValue!.toStringAsFixed(3),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: CustomTheme.of(context)
            .sizes
            .tilePadding
            .copyWith(top: 0, bottom: 0),
        child: const Text(
            'Pearsonův korelační koeficient vyjadřuje míru podobnosti dvou náhodných vektorů, v tomto případě časových řad o stejné délce a frekvenci. Aby byla korelace potvrzena, prvním kritériem je korelační koeficient v absolutní hodnotě větší nebo roven 0.4.'),
      ),
      ListTile(
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              const TextSpan(
                text: 'Sklon regresní přímky: ',
              ),
              TextSpan(
                text: data.series.slope!.toStringAsFixed(3),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: CustomTheme.of(context)
            .sizes
            .tilePadding
            .copyWith(top: 0, bottom: 0),
        child: const Text(
            'Dvojice datových bodů jsou také porovnávány lineární regresí (bodový graf vpravo). Proložená (regresní) přímka ukazuje lineární závislost mezi sledovaným ukazatelem a TFR. Sklon lze interpretovat jako hodnotu, o kterou se musí změnit sledovaný ukazatel, aby se TFR zvýšilo o 1.'),
      ),
      ListTile(
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              const TextSpan(
                text: 'Intercept: ',
              ),
              TextSpan(
                text: data.series.intercept!.toStringAsFixed(3),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: CustomTheme.of(context)
            .sizes
            .tilePadding
            .copyWith(top: 0, bottom: 0),
        child: const Text(
            'Intercept je posunem regresní přímky po ose Y. Pokud to vzhledem k významu ukazatele dává smysl, lze jej interpretovat jako hodnotu TFR, když je ukazatel roven nule.'),
      ),
      ListTile(
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              const TextSpan(
                text: 'p hodnota: ',
              ),
              TextSpan(
                text: data.series.pValue!.toStringAsFixed(3),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: CustomTheme.of(context).sizes.tilePadding.copyWith(top: 0),
        child: const Text(
            'Druhým kritériem pro ověření korelace je statistický test nenulovosti sklonu regresní přímky. Pokud je p hodnota dostatečně nízká, pak s ((1 - p) * 100)% jistotou zamítáme hypotézu, že přímka má nulový sklon a mezi sledovaným ukazatelem a TFR není lineární závislost.'),
      ),
    ];
  }
}
