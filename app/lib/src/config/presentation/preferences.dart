import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/providers.dart';

class PreferencesPage extends ConsumerStatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const PreferencesPage());

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  final TextEditingController _transactionsDirController =
      TextEditingController();

  @override
  void dispose() {
    _transactionsDirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení')),
      body: ListView(
        children: [
          const ListTile(
            // leading: Icon(Icons.format_paint),
            title: Text('Barevné schéma'),
          ),
          RadioListTile<ThemeMode>(
            groupValue: themeMode,
            value: ThemeMode.system,
            title: const Text('Podle systému'),
            onChanged: (ThemeMode? value) {
              ref.read(preferencesProvider.notifier).setThemeMode(value!);
            },
          ),
          RadioListTile<ThemeMode>(
            groupValue: themeMode,
            value: ThemeMode.light,
            title: const Text('Světlé'),
            onChanged: (ThemeMode? value) {
              ref.read(preferencesProvider.notifier).setThemeMode(value!);
            },
          ),
          RadioListTile<ThemeMode>(
            groupValue: themeMode,
            value: ThemeMode.dark,
            title: const Text('Tmavé'),
            onChanged: (ThemeMode? value) {
              ref.read(preferencesProvider.notifier).setThemeMode(value!);
            },
          ),
        ],
      ),
    );
  }
}
