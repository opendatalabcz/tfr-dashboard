import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences.dart';

final preferencesRepositoryProvider =
    FutureProvider<PreferencesRepository>((ref) async {
  final sharedPrefs = await SharedPreferences.getInstance();

  return PreferencesRepository(sharedPrefs);
});
