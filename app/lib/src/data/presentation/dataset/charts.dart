import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tfr_dashboard/src/theming/theming.dart';

import '../../data.dart';

/// Inter-region correlation chart. The data series of the given [Dataset] must
/// not be null.
class InterRegionCorrelationChart extends StatelessWidget {
  final Dataset dataset;

  const InterRegionCorrelationChart({
    Key? key,
    required this.dataset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
        enable: true,
        decimalPlaces: 3,
        activationMode: ActivationMode.singleTap,
        animationDuration: 0,
        duration: 0,
      ),
      legend: Legend(
        isVisible: true,
      ),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        minimum: -1,
        maximum: 1,
      ),
      series: <ChartSeries<dynamic, dynamic>>[
        AreaSeries<MapEntry<String, bool>, String>(
          name: 'ukazatel koreluje',
          legendIconType: LegendIconType.rectangle,
          dataSource: dataset.correlationValuesPerYear!.entries
              // .map((e) => MapEntry(e.key, e.value ? 1.0 : 0.0))
              .toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value ? 1.0 : null,
          animationDelay: 0,
          animationDuration: 0,
          color: Theme.of(context).primaryColor,
          opacity: 0.2,
          enableTooltip: false,
        ),
        AreaSeries<MapEntry<String, bool>, String>(
          isVisibleInLegend: false,
          enableTooltip: false,
          dataSource: dataset.correlationValuesPerYear!.entries
              // .map((e) => MapEntry(e.key, e.value ? 1.0 : 0.0))
              .toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value ? -1.0 : null,
          animationDelay: 0,
          animationDuration: 0,
          color: Theme.of(context).primaryColor,
          opacity: 0.2,
        ),
        LineSeries<MapEntry<String, num>, String>(
          name: 'p hodnota',
          dataSource: dataset.pValuesPerYear!.entries.toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value,
          animationDelay: 0,
          animationDuration: 0,
          color: Colors.purpleAccent,
        ),
        LineSeries<MapEntry<String, num>, String>(
          name: 'korelační koeficient',
          dataSource: dataset.rValuesPerYear!.entries.toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value,
          animationDelay: 0,
          animationDuration: 0,
          color: CustomTheme.of(context).colors.correlationColor,
        ),
      ],
      enableAxisAnimation: false,
    );
  }
}

class TimeSeriesWithTfrChart extends StatelessWidget {
  final TimeSeries series;
  final TimeSeries tfr;

  const TimeSeriesWithTfrChart({
    Key? key,
    required this.series,
    required this.tfr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Trim series to the same interval.
      final seriesStart = int.parse(series.series.keys.first);
      final seriesEnd = int.parse(series.series.keys.last);
      final tfrStart = int.parse(tfr.series.keys.first);
      final tfrEnd = int.parse(tfr.series.keys.last);

      final commonStart = max(seriesStart, tfrStart);
      final commonEnd = min(seriesEnd, tfrEnd);

      if (commonStart >= commonEnd) throw 'Series does not overlap with TFR';

      final trimmedSeries = Map.of(series.series);
      trimmedSeries.removeWhere((key, value) =>
          int.parse(key) < commonStart || int.parse(key) > commonEnd);
      final trimmedTfr = Map.of(tfr.series);
      trimmedTfr.removeWhere((key, value) =>
          int.parse(key) < commonStart || int.parse(key) > commonEnd);

      final sortedSeries = trimmedSeries.values.toList();
      sortedSeries.sort();
      final minSeriesValue = sortedSeries.first;
      final maxSeriesValue = sortedSeries.last;
      final padding = ((maxSeriesValue - minSeriesValue) / 20).roundToDouble();

      final sortedTfr = trimmedTfr.values.toList();
      sortedTfr.sort();
      final minTfrValue = sortedTfr.first;
      final maxTfrValue = sortedTfr.last;

      return SfCartesianChart(
        tooltipBehavior: TooltipBehavior(
          enable: true,
          decimalPlaces: 3,
          activationMode: ActivationMode.singleTap,
          animationDuration: 0,
          duration: 0,
        ),
        legend: Legend(
          isVisible: true,
        ),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          name: 'series',
          minimum: minSeriesValue.floorToDouble() - padding,
          maximum: maxSeriesValue.ceilToDouble() + padding,
          numberFormat: NumberFormat.compact(locale: 'cs_CZ'),
        ),
        axes: [
          NumericAxis(
            name: 'tfr',
            opposedPosition: true,
            // Round to nearest tenth and add a padding of one tenth.
            minimum: (minTfrValue * 10).floorToDouble() / 10 - 0.1,
            maximum: (maxTfrValue * 10).ceilToDouble() / 10 + 0.1,
          ),
        ],
        series: <ChartSeries<dynamic, dynamic>>[
          LineSeries<MapEntry<String, num>, String>(
            name: 'Ukazatel',
            yAxisName: 'series',
            dataSource: trimmedSeries.entries.toList(),
            xValueMapper: (entry, _) => entry.key,
            yValueMapper: (entry, _) => entry.value,
            animationDelay: 0,
            animationDuration: 0,
            color: CustomTheme.of(context).colors.otherSeriesColor,
          ),
          LineSeries<MapEntry<String, num>, String>(
            name: 'TFR',
            yAxisName: 'tfr',
            dataSource: trimmedTfr.entries.toList(),
            xValueMapper: (entry, _) => entry.key,
            yValueMapper: (entry, _) => entry.value,
            animationDelay: 0,
            animationDuration: 0,
            color: CustomTheme.of(context).colors.tfrColor,
          ),
        ],
        enableAxisAnimation: false,
      );
    } catch (e) {
      // Series is not plottable.
      return const ListTile(
        leading: Icon(Icons.error),
        title: Text('Data nejsou dostupná'),
      );
    }
  }
}

