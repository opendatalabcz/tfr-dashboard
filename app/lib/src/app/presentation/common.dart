import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tfr_dashboard/src/theming/theming.dart';

List<Region> sortedRegions(List<Region> regions) {
  regions.sort((a, b) => a.name.compareTo(b.name));
  // Put 'Whole world' and 'European Union' first if they are present.
  try {
    final euu = regions.singleWhere((region) => region.id == 'euu');
    regions.removeWhere((region) => region.id == 'euu');
    regions.insert(0, euu);
    // ignore: empty_catches
  } on StateError {}
  try {
    final wld = regions.singleWhere((region) => region.id == 'wld');
    regions.removeWhere((region) => region.id == 'wld');
    regions.insert(0, wld);
    // ignore: empty_catches
  } on StateError {}
  return regions;
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CustomTheme.of(context).sizes.tilePadding,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}

class CardTitle extends StatelessWidget {
  final String title;

  const CardTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CustomTheme.of(context).sizes.tilePadding,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}

/// Returns a string title for an object of type T.
typedef TitleSelector<T> = String Function(T);

/// Returns true when an object of type T is selected.
typedef SelectionChecker<T> = bool Function(T);

class SelectorCard<T> extends StatelessWidget {
  final List<T> items;
  final SelectionChecker<T> isSelected;
  final ValueChanged<T> onSelected;

  final TitleSelector<T> titleSelector;

  final bool isScrollable;

  const SelectorCard({
    Key? key,
    required this.items,
    required this.isSelected,
    required this.onSelected,
    required this.titleSelector,
    this.isScrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = [
      for (final item in items)
        ListTile(
          title: Text(titleSelector(item)),
          selectedTileColor: Theme.of(context).primaryColor,
          selectedColor: Theme.of(context).selectedRowColor,
          selected: isSelected(item),
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: CustomTheme.of(context).sizes.tileBorderRadius,
          ),
          onTap: () {
            onSelected(item);
          },
        ),
    ];

    if (isScrollable) {
      final scrollController = ScrollController();

      return Card(
        child: Padding(
          padding: CustomTheme.of(context).sizes.padding.copyWith(right: 8.0),
          child: Scrollbar(
            controller: scrollController,
            isAlwaysShown: true,
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              // padding: const EdgeInsets.all(16.0),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView(
                  controller: scrollController,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Card(
        child: Padding(
          padding: CustomTheme.of(context).sizes.padding,
          child: Column(
            children: children,
          ),
        ),
      );
    }
  }
}

class PageFooter extends StatelessWidget {
  const PageFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CustomTheme.of(context).sizes.padding,
      child: Center(
        // 'Dashboard vznikl v rámci bakalářské práce na FIT ČVUT ve spolupráci s OpenDataLab © 2022'
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'Dashboard',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch('https://github.com/opendatalabcz/tfr-dashboard');
                  },
              ),
              const TextSpan(text: ' vznikl v rámci bakalářské práce na '),
              TextSpan(
                text: 'FIT ČVUT',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch('https://fit.cvut.cz');
                  },
              ),
              const TextSpan(text: ' ve spolupráci s '),
              TextSpan(
                text: 'OpenDataLab',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch('https://opendatalab.cz');
                  },
              ),
              const TextSpan(text: ' © 2022'),
            ],
          ),
        ),
      ),
    );
  }
}

class TextDialog extends StatelessWidget {
  final String? title;
  final String text;

  const TextDialog(
    this.text, {
    this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: SizedBox(
        width: 500.0,
        child: Text(text),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zavřít'),
        ),
      ],
      // contentPadding: EdgeInsets.all(24),
    );
  }
}
