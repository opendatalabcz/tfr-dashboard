import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/app/presentation/common.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

class NumbersStrip extends ConsumerWidget {
  const NumbersStrip({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionsCountAsyncValue = ref.watch(regionsCountProvider);
    final datasetsCountAsyncValue = ref.watch(datasetsCountProvider);
    final timeSeriesCountAsyncValue = ref.watch(timeSeriesCountProvider);
    final correlationsCountAsyncValue = ref.watch(correlationsCountProvider);

    return Wrap(
      children: [
        DashboardSingleValueCard(
          title: 'oblastí',
          value: regionsCountAsyncValue.maybeWhen(
            data: (data) => data.toString(),
            orElse: () => '?',
          ),
          dialog: const TextDialog(
            'Aplikace zpřístupňuje data ze zemí Evropské unie a několika dalších geograficky a kulturně blízkých států, aby byly výsledky porovnatelné. Navíc je možné prohlédnout si evropský a celosvětový průměr.',
            title: 'Oblasti',
          ),
        ),
        DashboardSingleValueCard(
          title: 'ukazatelů',
          value: datasetsCountAsyncValue.maybeWhen(
            data: (data) => data.toString(),
            orElse: () => '?',
          ),
          dialog: const TextDialog(
            'V online datových zdrojích byly nalezeny demografické, ekonomické a další ukazatele. Jedná se jednak o ukazatele, které mají prokázaný vliv na TFR, jednak o nové, dosud nezkoumané.',
            title: 'Ukazatele',
          ),
        ),
        DashboardSingleValueCard(
          title: 'časových řad',
          value: timeSeriesCountAsyncValue.maybeWhen(
            data: (data) => data.toString(),
            orElse: () => '?',
          ),
          dialog: const TextDialog(
            'Ukazatele, které aplikace nabízí, mají většinou dostupná data pro více zemí. Každý vývoj daného ukazatele v čase a určitém státě tvoří jednu časovou řadu. Tu je možné porovnat s vývojem TFR ve stejném státě či napříč státy.',
            title: 'Časové řady',
          ),
        ),
        const DashboardSingleValueCard(
          title: 'pokrytí',
          value: '1980-2022',
          dialog: TextDialog(
            'Data dostupná v aplikaci jsou omezena na dobu od roku 1980 - většina ukazatelů totiž není dostupná v dřívějších obdobích. Aplikace cílí zejména na 21. století, pro nějž je k dispozici nejvíce dat.',
            title: 'Časové pokrytí',
          ),
        ),
        DashboardSingleValueCard(
          title: 'korelací',
          value: correlationsCountAsyncValue.maybeWhen(
            data: (data) => data.toString(),
            orElse: () => '?',
          ),
          dialog: const TextDialog(
            'Aplikace umožňuje zobrazení ukazatelů, které korelují s TFR a mají tedy podobný průběh čase. Korelace však nemusí znamenat, že je mezi daným ukazatelem a TFR příčinná souvislost.',
            title: 'Korelace',
          ),
        ),
      ],
    );
  }
}

class DashboardSingleValueCard extends StatelessWidget {
  final String value;
  final String title;
  final TextDialog? dialog;

  const DashboardSingleValueCard({
    Key? key,
    required this.value,
    required this.title,
    this.dialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: Padding(
          padding: CustomTheme.of(context).sizes.tilePadding,
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: '$value ',
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    color: Theme.of(context).primaryColor.withOpacity(0.8)),
              ),
              TextSpan(
                text: title,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ]),
          ),
        ),
        onTap: dialog != null
            ? () {
                showDialog(context: context, builder: (_) => dialog!);
              }
            : null,
      ),
    );
  }
}
