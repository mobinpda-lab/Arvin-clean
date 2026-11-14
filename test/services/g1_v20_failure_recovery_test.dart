import 'dart:io';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/g1_many_to_many_hierarchy_migration.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _V19FailureFixtureUser implements QueryExecutorUser {
  @override
  int get schemaVersion => 19;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}

const _failureStages = <String>[
  'before_migration',
  'after_first_junction',
  'after_second_junction',
  'after_relationship_transfer',
  'during_integrity_validation',
  'before_completion_marker',
  'after_migration_commit_before_drift_version',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final stage in _failureStages) {
    test('real Drift lifecycle rolls back or recovers after injected stage: $stage', () async {
      final directory = await Directory.systemTemp.createTemp('arvin-v20-failure-');
      final file = File('${directory.path}/failure.sqlite');
      await _createV19FailureFixture(file);

      final failing = NativeDatabase(file);
      await expectLater(
        failing.ensureOpen(
          G1DriftSchema(
            failureInjector: (actualStage) async {
              if (actualStage == stage) {
                throw StateError('injected lifecycle failure: $stage');
              }
            },
          ),
        ),
        throwsA(isA<StateError>()),
      );
      await failing.close();

      // The failed file must remain readable and must expose either the
      // untouched v19 migration boundary or the committed-but-unregistered
      // recoverable boundary. No third partially accepted state is allowed.
      final inspection = NativeDatabase(file);
      try {
        await inspection.ensureOpen(_V19FailureFixtureUser());
        expect(
          (await inspection.runSelect('PRAGMA user_version', const [])).single.values.first,
          19,
        );
        expect(
          (await inspection.runSelect(
            'SELECT id FROM tasks WHERE id = ?',
            const ['task-retry'],
          )).single['id'],
          'task-retry',
        );
        expect(
          (await inspection.runSelect('PRAGMA integrity_check', const [])).single.values.single,
          'ok',
        );

        final marker = await inspection.runSelect(
          'SELECT value FROM arvin_storage_meta WHERE key = ?',
          const [G1ManyToManyHierarchyMigration.markerKey],
        );
        final committedButUnregistered =
            stage == 'after_migration_commit_before_drift_version';

        if (committedButUnregistered) {
          expect(marker, [{'value': '20'}]);
          expect(
            await inspection.runSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('center_projects', 'project_categories', 'categories')",
              const [],
            ),
            hasLength(3),
          );
          expect(
            await inspection.runSelect(
              'SELECT center_id, project_id FROM center_projects',
              const [],
            ),
            [{'center_id': 'center-a', 'project_id': 'project-a'}],
          );
        } else {
          expect(marker, isEmpty);
          expect(
            await inspection.runSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('center_projects', 'project_categories', 'categories')",
              const [],
            ),
            isEmpty,
          );
          final columns = await inspection.runSelect("PRAGMA table_info('tasks')", const []);
          expect(columns.any((row) => row['name'] == 'center_id'), isFalse);
          expect(columns.any((row) => row['name'] == 'project_id'), isFalse);
          expect(columns.any((row) => row['name'] == 'category_id'), isFalse);
        }
      } finally {
        await inspection.close();
      }

      // Retry always uses the canonical production path. The interrupted
      // post-commit case must recognize its marker and never duplicate edges.
      final retry = NativeDatabase(file);
      try {
        await retry.ensureOpen(G1DriftSchema());
        expect((await retry.runSelect('PRAGMA user_version', const [])).single.values.first, 20);
        expect(
          await retry.runSelect(
            'SELECT value FROM arvin_storage_meta WHERE key = ?',
            const [G1ManyToManyHierarchyMigration.markerKey],
          ),
          [{'value': '20'}],
        );
        expect(
          await retry.runSelect('SELECT center_id, project_id FROM center_projects', const []),
          [{'center_id': 'center-a', 'project_id': 'project-a'}],
        );
        expect(
          (await retry.runSelect('SELECT COUNT(*) AS count FROM center_projects', const [])).single['count'],
          1,
        );
        expect(await retry.runSelect('PRAGMA foreign_key_check(center_projects)', const []), isEmpty);
        expect(await retry.runSelect('PRAGMA foreign_key_check(project_categories)', const []), isEmpty);
        expect((await retry.runSelect('PRAGMA integrity_check', const [])).single.values.single, 'ok');
      } finally {
        await retry.close();
        await directory.delete(recursive: true);
      }
    });
  }
}

Future<void> _createV19FailureFixture(File file) async {
  final source = NativeDatabase(file);
  await source.ensureOpen(_V19FailureFixtureUser());
  await source.runCustom('PRAGMA foreign_keys = ON');
  await source.runCustom('''CREATE TABLE centers(
    id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
    is_archived INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL
  )''');
  await source.runCustom('''CREATE TABLE projects(
    id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
    name TEXT NOT NULL, color_value INTEGER NOT NULL DEFAULT 4283059371,
    is_archived INTEGER NOT NULL DEFAULT 0,
    center_id TEXT NULL REFERENCES centers(id), template_id TEXT NULL,
    template_name_snapshot TEXT NULL, legacy_payload_json TEXT NULL
  )''');
  await source.runCustom('''CREATE TABLE tasks(
    id TEXT NOT NULL PRIMARY KEY, storage_ordinal INTEGER NOT NULL DEFAULT 0,
    title TEXT NOT NULL, description TEXT NOT NULL, created_at TEXT NULL,
    updated_at TEXT NULL, due_date TEXT NULL, category TEXT NULL,
    notebook_kind TEXT NULL, priority TEXT NOT NULL, archived INTEGER NOT NULL,
    trashed INTEGER NOT NULL, completed INTEGER NOT NULL, completed_at TEXT NULL,
    is_favorite INTEGER NOT NULL DEFAULT 0, recurrence_json TEXT NULL,
    legacy_payload_json TEXT NULL
  )''');
  await source.runCustom('''CREATE TABLE project_items(
    project_id TEXT NOT NULL REFERENCES projects(id),
    task_id TEXT NOT NULL REFERENCES tasks(id), ordinal INTEGER NOT NULL,
    PRIMARY KEY(project_id, task_id)
  )''');
  await source.runCustom('''CREATE TABLE taxonomy_categories(
    name TEXT NOT NULL PRIMARY KEY, created_at TEXT NOT NULL
  )''');
  await source.runCustom('''CREATE TABLE arvin_storage_meta(
    key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL
  )''');
  await source.runCustom("INSERT INTO centers VALUES ('center-a', 'مرکز الف', 0, '2026-11-01')");
  await source.runCustom("INSERT INTO projects(id, name, center_id) VALUES ('project-a', 'پروژه الف', 'center-a')");
  await source.runCustom("INSERT INTO tasks(id, title, description, priority, archived, trashed, completed) VALUES ('task-retry', 'کار بازیابی', '', 'none', 0, 0, 0)");
  await source.runCustom("INSERT INTO project_items VALUES ('project-a', 'task-retry', 0)");
  await source.runCustom("INSERT INTO taxonomy_categories VALUES ('عملیات', '2026-11-01')");
  await source.close();
}
