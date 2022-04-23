import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/data/application/app.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';
import 'package:url_launcher/url_launcher.dart';

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
            const SectionTitle(title: 'Vývoj napříč regiony'),
            InterRegionDetailsCard(datasetId: datasetId),
            const SectionTitle(title: 'Vývoj podle regionu'),
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

    return Card(
      child: Padding(padding: CustomTheme.of(context).sizes.tilePadding),
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
