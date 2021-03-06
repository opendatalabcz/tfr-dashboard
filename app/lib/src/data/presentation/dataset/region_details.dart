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
        onSelected: (region) => ref
            .read(selectedRegionIdProviderOverride.notifier)
            .update((state) => region.id),
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
              const CardTitle(title: 'V??voj v ??ase spolu s TFR'),
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
                      'Korelace je zji????ov??na porovn??n??m diferencovan??ch dat. Neporovn??vaj?? se tedy p????mo hodnoty v dan??m roce, ale jejich rozd??l proti hodnot?? z minul??ho roku. V??sledkem je tak zji??t??n?? z??vislosti mezi zm??nami ve v??voji, nikoli mezi celkov??m trendem.' //, kde by z??vislosti mohly b??t siln?? zav??d??j??c??.',
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
                              ? 'Pozitivn??'
                              : 'Negativn??') +
                          ' korelace byla potvrzena n??sleduj??c??mi parametry.'),
                    )
                  : ListTile(
                      leading: Icon(
                        Icons.close,
                        color: CustomTheme.of(context).colors.errorIconColor,
                      ),
                      title: Text(data.series.lag != null
                          ? 'Korelace nebyla potvrzena, nejlep???? byly n??sleduj??c?? parametry.'
                          : 'Korelace nebyla potvrzena, chyb?? data.'),
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
          child: Text('Vyberte st??t ze seznamu'),
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
                text: 'Zpo??d??n??: ',
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
            'P??i ov????ov??n?? korelace se hled?? souvislost nejen mezi dvojicemi hodnot pro ka??d?? rok, ale ??asov?? ??ady se tak?? zkou???? vz??jemn?? posouvat v ??ase. P??i kladn??m zpo??d??n?? reaguje TFR na zm??nu hodnoty ukazatele opo??d??n??. Pokud je naopak zpo??d??n?? z??porn??, zm??ny v TFR p??edch??z?? zm??n??m ve sledovan??m ukazateli. Vybr??no je to zpo??d??n??, pro n??j?? je korela??n?? koeficient nejvy??????.'),
      ),
      ListTile(
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              const TextSpan(
                text: 'Korela??n?? koeficient: ',
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
            'Pearson??v korela??n?? koeficient vyjad??uje m??ru podobnosti dvou n??hodn??ch vektor??, v tomto p????pad?? ??asov??ch ??ad o stejn?? d??lce a frekvenci. Pokud je kladn??, vy?????? hodnota ukazatele souvis?? s vy?????? hodnotou TFR. Je-li z??porn??, pak vy?????? hodnota ukazatele znamen?? ni?????? TFR. ????m je hodnota d??l od nuly, t??m je korelace siln??j????.'),
      ),
      ListTile(
        title: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              const TextSpan(
                text: 'Sklon regresn?? p????mky: ',
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
            'Dvojice datov??ch bod?? jsou tak?? porovn??v??ny line??rn?? regres?? (bodov?? graf vpravo). Prolo??en?? (regresn??) p????mka ukazuje line??rn?? z??vislost mezi sledovan??m ukazatelem a TFR. Sklon lze interpretovat jako hodnotu, o kterou se mus?? zm??nit sledovan?? ukazatel, aby se TFR zv????ilo o 1.'),
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
            'Intercept je posunem regresn?? p????mky po ose Y. Pokud to vzhledem k v??znamu ukazatele d??v?? smysl, lze jej interpretovat jako hodnotu TFR, kdy?? je ukazatel roven nule.'),
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
            'Krit??riem pro ov????en?? statistick?? v??znamnosti tvrzen?? o korelaci je statistick?? test nenulovosti sklonu regresn?? p????mky. Pokud je p hodnota dostate??n?? n??zk??, pak s ((1 - p) * 100)% jistotou zam??t??me hypot??zu, ??e p????mka m?? nulov?? sklon a mezi sledovan??m ukazatelem a TFR nen?? line??rn?? z??vislost.'),
      ),
    ];
  }
}
