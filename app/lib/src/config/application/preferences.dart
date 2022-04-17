import 'dart:async';

import 'package:flutter/material.dart';

import '../infrastructure/preferences.dart';

class Preferences extends ChangeNotifier {
  bool _isInitialized = false;
  late final PreferencesRepository _repository;

  ThemeMode themeMode;

  final Completer<String> _saveDirectoryPathCompleter;
  late Future<String> saveDirectoryPath;

  Preferences({required Future<PreferencesRepository> repository})
      : themeMode = ThemeMode.system,
        _saveDirectoryPathCompleter = Completer<String>() {
    saveDirectoryPath = _saveDirectoryPathCompleter.future;
    init(repository);
  }

  void init(Future<PreferencesRepository> repository) async {
    _repository = await repository;

    themeMode = _repository.getThemeMode();

    notifyListeners();

    _isInitialized = true;
  }

  void setThemeMode(ThemeMode mode) {
    if (_isInitialized) {
      _repository.setThemeMode(mode);
      themeMode = mode;
      notifyListeners();
    }
  }
}
