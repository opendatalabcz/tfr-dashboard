import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tfr_dashboard/src/app/presentation/common.dart';
import 'package:tfr_dashboard/src/data/application/api.dart';
import 'package:tfr_dashboard/src/data/application/app.dart';
import 'package:tfr_dashboard/src/data/presentation/dataset/region_details.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import '../domain/data.dart';

class RegionPage extends ConsumerWidget {
  final String regionId;

  const RegionPage({
    Key? key,
    required this.regionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionAsyncValue = ref.watch(regionProvider(regionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          regionAsyncValue.maybeWhen(
              data: (data) => data.name, orElse: () => 'Region'),
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
            const SectionTitle(title: 'Ukazatele korelující s TFR'),
            Datasets(regionId: regionId),
            const PageFooter(),
            SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
          ],
        ),
      ),
    );
  }
}

class Datasets extends ConsumerWidget {
  final String regionId;

  const Datasets({
    Key? key,
    required this.regionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetsAsyncValue =
        ref.watch(correlatingDatasetsForRegionProvider(regionId));
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
                child: TimeSeriesCard(
                  address: TimeSeriesAddress(
                    datasetId: selectedDatasetId,
                    regionId: regionId,
                  ),
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
              TimeSeriesCard(
                address: TimeSeriesAddress(
                  datasetId: selectedDatasetId,
                  regionId: regionId,
                ),
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
