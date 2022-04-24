import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/app/app.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import '../../data.dart';
import 'charts.dart';

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
      data: (data) {
        if (data.correlationValuesPerYear != null) {
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: CustomTheme.of(context).sizes.tilePadding,
                  child: InterRegionCorrelationChart(dataset: data),
                ),
                const CardTitle(title: 'Jak graf číst?'),
                Padding(
                  padding: CustomTheme.of(context)
                      .sizes
                      .tilePadding
                      .copyWith(top: 0),
                  child: const Text(
                    'Graf popisuje vztah mezi hodnotami ukazatele a hodnotami TFR v každém roce napříč regiony. Korelace byla nalezena v těch časových úsecích, kde je plocha grafu podbarvená. Není-li graf podbarvený nikde, korelace ukazatele a TFR napříč regiony nalezena nebyla.',
                  ),
                ),
                Padding(
                  padding: CustomTheme.of(context)
                      .sizes
                      .tilePadding
                      .copyWith(top: 0, bottom: 0),
                  child: const Text(
                    'Pokud je hodnota korelačního koeficientu kladná, pak platí, že v regionech, kde má ukazatel vysokou hodnotu, je vysoké i TFR (pozitivní korelace). Je-li ale korelační koeficient záporný, pak v regionech, kde má ukazatel vysokou hodnotu, je naopak TFR nízké (negativní korelace).',
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
                          'Pro oveření korelace se používá jednak pearsonův korelační koeficient, jednak p hodnota statistického testu nenulovosti sklonu regresní přímky. Korelace platí, pokud je korelační koeficient dostatečně daleko od nuly (v absolutní hodnotě alespoň 0.4) a zároveň je p hodnota testu nižší než 0.05 (zamítáme na 95% hladině hypotézu, že regresní přímka má nulový sklon).',
                          title: 'Metoda výpočtu korelace',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: CustomTheme.of(context).sizes.padding,
            child: Text(
              'Korelace napříč regiony není dostupná, protože ukazatel nemá hodnoty v dostatečném počtu regionů.',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          );
        }
      },
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
