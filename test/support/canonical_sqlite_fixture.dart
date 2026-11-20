import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_plan_codec.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/center_store.dart';

/// Seeds UI tests through Arvin's canonical SQLite stores.
///
/// Legacy preference-shaped fixtures remain convenient to author, but they
/// must not be mistaken for the app's live storage after the one-time
/// SharedPreferences migration has completed.
Future<void> setCanonicalSqliteFixture(Map<String, Object?> values) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.clear();

  await TaskStore.resetTestDatabase();
  await ProjectStore.resetTestDatabase();
  await CenterStore.resetTestDatabase();

  // Initialize an empty canonical database before inserting fixture data.
  // This prevents a previous test's one-time legacy migration marker or
  // cached preferences from deciding which rows the UI sees.
  await TaskStore().save(const <Task>[]);

  final rawTasks = values['arvin.tasks'];
  if (rawTasks is String && rawTasks.trim().isNotEmpty) {
    final decoded = jsonDecode(rawTasks);
    if (decoded is! List) {
      throw const FormatException('UI test Task fixture must be a JSON list');
    }
    final tasks = decoded.map((raw) {
      if (raw is! Map) {
        throw const FormatException('UI test Task fixture entries must be objects');
      }
      return Task.fromLegacyJson(Map<String, dynamic>.from(raw));
    }).toList(growable: false);
    await TaskStore().save(tasks);
  }

  final rawProjects = values['arvin.projects'];
  if (rawProjects is String && rawProjects.trim().isNotEmpty) {
    final decoded = jsonDecode(rawProjects);
    final projects = const ProjectPlanCodec().decodeList(decoded);
    await ProjectStore().save(projects);
  } else {
    await ProjectStore().save(const []);
  }

  // Keep ordinary preference fixtures (theme, onboarding, settings, etc.)
  // while keeping canonical task/project payloads in their SQLite stores.
  const canonicalKeys = <String>{
    'arvin.tasks',
    'arvin.projects',
    'arvin.categories',
    'arvin.tags',
  };
  for (final entry in values.entries) {
    if (canonicalKeys.contains(entry.key)) continue;
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
      throw ArgumentError.value(value, entry.key, 'Unsupported UI test preference value');
    }
  }
}
