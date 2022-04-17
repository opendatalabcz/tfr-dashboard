import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/providers.dart';
import 'preferences.dart';

final preferencesProvider = ChangeNotifierProvider<Preferences>((ref) {
  final preferencesRepository = ref.watch(preferencesRepositoryProvider.future);

  return Preferences(repository: preferencesRepository);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final preferences = ref.watch(preferencesProvider);

  return preferences.themeMode;
});
