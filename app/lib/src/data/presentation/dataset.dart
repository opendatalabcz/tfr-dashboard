import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tfr_dashboard/src/app/app.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import 'dataset/inter_region_details.dart';
import 'dataset/region_details.dart';

final selectedCorrelatingRegionIdProvider = StateProvider<String?>((ref) {
  return null;
});

final selectedNonCorrelatingRegionIdProvider = StateProvider<String?>((ref) {
  return null;
});

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

    return WillPopScope(
      onWillPop: () async {
        // Clear the selected region providers, so that the next opened dataset
        // doesn't have preselected regions with possibly mixed up placement in
        // the Found correlations / No correlations section.
        ref
            .read(selectedCorrelatingRegionIdProvider.notifier)
            .update((state) => null);
        ref
            .read(selectedNonCorrelatingRegionIdProvider.notifier)
            .update((state) => null);
        return true;
      },
      child: Scaffold(
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
              const SectionTitle(
                  title: 'Nalezené korelace v jednotlivých regionech'),
              Expanded(
                  child: RegionDetails(
                datasetId: datasetId,
                regionsProvider: correlatingRegionsForDatasetProvider,
                selectedRegionIdProviderOverride:
                    selectedCorrelatingRegionIdProvider,
              )),
              const SectionTitle(title: 'Regiony bez korelace'),
              Expanded(
                  child: RegionDetails(
                datasetId: datasetId,
                regionsProvider: nonCorrelatingRegionsForDatasetProvider,
                selectedRegionIdProviderOverride:
                    selectedNonCorrelatingRegionIdProvider,
              )),
              const PageFooter(),
              SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
            ],
          ),
        ),
      ),
    );
  }
}
