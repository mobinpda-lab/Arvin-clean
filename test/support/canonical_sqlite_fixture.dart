import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/center_store.dart';

/// Seeds UI tests through the supported one-time legacy-to-SQLite migration.
///
/// Preference-shaped fixtures are installed before the stores are initialized.
/// Each store then migrates the fixture into its own test SQLite executor,
/// matching the production read path without treating SharedPreferences as
/// live storage during the widget assertions.
Future<void> setCanonicalSqliteFixture(Map<String, Object?> values) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await TaskStore.resetTestDatabase();
  await ProjectStore.resetTestDatabase();
  await CenterStore.resetTestDatabase();

  final preferences = await SharedPreferences.getInstance();
  await preferences.clear();
  for (final entry in values.entries) {
    final value = entry.value;
    if (value is String) {
      await preferences.setString(entry.key, value);
    } else if (value is bool) {
      await preferences.setBool(entry.key, value);
    } else if (value is int) {
      await preferences.setInt(entry.key, value);
    } else if (value is double) {
      await preferences.setDouble(entry.key, value);
    } else if (value is List<String>) {
      await preferences.setStringList(entry.key, value);
    } else {
      throw ArgumentError.value(
        value,
        entry.key,
        'Unsupported UI test preference value',
      );
    }
  }

  // Initialize/migrate both canonical stores before mounting the widget. The
  // stores have separate in-memory test executors, so each must migrate from
  // the same fixture to preserve Task and Project identity consistently.
  await TaskStore().load();
  await ProjectStore().load();
  await CenterStore().load();
}
