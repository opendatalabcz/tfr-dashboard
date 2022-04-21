import 'package:flutter/material.dart';

import 'package:tfr_dashboard/src/theming/theming.dart';

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

  const SelectorCard({
    Key? key,
    required this.items,
    required this.isSelected,
    required this.onSelected,
    required this.titleSelector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: CustomTheme.of(context).sizes.tilePadding,
        child: ListView(
          controller: ScrollController(),
          children: [
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
          ],
        ),
      ),
    );
  }
}
