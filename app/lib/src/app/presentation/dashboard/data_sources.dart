import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/app/app.dart';
import 'package:tfr_dashboard/src/data/application/api.dart';
import 'package:url_launcher/url_launcher.dart';

class DataSources extends ConsumerWidget {
  const DataSources({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSources = ref.watch(dataSourcesProvider);

    final cards = dataSources.when(
      data: (data) => data.map(
        (dataSource) {
          final datasetsCountAsyncValue =
              ref.watch(datasetsInDataSourceCountProvider(dataSource.id));

          final datasetsCount = datasetsCountAsyncValue.when(
            data: (data) => data,
            error: (_, __) => '?',
            loading: () => '?',
          );

          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTitle(title: dataSource.name),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(dataSource.description),
                ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: Text(
                    dataSource.url,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onTap: () {
                    launch(dataSource.url);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insights),
                  title: Text('$datasetsCount ukazatelů'),
                ),
                ListTile(
                  title: const Text('Zobrazit více'),
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/data-source/${dataSource.id}');
                  },
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          );
        },
      ).toList(),
      error: (_, __) => const [],
      loading: () => const [CircularProgressIndicator()],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Datové zdroje'),
        for (int i = 0; i < cards.length; i += 2)
          Row(
            children: [
              if (i < cards.length) Expanded(child: cards[i]),
              if (i + 1 < cards.length) Expanded(child: cards[i + 1]),
            ],
          ),
      ],
    );
  }
}
