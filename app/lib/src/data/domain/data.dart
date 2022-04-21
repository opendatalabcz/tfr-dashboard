import 'dart:collection';

typedef DoubleSeries = LinkedHashMap<String, double>;
typedef BoolSeries = LinkedHashMap<String, bool>;

class Region {
  final String id;
  final String name;

  const Region({
    required this.id,
    required this.name,
  });

  factory Region.fromMap(Map<String, dynamic> map) {
    return Region(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }

  @override
  String toString() => 'Region(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Region && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class DataSource {
  final String id;
  final String name;
  final String description;
  final String url;

  const DataSource({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
  });

  factory DataSource.fromMap(Map<String, dynamic> map) {
    return DataSource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
    );
  }

  @override
  String toString() {
    return 'DataSource(id: $id, name: $name, description: $description, url: $url)';
  }
}

class Dataset {
  final String id;
  final String dataSourceId;
  final String name;
  final String description;
  final String url;
  final String unit;

  final DoubleSeries pValuesPerYear;
  final DoubleSeries rValuesPerYear;
  final BoolSeries correlationValuesPerYear;

  const Dataset({
    required this.id,
    required this.dataSourceId,
    required this.name,
    required this.description,
    required this.url,
    required this.unit,
    required this.pValuesPerYear,
    required this.rValuesPerYear,
    required this.correlationValuesPerYear,
  });

  factory Dataset.fromMap(Map<String, dynamic> map) {
    return Dataset(
      id: map['id'] ?? '',
      dataSourceId: map['data_source'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      unit: map['unit'] ?? '',
      pValuesPerYear: DoubleSeries.from(map['p_values_per_year']),
      rValuesPerYear: DoubleSeries.from(map['r_values_per_year']),
      correlationValuesPerYear:
          BoolSeries.from(map['correlation_values_per_year']),
    );
  }

  @override
  String toString() {
    return 'Dataset(id: $id, dataSourceId: $dataSourceId, name: $name, description: $description, url: $url, unit: $unit, pValuesPerYear: $pValuesPerYear, rValuesPerYear: $rValuesPerYear, correlationValuesPerYear: $correlationValuesPerYear)';
  }
}

/// Helper for passing time series compound id to providers.
class TimeSeriesAddress {
  final String? datasetId;
  final String? regionId;

  const TimeSeriesAddress({
    required this.datasetId,
    required this.regionId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimeSeriesAddress &&
        other.datasetId == datasetId &&
        other.regionId == regionId;
  }

  @override
  int get hashCode => datasetId.hashCode ^ regionId.hashCode;
}

class TimeSeries {
  final String datasetId;
  final String regionId;

  final DoubleSeries series;
  final int lag;
  final double slope;
  final double intercept;
  final double rValue;
  final double pValue;
  final double stdErr;
  final bool correlation;

  double get lastValue => series.isNotEmpty ? series.entries.last.value : 0;
  double get difference => series.isNotEmpty
      ? series.entries.last.value - series.entries.first.value
      : 0;

  const TimeSeries({
    required this.datasetId,
    required this.regionId,
    required this.series,
    required this.lag,
    required this.slope,
    required this.intercept,
    required this.rValue,
    required this.pValue,
    required this.stdErr,
    required this.correlation,
  });

  factory TimeSeries.fromMap(Map<String, dynamic> map) {
    return TimeSeries(
      datasetId: map['dataset'] ?? '',
      regionId: map['region'] ?? '',
      series: DoubleSeries.from(map['series']),
      lag: map['lag']?.toInt() ?? 0,
      slope: map['slope']?.toDouble() ?? 0.0,
      intercept: map['intercept']?.toDouble() ?? 0.0,
      rValue: map['rValue']?.toDouble() ?? 0.0,
      pValue: map['pValue']?.toDouble() ?? 0.0,
      stdErr: map['stdErr']?.toDouble() ?? 0.0,
      correlation: map['correlation'] ?? false,
    );
  }

  @override
  String toString() {
    return 'TimeSeries(datasetId: $datasetId, regionId: $regionId, series: $series, lag: $lag, slope: $slope, intercept: $intercept, rValue: $rValue, pValue: $pValue, stdErr: $stdErr, correlation: $correlation)';
  }
}
