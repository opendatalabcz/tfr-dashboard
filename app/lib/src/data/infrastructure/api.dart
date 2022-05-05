import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tfr_dashboard/src/data/data.dart';

/// Wrapper around the TFR REST API providing asynchronous requests with results
/// mapped to DTOs.
/// Supports partial response caching.
class TfrApi {
  static final Uri _apiRoot = Uri.parse('http://127.0.0.1:5051/');

  static const String tfrDatasetId = 'tfr';

  static final Map<String, Region> _regionCache = {};
  static final Map<String, DataSource> _dataSourceCache = {};
  static final Map<String, Dataset> _datasetCache = {};
  static final Map<TimeSeriesAddress, TimeSeries> _timeSeriesCache = {};

  static Future<bool> isApiAvailable() async {
    try {
      await _getResultsJson(path: '');
      return true;
    } on ApiUnavailableException {
      return false;
    }
  }

  // All entities of a type.

  static Future<List<Region>> allRegions() async {
    try {
      final response = await _getResultsJson(path: 'region');
      final results = (response as List).map((e) => Region.fromMap(e)).toList();
      _regionCache.addEntries(results.map((e) => MapEntry(e.id, e)));
      return results;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<List<DataSource>> allDataSources() async {
    try {
      final response = await _getResultsJson(path: 'data_source');
      final results =
          (response as List).map((e) => DataSource.fromMap(e)).toList();
      _dataSourceCache.addEntries(results.map((e) => MapEntry(e.id, e)));
      return results;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  // Single entity of a type.

  static Future<Region> singleRegion(String regionId) async {
    final result = _regionCache[regionId];
    if (result != null) {
      return result;
    }
    try {
      final response = await _getResultsJson(
        path: 'region',
        queryParameters: {
          'id': 'eq.$regionId',
        },
      );
      final result = Region.fromMap(response[0]);
      _regionCache.addAll({regionId: result});
      return result;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<Dataset> singleDataset(String datasetId) async {
    final result = _datasetCache[datasetId];
    if (result != null) {
      return result;
    }
    try {
      final response = await _getResultsJson(
        path: 'dataset',
        queryParameters: {
          'id': 'eq.$datasetId',
        },
      );
      final result = Dataset.fromMap(response[0]);
      _datasetCache.addAll({datasetId: result});
      return result;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<TimeSeries> singleTimeSeries(TimeSeriesAddress address) async {
    final result = _timeSeriesCache[address];
    if (result != null) {
      return result;
    }
    try {
      final response = await _getResultsJson(
        path: 'time_series',
        queryParameters: {
          'dataset': 'eq.${address.datasetId}',
          'region': 'eq.${address.regionId}',
        },
      );
      final result = TimeSeries.fromMap(response[0]);
      _timeSeriesCache.addAll({address: result});
      return result;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  // Entity by foreign ID or IDs.

  /// Get all regions the selected dataset has time series for.
  static Future<List<Region>> regionsForDataset(String datasetId) async {
    try {
      // Fetch time series for the dataset.
      final response = await _getResultsJson(
        path: 'time_series',
        queryParameters: {
          'dataset': 'eq.$datasetId',
        },
      );
      final timeSeriesList =
          (response as List).map((e) => TimeSeries.fromMap(e)).toList();
      _timeSeriesCache.addEntries(timeSeriesList.map((e) => MapEntry(
          TimeSeriesAddress(datasetId: e.datasetId, regionId: e.regionId), e)));
      // Fetch regions by IDs.
      final List<Region> regions = [];
      for (final timeSeries in timeSeriesList) {
        regions.add(await singleRegion(timeSeries.regionId));
      }
      return regions;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  /// Get all regions the selected dataset has correlating time series for.
  static Future<List<Region>> correlatingRegionsForDataset(
      String datasetId) async {
    try {
      // Fetch time series for the dataset.
      final response = await _getResultsJson(
        path: 'time_series',
        queryParameters: {
          'dataset': 'eq.$datasetId',
          'correlation': 'eq.true',
        },
      );
      final timeSeriesList =
          (response as List).map((e) => TimeSeries.fromMap(e)).toList();
      _timeSeriesCache.addEntries(timeSeriesList.map((e) => MapEntry(
          TimeSeriesAddress(datasetId: e.datasetId, regionId: e.regionId), e)));
      // Fetch regions by IDs.
      final List<Region> regions = [];
      for (final timeSeries in timeSeriesList) {
        regions.add(await singleRegion(timeSeries.regionId));
      }
      return regions;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  /// Get all regions the selected dataset does not have
  /// correlating time series for.
  static Future<List<Region>> nonCorrelatingRegionsForDataset(
      String datasetId) async {
    try {
      // Fetch time series for the dataset.
      final response = await _getResultsJson(
        path: 'time_series',
        queryParameters: {
          'dataset': 'eq.$datasetId',
          'correlation': 'eq.false',
        },
      );
      final timeSeriesList =
          (response as List).map((e) => TimeSeries.fromMap(e)).toList();
      _timeSeriesCache.addEntries(timeSeriesList.map((e) => MapEntry(
          TimeSeriesAddress(datasetId: e.datasetId, regionId: e.regionId), e)));
      // Fetch regions by IDs.
      final List<Region> regions = [];
      for (final timeSeries in timeSeriesList) {
        regions.add(await singleRegion(timeSeries.regionId));
      }
      return regions;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<List<Dataset>> datasetsInDataSource(String dataSourceId) async {
    try {
      final response = await _getResultsJson(
        path: 'dataset',
        queryParameters: {
          'data_source': 'eq.$dataSourceId',
        },
      );
      final results =
          (response as List).map((e) => Dataset.fromMap(e)).toList();
      _datasetCache.addEntries(results.map((e) => MapEntry(e.id, e)));
      return results;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<List<Dataset>> correlatingDatasetsForRegion(
      String regionId) async {
    try {
      final response = await _getResultsJson(
        path: 'time_series',
        queryParameters: {
          'region': 'eq.$regionId',
          'correlation': 'eq.true',
        },
      );
      final timeSeriesList =
          (response as List).map((e) => TimeSeries.fromMap(e)).toList();
      _timeSeriesCache.addEntries(timeSeriesList.map((e) => MapEntry(
          TimeSeriesAddress(
            datasetId: e.datasetId,
            regionId: e.regionId,
          ),
          e)));
      // Fetch datasets by IDs.
      final List<Dataset> datasets = [];
      for (final timeSeries in timeSeriesList) {
        datasets.add(await singleDataset(timeSeries.datasetId));
      }
      return datasets;
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  // Entity counts.

  static Future<int> regionsCount() async {
    try {
      return await _getResultsCount(path: 'region');
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<int> datasetsCount() async {
    try {
      return await _getResultsCount(path: 'dataset');
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<int> timeSeriesCount() async {
    try {
      return await _getResultsCount(path: 'time_series');
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<int> timeSeriesInDatasetCount(String datasetId) async {
    try {
      return await _getResultsCount(
        path: 'time_series',
        queryParameters: {
          'dataset': 'eq.$datasetId',
        },
      );
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<int> datasetsInDataSourceCount(String dataSourceId) async {
    try {
      return await _getResultsCount(
        path: 'dataset',
        queryParameters: {
          'data_source': 'eq.$dataSourceId',
        },
      );
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<int> correlationsCount() async {
    try {
      return await _getResultsCount(
        path: 'time_series',
        queryParameters: {
          'correlation': 'eq.true',
        },
      );
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  static Future<int> correlationsInRegionCount(String regionId) async {
    try {
      return await _getResultsCount(
        path: 'time_series',
        queryParameters: {
          'region': 'eq.$regionId',
          'correlation': 'eq.true',
        },
      );
    } catch (_) {
      throw const ApiResponseException();
    }
  }

  /// Get a parsed response body from the API.
  static Future<dynamic> _getResultsJson({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    final url = _apiRoot.replace(path: path, queryParameters: queryParameters);
    try {
      final response = await http.get(url);
      return jsonDecode(response.body);
    } catch (_) {
      throw const ApiUnavailableException();
    }
  }

  /// Get the count of objects matching the query to the API.
  static Future<int> _getResultsCount({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    final url = _apiRoot.replace(path: path, queryParameters: queryParameters);
    try {
      final response = await http.head(
        url,
        headers: {'Prefer': 'count=exact'},
      );
      return int.tryParse(response.headers['content-range']!.split('/').last) ??
          0;
    } catch (_) {
      throw const ApiUnavailableException();
    }
  }
}

class ApiUnavailableException implements Exception {
  const ApiUnavailableException();
}

class ApiResponseException implements Exception {
  const ApiResponseException();
}
