import 'dart:convert';
import 'dart:io';

import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  test('real file-backed v8 Center and Project links migrate to v9 M2M and survive retry/reopen', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-v8-v9b-file-');
    final file = File('${directory.path}/canonical-v8.sqlite');
    NativeDatabase? database;

    Future<void> createV8Fixture() async {
      database = NativeDatabase(file);
      // Open the executor, then install the exact v8 source table shapes used
      // by the historical schema. The fixture deliberately includes the
      // pre-existing Center catalog and nullable Project.center_id FK.
      await database!.ensureOpen(G1DriftSchema());
      await database!.runCustom('PRAGMA foreign_keys = ON');
      await database!.runCustom('''
        CREATE TABLE tasks (
          id TEXT NOT NULL PRIMARY KEY,
          storage_ordinal INTEGER NOT NULL DEFAULT 0,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          created_at TEXT NULL,
          updated_at TEXT NULL,
          due_date TEXT NULL,
          follow_up_enabled INTEGER NOT NULL,
          follow_up_date TEXT NULL,
          category TEXT NULL,
          notebook_kind TEXT NULL,
          reminder_date TEXT NULL,
          priority TEXT NOT NULL,
          archived INTEGER NOT NULL,
          trashed INTEGER NOT NULL,
          completed INTEGER NOT NULL,
          completed_at TEXT NULL,
          recurrence_json TEXT NULL,
          legacy_payload_json TEXT NULL
        )
      ''');
      await database!.runCustom('''
        CREATE TABLE centers (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          is_archived INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
      await database!.runCustom('''
        CREATE TABLE projects (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          color_value INTEGER NOT NULL DEFAULT 4283059371,
          is_archived INTEGER NOT NULL DEFAULT 0,
          center_id TEXT NULL REFERENCES centers(id),
          template_id TEXT NULL,
          template_name_snapshot TEXT NULL,
          legacy_payload_json TEXT NULL
        )
      ''');
      await database!.runCustom('''
        CREATE TABLE project_items (
          project_id TEXT NOT NULL REFERENCES projects(id),
          task_id TEXT NOT NULL REFERENCES tasks(id),
          ordinal INTEGER NOT NULL,
          PRIMARY KEY (project_id, task_id)
        )
      ''');
      await database!.runCustom('''
        CREATE TABLE taxonomy_categories (
          name TEXT NOT NULL PRIMARY KEY,
          created_at TEXT NOT NULL
        )
      ''');
      await database!.runCustom('''
        CREATE TABLE arvin_storage_meta (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      await database!.runCustom(
        "INSERT INTO centers (id, name, is_archived, created_at) VALUES "
        "('center-v8-a', 'مرکز الف', 0, '2026-11-01T08:00:00.000Z'), "
        "('center-v8-b', 'مرکز ب', 1, '2026-11-02T08:00:00.000Z')",
      );
      // Reproduce a legacy orphaned reference without weakening the
      // migration's own foreign-key enforcement.
      await database!.runCustom('PRAGMA foreign_keys = OFF');
      await database!.runCustom(
        "INSERT INTO projects (id, name, is_archived, center_id, template_id, template_name_snapshot, legacy_payload_json) VALUES "
        "('project-v8-a', 'پروژه الف', 0, 'center-v8-a', 'template-legacy', 'الگوی قدیمی', '{\"unknownProjectField\":{\"keep\":true}}'), "
        "('project-v8-b', 'پروژه ب', 0, 'center-v8-a', NULL, NULL, NULL), "
        "('project-v8-c', 'پروژه ج', 1, 'center-v8-b', NULL, NULL, NULL), "
        "('project-v8-missing-center', 'پروژه با مرکز مفقود', 0, 'center-v8-missing', NULL, NULL, NULL), "
        "('project-v8-missing-center-b', 'پروژه با مرکز دوم مفقود', 0, 'center-v8-missing-b', NULL, NULL, NULL), "
        "('project-v8-null-center', 'پروژه بدون مرکز', 0, NULL, NULL, NULL, NULL)",
      );
      await database!.runCustom('PRAGMA foreign_keys = ON');
      await database!.runCustom(
        "INSERT INTO tasks (id, title, description, follow_up_enabled, category, priority, archived, trashed, completed) "
        "VALUES ('task-v8-a', 'کار تاریخی', '', 0, 'شخصی', 'none', 0, 0, 0)",
      );
      await database!.runCustom(
        "INSERT INTO project_items (project_id, task_id, ordinal) VALUES ('project-v8-a', 'task-v8-a', 4)",
      );
      await database!.runCustom(
        "INSERT INTO taxonomy_categories (name, created_at) VALUES ('قدیمی', '2026-11-01T00:00:00.000Z')",
      );
      // Record the fixture's actual source version independently from the
      // target Drift schema version used to open the executor.
      await database!.runCustom('PRAGMA user_version = 8');
    }

    Future<void> resetV8Database() async {
      await database?.close();
      if (await file.exists()) await file.delete();
      await createV8Fixture();
      await database!.close();
      database = NativeDatabase(file);
    }

    try {
      // Each injected failure gets a fresh physical v8 database. Every stage
      // must roll back the preservation column, relationship tables, exception
      // ledger and completion marker as one atomic migration transaction.
      for (final failureStage in <String>[
        'after_legacy_relationship_transfer',
        'during_exception_insert',
        'after_exception_insert',
        'before_completion_marker',
      ]) {
        await resetV8Database();
        await expectLater(
          G1DriftSchema.install(
            database!,
            failureInjector: (stage) {
              if (stage == failureStage) {
                throw StateError('injected v8→v9 failure at $failureStage');
              }
            },
          ),
          throwsA(isA<StateError>()),
        );
        final centerColumns = await database!.runSelect(
          "PRAGMA table_info('centers')",
          const [],
        );
        expect(centerColumns.map((row) => row['name']), isNot(contains('updated_at')));
        final projectColumns = await database!.runSelect(
          "PRAGMA table_info('projects')",
          const [],
        );
        expect(projectColumns.map((row) => row['name']), isNot(contains('legacy_center_id')));
        final rolledBackLinks = await database!.runSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'center_projects'",
          const [],
        );
        expect(rolledBackLinks, isEmpty);
        final rolledBackExceptions = await database!.runSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'arvin_migration_exceptions'",
          const [],
        );
        expect(rolledBackExceptions, isEmpty);
        final rolledBackMarker = await database!.runSelect(
          "SELECT value FROM arvin_storage_meta WHERE key = 'rev10_hierarchy_schema_version'",
          const [],
        );
        expect(rolledBackMarker, isEmpty);
        final originalOrphan = await database!.runSelect(
          "SELECT center_id FROM projects WHERE id = 'project-v8-missing-center'",
          const [],
        );
        expect(originalOrphan.single['center_id'], 'center-v8-missing');
      }

      // Retry successfully on a fresh copy of the same historical fixture.
      await resetV8Database();
      await G1DriftSchema.install(database!);
      final links = await database!.runSelect(
        'SELECT center_id, project_id FROM center_projects ORDER BY center_id, project_id',
        const [],
      );
      expect(links, hasLength(3));
      final preservedMissingProject = await database!.runSelect(
        "SELECT id, center_id, legacy_center_id FROM projects WHERE id = 'project-v8-missing-center'",
        const [],
      );
      expect(preservedMissingProject, hasLength(1));
      expect(preservedMissingProject.single['center_id'], isNull);
      expect(preservedMissingProject.single['legacy_center_id'], 'center-v8-missing');
      final missingCenterExceptions = await database!.runSelect(
        """SELECT entity_type, entity_id, code, details_json
           FROM arvin_migration_exceptions
           WHERE migration_key = 'rev10_hierarchy_schema_version'
             AND entity_type = 'project'
             AND code = 'PROJECT_CENTER_REFERENCE_MISSING'
           ORDER BY entity_id""",
        const [],
      );
      expect(missingCenterExceptions, hasLength(2));
      expect(
        missingCenterExceptions.map((row) => row['entity_id']).toList(),
        <String>['project-v8-missing-center', 'project-v8-missing-center-b'],
      );
      final exceptionDetails = <String, Map<String, dynamic>>{
        for (final row in missingCenterExceptions)
          row['entity_id'] as String:
              jsonDecode(row['details_json'] as String) as Map<String, dynamic>,
      };
      expect(exceptionDetails['project-v8-missing-center']!['historicalCenterId'], 'center-v8-missing');
      expect(exceptionDetails['project-v8-missing-center-b']!['historicalCenterId'], 'center-v8-missing-b');
      for (final details in exceptionDetails.values) {
        expect(details['sourceEntity'], 'projects');
        expect(details['migrationVersion'], 9);
        expect(details['exceptionType'], 'MissingHistoricalCenter');
        expect(details['recoveryStatus'], 'pending');
      }
      expect(
        await database!.runSelect('PRAGMA foreign_key_check', const []),
        isEmpty,
      );
      expect(links.map((row) => '${row['center_id']}:${row['project_id']}'), <String>[
        'center-v8-a:project-v8-a',
        'center-v8-a:project-v8-b',
        'center-v8-b:project-v8-c',
      ]);

      centerColumns = await database!.runSelect(
        "PRAGMA table_info('centers')",
        const [],
      );
      expect(centerColumns.map((row) => row['name']), contains('updated_at'));
      final centerRows = await database!.runSelect(
        'SELECT id, created_at, updated_at FROM centers ORDER BY id',
        const [],
      );
      expect(centerRows, hasLength(2));
      for (final row in centerRows) {
        expect(row['updated_at'], row['created_at']);
      }

      final oldProjectColumns = await database!.runSelect(
        "PRAGMA table_info('projects')",
        const [],
      );
      expect(oldProjectColumns.map((row) => row['name']), contains('center_id'));
      final legacyCenterColumn = oldProjectColumns.singleWhere(
        (row) => row['name'] == 'legacy_center_id',
      );
      expect(legacyCenterColumn['type'], 'TEXT');
      expect((legacyCenterColumn['notnull'] as num).toInt(), 0);
      expect((legacyCenterColumn['pk'] as num).toInt(), 0);
      final projectForeignKeys = await database!.runSelect(
        "PRAGMA foreign_key_list('projects')",
        const [],
      );
      expect(
        projectForeignKeys.any((row) => row['from'] == 'legacy_center_id'),
        isFalse,
      );
      final oldProjectLinks = await database!.runSelect(
        'SELECT id, center_id FROM projects ORDER BY id',
        const [],
      );
      // All six source Projects survive. Only the two orphaned FK edges
      // are cleared; their original IDs remain in legacy_center_id and the
      // exception ledger. An explicitly NULL Center remains NULL.
      expect(oldProjectLinks, hasLength(6));
      final orphanedProject = oldProjectLinks.singleWhere(
        (row) => row['id'] == 'project-v8-missing-center',
      );
      expect(orphanedProject['center_id'], isNull);
      final secondOrphanedProject = oldProjectLinks.singleWhere(
        (row) => row['id'] == 'project-v8-missing-center-b',
      );
      expect(secondOrphanedProject['center_id'], isNull);
      final noCenterProject = oldProjectLinks.singleWhere(
        (row) => row['id'] == 'project-v8-null-center',
      );
      expect(noCenterProject['center_id'], isNull);
      final preservedIds = await database!.runSelect(
        "SELECT id, legacy_center_id FROM projects WHERE id IN ('project-v8-missing-center', 'project-v8-missing-center-b', 'project-v8-null-center') ORDER BY id",
        const [],
      );
      expect(
        preservedIds.map((row) => row['legacy_center_id']).toList(),
        <Object?>['center-v8-missing', 'center-v8-missing-b', null],
      );
      final archivedProject = await database!.runSelect(
        "SELECT is_archived FROM projects WHERE id = 'project-v8-c'",
        const [],
      );
      expect((archivedProject.single['is_archived'] as num).toInt(), 1);
      final activeProject = await database!.runSelect(
        "SELECT is_archived FROM projects WHERE id = 'project-v8-a'",
        const [],
      );
      expect((activeProject.single['is_archived'] as num).toInt(), 0);

      final membership = await database!.runSelect(
        'SELECT ordinal FROM project_items WHERE project_id = ? AND task_id = ?',
        const <Object?>['project-v8-a', 'task-v8-a'],
      );
      expect(membership.single['ordinal'], 4);
      final task = await database!.runSelect(
        'SELECT id, title, category FROM tasks WHERE id = ?',
        const <Object?>['task-v8-a'],
      );
      expect(task.single['title'], 'کار تاریخی');
      expect(task.single['category'], 'شخصی');

      final centerStore = CenterStore(executor: database);
      final center = await centerStore.findById('center-v8-a');
      expect(center, isNotNull);
      expect(center!.updatedAt, DateTime.parse('2026-11-01T08:00:00.000Z'));
      expect(await centerStore.projectIdsForCenter('center-v8-a'),
          <String>['project-v8-a', 'project-v8-b']);
      expect(await centerStore.centerIdsForProject('project-v8-c'),
          <String>['center-v8-b']);

      await database!.close();
      database = NativeDatabase(file);
      await G1DriftSchema.install(database!);
      await G1DriftSchema.install(database!);

      final reopenedLinks = await database!.runSelect(
        'SELECT center_id, project_id FROM center_projects ORDER BY center_id, project_id',
        const [],
      );
      expect(reopenedLinks, hasLength(3));
      expect(
        await database!.runSelect('PRAGMA integrity_check', const []),
        isNotEmpty,
      );
      expect(
        (await database!.runSelect('PRAGMA integrity_check', const [])).single.values.first,
        'ok',
      );
      expect(await database!.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
      final reopenedLegacyIds = await database!.runSelect(
        "SELECT id, legacy_center_id FROM projects WHERE id IN ('project-v8-missing-center', 'project-v8-missing-center-b') ORDER BY id",
        const [],
      );
      expect(
        reopenedLegacyIds.map((row) => row['legacy_center_id']).toList(),
        <String>['center-v8-missing', 'center-v8-missing-b'],
      );
      final exceptionsAfterDuplicateInstall = await database!.runSelect(
        """SELECT entity_id FROM arvin_migration_exceptions
           WHERE migration_key = 'rev10_hierarchy_schema_version'
             AND code = 'PROJECT_CENTER_REFERENCE_MISSING'""",
        const [],
      );
      expect(exceptionsAfterDuplicateInstall, hasLength(2));
      final marker = await database!.runSelect(
        "SELECT value FROM arvin_storage_meta WHERE key = 'rev10_hierarchy_schema_version'",
        const [],
      );
      expect(marker.single['value'], '9');
    } finally {
      await database?.close();
      await directory.delete(recursive: true);
    }
  });

  test('v8 upgrade adds legacy_center_id when every historical Center link is valid', () async {
  final directory = await Directory.systemTemp.createTemp('arvin-v8-v9-valid-center-');
  final file = File('${directory.path}/canonical-v8-valid.sqlite');
  var database = NativeDatabase(file);
  try {
    await database.ensureOpen(G1DriftSchema());
    await database.runCustom('PRAGMA foreign_keys = ON');
    await database.runCustom('''
      CREATE TABLE tasks (
        id TEXT NOT NULL PRIMARY KEY,
        category TEXT NULL
      )
    ''');
    await database.runCustom('''
      CREATE TABLE centers (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await database.runCustom('''
      CREATE TABLE projects (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        center_id TEXT NULL REFERENCES centers(id)
      )
    ''');
    await database.runCustom('''
      CREATE TABLE project_items (
        project_id TEXT NOT NULL REFERENCES projects(id),
        task_id TEXT NOT NULL REFERENCES tasks(id),
        ordinal INTEGER NOT NULL,
        PRIMARY KEY (project_id, task_id)
      )
    ''');
    await database.runCustom('''
      CREATE TABLE taxonomy_categories (
        name TEXT NOT NULL PRIMARY KEY,
        created_at TEXT NOT NULL
      )
    ''');
    await database.runCustom('''
      CREATE TABLE arvin_storage_meta (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await database.runCustom(
      "INSERT INTO centers (id, name, created_at) VALUES ('valid-center', 'مرکز معتبر', '2026-11-01T08:00:00.000Z')",
    );
    await database.runCustom(
      "INSERT INTO projects (id, name, center_id) VALUES ('valid-project', 'پروژه معتبر', 'valid-center')",
    );

    await G1DriftSchema.install(database);

    final columns = await database.runSelect(
      "PRAGMA table_info('projects')",
      const [],
    );
    expect(columns.map((row) => row['name']), contains('legacy_center_id'));
    final project = await database.runSelect(
      "SELECT id, center_id, legacy_center_id FROM projects WHERE id = 'valid-project'",
      const [],
    );
    expect(project, hasLength(1));
    expect(project.single['center_id'], 'valid-center');
    expect(project.single['legacy_center_id'], isNull);
    final links = await database.runSelect(
      "SELECT center_id, project_id FROM center_projects",
      const [],
    );
    expect(links, hasLength(1));
    expect(links.single['center_id'], 'valid-center');
    expect(links.single['project_id'], 'valid-project');
    expect(await database.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
  } finally {
    await database.close();
    await directory.delete(recursive: true);
  }
});
}
