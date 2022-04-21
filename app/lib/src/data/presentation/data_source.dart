import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/app/presentation/common.dart';
import 'package:tfr_dashboard/src/data/application/api.dart';
import 'package:tfr_dashboard/src/data/application/app.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final datasetsAsyncValue =
        ref.watch(datasetsInDataSourceProvider(dataSourceId));
    final selectedDatasetId = ref.watch(selectedDatasetIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          dataSourceAsyncValue.maybeWhen(
              data: (data) => 'Datový zdroj ${data.name}',
              orElse: () => 'Datový zdroj'),
        ),
      ),
      body: Padding(
        padding: CustomTheme.of(context).sizes.halfPadding.copyWith(
              top: 0,
              bottom: 0,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
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
            ),
            const SectionTitle(title: 'Ukazatele'),
            Expanded(
              child: LayoutBuilder(builder: ((context, constraints) {
                final datasetSelector = SelectorCard<Dataset>(
                  items: datasetsAsyncValue.maybeWhen(
                    data: (data) => data,
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
                    children: [
                      SizedBox(
                          width: min(constraints.maxWidth / 3, 400.0),
                          child: datasetSelector),
                      if (selectedDatasetId != null)
                        Expanded(
                          child: DatasetCard(datasetId: selectedDatasetId),
                        )
                      else
                        const Expanded(
                          child: Center(
                            child: Text('Vyberte ukazatel ze seznamu'),
                          ),
                        ),
                    ],
                  );
                } else {
                  return ListView(
                    children: [
                      SizedBox(
                        height: 300,
                        child: datasetSelector,
                      ),
                      if (selectedDatasetId != null)
                        DatasetCard(
                          datasetId: selectedDatasetId,
                          isScrollable: false,
                        )
                      else
                        const Center(
                          child: Text('Vyberte ukazatel ze seznamu'),
                        ),
                    ],
                  );
                }
              })),
            ),
            SizedBox(height: CustomTheme.of(context).sizes.halfPaddingSize),
          ],
        ),
      ),
    );
  }
}

class DatasetCard extends ConsumerWidget {
  final String datasetId;
  final bool isScrollable;

  const DatasetCard({
    Key? key,
    required this.datasetId,
    this.isScrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetAsyncValue = ref.watch(datasetProvider(datasetId));

    final children = [
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
      const ListTile(
        leading: Icon(Icons.insights),
        title: Text('Dostupné časové řady pro <počet> regionů'),
      ),
      ListTile(
        leading: const Icon(Icons.numbers),
        title: Text(datasetAsyncValue.maybeWhen(
            data: (data) => 'Jednotka: ${data.unit}',
            orElse: () => 'Jednotka')),
      ),
      const ListTile(
        leading: Icon(Icons.poll),
        title: Text('Vývoj ve zvoleném regionu'),
        subtitle: Text('<zvolený region>'),
      ),
      // TODO: Chart for the currently selected region.
      const SizedBox(
        height: 300.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Placeholder(),
        ),
      ),
      ListTile(
        title: const Text('Zobrazit detaily a ostatní regiony'),
        onTap: () {
          Navigator.pushNamed(context, '/dataset/$datasetId');
        },
        trailing: const Icon(Icons.chevron_right),
      ),
    ];

    return Card(
      child: isScrollable
          ? ListView(children: children)
          : Column(children: children),
    );
  }
}
