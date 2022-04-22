import 'package:flutter/material.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

// TODO: Implement from API.
class NumbersStrip extends StatelessWidget {
  const NumbersStrip({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: const [
        DashboardSingleValueCard(
          title: 'regionů',
          value: '50',
        ),
        DashboardSingleValueCard(
          title: 'ukazatelů',
          value: '64',
        ),
        DashboardSingleValueCard(
          title: 'časových řad',
          value: '684',
        ),
        DashboardSingleValueCard(
          title: 'pokrytí',
          value: '1980-2020',
        ),
        DashboardSingleValueCard(
          title: 'korelací',
          value: '92',
        ),
        // TODO: Pie chart of correlating sets vs. all sets?
      ],
    );
  }
}

class DashboardSingleValueCard extends StatelessWidget {
  final String value;
  final String title;

  const DashboardSingleValueCard({
    Key? key,
    required this.value,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: CustomTheme.of(context).sizes.tilePadding,
        child: Row(
          // TODO: Remake with RichText.
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  color: Theme.of(context).primaryColor.withOpacity(0.8)),
            ),
            SizedBox(width: CustomTheme.of(context).sizes.paddingSize),
            Text(title),
          ],
        ),
      ),
    );
  }
}
