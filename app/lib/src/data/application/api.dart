import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tfr_dashboard/src/data/data.dart';
import 'package:tfr_dashboard/src/data/infrastructure/api.dart';

final apiAvailableProvider = FutureProvider((ref) async {
  return await TfrApi.isApiAvailable();
});

// Region

final regionsProvider = FutureProvider((ref) async {
  return await TfrApi.allRegions();
});

final regionsCountProvider = FutureProvider((ref) async {
  return await TfrApi.regionsCount();
});

final correlationsInRegionCountProvider =
    FutureProvider.family((ref, String? regionId) async {
  if (regionId == null) {
    return 0;
  }

  return await TfrApi.correlationsInRegionCount(regionId)
      .then((value) => value);
});

final currentTfrInRegionProvider =
    FutureProvider.family((ref, String? regionId) async {
  if (regionId == null) {
    return 0;
  }

  final timeSeries = await ref.watch(timeSeriesProvider(
    TimeSeriesAddress(datasetId: TfrApi.tfrDatasetId, regionId: regionId),
  ).future);

  return timeSeries.lastValue;
});

final tfrDifferenceProvider =
    FutureProvider.family((ref, String? regionId) async {
  if (regionId == null) {
    return 0;
  }

  final timeSeries = await ref.watch(timeSeriesProvider(
    TimeSeriesAddress(datasetId: TfrApi.tfrDatasetId, regionId: regionId),
  ).future);

  return timeSeries.difference;
});

// Data sources
final dataSourcesProvider = FutureProvider((ref) async {
  return await TfrApi.allDataSources();
});

final dataSourceProvider = FutureProvider.family((ref, String id) async {
  final dataSources = await ref.watch(dataSourcesProvider.future);
  return dataSources.firstWhere((ds) => ds.id == id);
});

final datasetsInDataSourceCountProvider =
    FutureProvider.family((ref, String dataSourceId) async {
  return await TfrApi.datasetsInDataSourceCount(dataSourceId);
});

// Datasets
final datasetProvider = FutureProvider.family((ref, String datasetId) async {
  return await TfrApi.singleDataset(datasetId);
});

final datasetsInDataSourceProvider =
    FutureProvider.family((ref, String dataSourceId) async {
  return await TfrApi.datasetsInDataSource(dataSourceId);
});

final datasetsCountProvider = FutureProvider((ref) async {
  return await TfrApi.datasetsCount();
});

// Time series

final timeSeriesProvider =
    FutureProvider.family((ref, TimeSeriesAddress address) async {
  if (address.datasetId == null || address.regionId == null) {
    throw const ArgumentException();
  }
  return await TfrApi.singleTimeSeries(address);
});

final timeSeriesCountProvider = FutureProvider((ref) async {
  return await TfrApi.timeSeriesCount();
});

final correlationsCountProvider = FutureProvider((ref) async {
  return await TfrApi.correlationsCount();
});

class ArgumentException implements Exception {
  const ArgumentException();
}
