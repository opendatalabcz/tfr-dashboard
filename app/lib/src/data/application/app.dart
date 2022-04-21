import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the currently selected region's ID.
final selectedRegionIdProvider = StateProvider<String?>((ref) {
  return 'wld';
});

/// Provides the currently selected dataset's ID.
///
/// It's autodisposable so that the selection from previously visited (another)
/// data source page is not shown in the current page.
final selectedDatasetIdProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});