/// Time series correlation charts. The [processedSeries] of given [TimeSeries]
/// must not be null.
class TimeSeriesCorrelationChart extends StatelessWidget {
  final TimeSeries series;
  final TimeSeries tfr;

  const TimeSeriesCorrelationChart({
    Key? key,
    required this.series,
    required this.tfr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Trim series to the common (same length, relatively lagged) interval.
      final int seriesStart = int.parse(series.processedSeries!.keys.first);
      final int seriesEnd = int.parse(series.processedSeries!.keys.last);
      final int tfrStart = int.parse(tfr.processedSeries!.keys.first);
      final int tfrEnd = int.parse(tfr.processedSeries!.keys.last);

      int seriesLaggedStart;
      int seriesLaggedEnd;
      int tfrLaggedStart;
      int tfrLaggedEnd;
      if (series.lag! >= 0) {
        tfrLaggedStart = tfrStart;
        seriesLaggedStart = tfrStart + series.lag!;
        if (seriesLaggedStart < seriesStart) {
          tfrLaggedStart += seriesStart - seriesLaggedStart;
          seriesLaggedStart = seriesStart;
        }
        seriesLaggedEnd = seriesEnd;
        tfrLaggedEnd = seriesEnd - series.lag!;
        if (tfrLaggedEnd > tfrEnd) {
          seriesLaggedEnd -= tfrLaggedEnd - tfrEnd;
          tfrLaggedEnd = tfrEnd;
        }
      } else {
        seriesLaggedStart = seriesStart;
        tfrLaggedStart = seriesStart - series.lag!;
        if (tfrLaggedStart < tfrStart) {
          seriesLaggedStart += tfrStart - tfrLaggedStart;
          tfrLaggedStart = tfrStart;
        }
        tfrLaggedEnd = tfrEnd;
        seriesLaggedEnd = tfrEnd + series.lag!;
        if (seriesLaggedEnd > seriesEnd) {
          tfrLaggedEnd -= seriesLaggedEnd - seriesEnd;
          seriesLaggedEnd = seriesEnd;
        }
      }

      if (seriesLaggedStart >= seriesLaggedEnd ||
          tfrLaggedStart >= tfrLaggedEnd) {
        throw 'Series does not overlap with TFR';
      }

      final trimmedSeries = Map.of(series.processedSeries!);
      trimmedSeries.removeWhere((key, value) =>
          int.parse(key) < seriesLaggedStart ||
          int.parse(key) > seriesLaggedEnd);

      final trimmedTfr = Map.of(tfr.processedSeries!);
      trimmedTfr.removeWhere((key, value) =>
          int.parse(key) < tfrLaggedStart || int.parse(key) > tfrLaggedEnd);

      // Find min and max values to bound the axes.
      final sortedSeries = trimmedSeries.values.toList();
      sortedSeries.sort();
      final minSeriesValue = sortedSeries.first;
      final maxSeriesValue = sortedSeries.last;
      final padding = ((maxSeriesValue - minSeriesValue) / 20).roundToDouble();
      final minSeriesAxisValue = minSeriesValue.floorToDouble() - padding;
      final maxSeriesAxisValue = maxSeriesValue.ceilToDouble() + padding;

      final sortedTfr = trimmedTfr.values.toList();
      sortedTfr.sort();
      final minTfrValue = sortedTfr.first;
      final maxTfrValue = sortedTfr.last;
      // Round to nearest tenth and add a padding of one tenth.
      final minTfrAxisValue = (minTfrValue * 10).floorToDouble() / 10;
      final maxTfrAxisValue = (maxTfrValue * 10).ceilToDouble() / 10;

      final regressionPoints = <Point>[];
      for (int i = 0; i < trimmedTfr.values.length; i++) {
        regressionPoints.add(Point(
          trimmedTfr.values.elementAt(i),
          trimmedSeries.values.elementAt(i),
        ));
      }

      // Create series for the differenced time series chart.
      final tfrChartSeries = LineSeries<MapEntry<String, num>, String>(
        name: 'TFR',
        yAxisName: 'tfr',
        xAxisName: 'none',
        dataSource: trimmedTfr.entries.toList(),
        xValueMapper: (entry, _) {
          final year = int.parse(entry.key);
          return (year + series.lag!).toString();
        },
        yValueMapper: (entry, _) => entry.value,
        animationDelay: 0,
        animationDuration: 0,
        color: CustomTheme.of(context).colors.tfrColor,
      );
      final otherChartSeries = LineSeries<MapEntry<String, num>, String>(
        name: 'Ukazatel',
        yAxisName: 'series',
        dataSource: trimmedSeries.entries.toList(),
        xValueMapper: (entry, _) => entry.key,
        yValueMapper: (entry, _) => entry.value,
        animationDelay: 0,
        animationDuration: 0,
        color: CustomTheme.of(context).colors.otherSeriesColor,
      );

      // Create regression line for the regression chart.
      final regressionLine = [
        Point(minTfrAxisValue,
            series.intercept! + minTfrAxisValue * series.slope!),
        Point(maxTfrAxisValue,
            series.intercept! + maxTfrAxisValue * series.slope!),
      ];

      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SfCartesianChart(
              title: ChartTitle(text: 'Diferencovaný vývoj'),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                decimalPlaces: 2,
                activationMode: ActivationMode.singleTap,
                animationDuration: 0,
                duration: 0,
              ),
              primaryXAxis: CategoryAxis(
                title: AxisTitle(
                  text: 'Čas' +
                      (series.lag! != 0
                          ? ' (zpoždění TFR ${series.lag!})'
                          : ''),
                ),
              ),
              primaryYAxis: NumericAxis(
                name: 'series',
                title: AxisTitle(text: 'Ukazatel'),
                minimum: minSeriesAxisValue,
                maximum: maxSeriesAxisValue,
                numberFormat: NumberFormat.compact(locale: 'cs_CZ'),
              ),
              axes: [
                NumericAxis(
                  name: 'tfr',
                  title: AxisTitle(text: 'TFR'),
                  opposedPosition: true,
                  minimum: minTfrAxisValue,
                  maximum: maxTfrAxisValue,
                ),
              ],
              series: <ChartSeries<dynamic, dynamic>>[
                // Sort the series, so that the labels and lines aren't wrapped.
                if (series.lag! >= 0) ...[
                  otherChartSeries,
                  tfrChartSeries
                ] else ...[
                  tfrChartSeries,
                  otherChartSeries
                ],
              ],
              enableAxisAnimation: false,
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              title: ChartTitle(text: 'Lineární regrese'),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                decimalPlaces: 2,
                activationMode: ActivationMode.singleTap,
                animationDuration: 0,
                duration: 0,
              ),
              primaryXAxis: NumericAxis(
                name: 'TFR',
                title: AxisTitle(text: 'TFR'),
                minimum: minTfrAxisValue,
                maximum: maxTfrAxisValue,
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: 'Ukazatel'),
                minimum: minSeriesAxisValue,
                maximum: maxSeriesAxisValue,
                numberFormat: NumberFormat.compact(locale: 'cs_CZ'),
              ),
              series: <ChartSeries<dynamic, dynamic>>[
                ScatterSeries<Point, num>(
                  name: 'Ukazatel',
                  dataSource: regressionPoints,
                  xValueMapper: (point, _) => point.x,
                  yValueMapper: (point, _) => point.y,
                  animationDelay: 0,
                  animationDuration: 0,
                  color: CustomTheme.of(context).colors.tfrColor,
                ),
                LineSeries<Point, num>(
                  name: 'Regresní přímka',
                  dataSource: regressionLine,
                  xValueMapper: (point, _) => point.x,
                  yValueMapper: (point, _) => point.y,
                  animationDelay: 0,
                  animationDuration: 0,
                  color: CustomTheme.of(context).colors.correlationColor,
                ),
              ],
              enableAxisAnimation: false,
            ),
          ),
        ],
      );
    } catch (e) {
      // Series can't be plotted.
      return const Center(child: Text('Korelaci nelze zobrazit'));
    }
  }
}
