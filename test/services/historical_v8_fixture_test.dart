import 'dart:convert';
import 'dart:io';

import 'package:arvin/services/g1_drift_schema.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('independent historical v8 DDL fixture matches fingerprint and executes all tables', () async {
    final fixture = File(
      'test/fixtures/database/historical/v8_schema.sql',
    );
    final bytes = await fixture.readAsBytes();
    final fingerprint = (await Sha256().hash(bytes))
        .bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    expect(
      fingerprint,
      '9a11f8952cf1d11bebd020a785021e7f051410580762a6b78276b7b0f89dc2ba',
    );

    final database = NativeDatabase.memory();
    try {
      // Open only the low-level executor. No current-schema installer is run;
      // every application table below comes from the historical SQL fixture.
      await database.ensureOpen(G1DriftSchema());
      final sql = utf8.decode(bytes);
      // Remove full-line SQL comments before splitting statements. A comment
      // may itself contain semicolons; splitting first would turn its tail
      // into executable SQL (for example, "not generated from current schema").
      final executableSql = sql
          .split('\n')
          .where((line) => !line.trimLeft().startsWith('--'))
          .join('\n');
      final statements = executableSql
          .split(';')
          .map((statement) => statement.trim())
          .where((statement) => statement.isNotEmpty);
      for (final statement in statements) {
        await database.runCustom(statement);
      }

      final tables = await database.runSelect(
        """SELECT name FROM sqlite_master
           WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
           ORDER BY name""",
        const [],
      );
      expect(tables.map((row) => row['name']), <String>[
        'arvin_storage_meta',
        'centers',
        'checklist_items',
        'follow_up_people',
        'follow_ups',
        'people',
        'project_items',
        'project_template_tasks',
        'project_templates',
        'projects',
        'tags',
        'task_people',
        'task_tags',
        'tasks',
        'taxonomy_categories',
        'template_task_applications',
      ]);

      final projectCenterForeignKey = await database.runSelect(
        "PRAGMA foreign_key_list('projects')",
        const [],
      );
      expect(
        projectCenterForeignKey.any(
          (row) => row['table'] == 'centers' && row['from'] == 'center_id',
        ),
        isTrue,
      );
      final templateForeignKey = await database.runSelect(
        "PRAGMA foreign_key_list('project_template_tasks')",
        const [],
      );
      expect(
        templateForeignKey.any(
          (row) => row['table'] == 'project_templates',
        ),
        isTrue,
      );

      final partialIndex = await database.runSelect(
        """SELECT sql FROM sqlite_master
           WHERE type = 'index'
             AND name = 'idx_projects_active_template_center'""",
        const [],
      );
      expect(partialIndex, hasLength(1));
      expect(partialIndex.single['sql'], contains(' WHERE '));
      expect(
        partialIndex.single['sql'],
        contains('is_archived = 0'),
      );
      // Fingerprint canonical SQLite metadata rather than sqlite_master SQL text.
      // SQLite versions may normalize CREATE statements differently even when
      // the resulting schema is identical. PRAGMA metadata captures columns,
      // constraints, foreign keys and index shape in a version-stable form.
      final canonicalSchema = <Map<String, Object?>>[];
      for (final tableRow in tables) {
        final tableName = tableRow['name'] as String;
        final columns = await database.runSelect(
          "PRAGMA table_info('$tableName')",
          const [],
        );
        final columnShape = columns.map((row) => <String, Object?>{
          'cid': row['cid'],
          'name': row['name'],
          'type': row['type'],
          'notnull': row['notnull'],
          'default': row['dflt_value'],
          'pk': row['pk'],
        }).toList(growable: false);
        final foreignKeys = await database.runSelect(
          "PRAGMA foreign_key_list('$tableName')",
          const [],
        );
        final foreignKeyShape = foreignKeys.map((row) => <String, Object?>{
          'id': row['id'],
          'seq': row['seq'],
          'table': row['table'],
          'from': row['from'],
          'to': row['to'],
          'onUpdate': row['on_update'],
          'onDelete': row['on_delete'],
          'match': row['match'],
        }).toList()
          ..sort((left, right) {
            final byId = (left['id'] as num).compareTo(right['id'] as num);
            return byId != 0
                ? byId
                : (left['seq'] as num).compareTo(right['seq'] as num);
          });
        final indexes = await database.runSelect(
          "PRAGMA index_list('$tableName')",
          const [],
        );
        final indexShape = <Map<String, Object?>>[];
        for (final index in indexes) {
          final indexName = index['name'] as String;
          final indexColumns = await database.runSelect(
            "PRAGMA index_xinfo('$indexName')",
            const [],
          );
          indexShape.add(<String, Object?>{
            'name': indexName,
            'unique': index['unique'],
            'origin': index['origin'],
            'partial': index['partial'],
            'columns': indexColumns.map((row) => <String, Object?>{
              'seqno': row['seqno'],
              'cid': row['cid'],
              'name': row['name'],
              'desc': row['desc'],
              'coll': row['coll'],
              'key': row['key'],
            }).toList(growable: false),
          });
        }
        indexShape.sort(
          (left, right) =>
              (left['name'] as String).compareTo(right['name'] as String),
        );
        canonicalSchema.add(<String, Object?>{
          'table': tableName,
          'columns': columnShape,
          'foreignKeys': foreignKeyShape,
          'indexes': indexShape,
        });
      }
      final structuralFingerprint = (await Sha256().hash(
        utf8.encode(jsonEncode(canonicalSchema)),
      )).bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
      expect(
        structuralFingerprint,
        'ae240d3fd9e9af95cd3f503b282d58463613373585c967f4f80525e013751463',
      );

      const expectedColumns = <String, List<String>>{
        'tasks': <String>['id', 'storage_ordinal', 'title', 'description', 'created_at', 'updated_at', 'due_date', 'follow_up_enabled', 'follow_up_date', 'category', 'notebook_kind', 'reminder_date', 'priority', 'archived', 'trashed', 'completed', 'completed_at', 'recurrence_json', 'legacy_payload_json'],
        'follow_ups': <String>['id', 'task_id', 'date_time', 'title', 'note', 'result', 'reminder_date', 'next_follow_up', 'completed', 'waiting_for_response', 'ordinal'],
        'centers': <String>['id', 'name', 'is_archived', 'created_at'],
        'project_templates': <String>['id', 'name', 'is_archived', 'created_at', 'updated_at'],
        'project_template_tasks': <String>['id', 'template_id', 'title', 'description', 'category', 'tags_json', 'checklist_json', 'ordinal'],
        'projects': <String>['id', 'name', 'color_value', 'is_archived', 'center_id', 'template_id', 'template_name_snapshot', 'legacy_payload_json'],
        'project_items': <String>['project_id', 'task_id', 'ordinal'],
        'template_task_applications': <String>['template_task_id', 'project_id', 'task_id'],
        'taxonomy_categories': <String>['name', 'created_at'],
        'tags': <String>['id', 'name'],
        'task_tags': <String>['task_id', 'tag_id', 'ordinal'],
        'checklist_items': <String>['task_id', 'ordinal', 'value'],
        'task_people': <String>['task_id', 'person_id', 'person_json', 'ordinal'],
        'people': <String>['id', 'name', 'created_at', 'updated_at'],
        'follow_up_people': <String>['follow_up_id', 'person_id', 'ordinal'],
        'arvin_storage_meta': <String>['key', 'value'],
      };
      for (final entry in expectedColumns.entries) {
        final columns = await database.runSelect(
          "PRAGMA table_info('${entry.key}')",
          const [],
        );
        expect(
          columns.map((row) => row['name']).toList(),
          entry.value,
          reason: 'Historical column shape mismatch for ${entry.key}',
        );
      }

      const expectedForeignKeys = <String, List<String>>{
        'follow_ups': <String>['task_id:tasks:id'],
        'project_template_tasks': <String>['template_id:project_templates:id'],
        'projects': <String>['center_id:centers:id'],
        'project_items': <String>['project_id:projects:id', 'task_id:tasks:id'],
        'template_task_applications': <String>['project_id:projects:id', 'task_id:tasks:id'],
        'task_tags': <String>['tag_id:tags:id', 'task_id:tasks:id'],
        'checklist_items': <String>['task_id:tasks:id'],
        'task_people': <String>['task_id:tasks:id'],
        'follow_up_people': <String>['follow_up_id:follow_ups:id'],
      };
      for (final entry in expectedForeignKeys.entries) {
        final foreignKeys = await database.runSelect(
          "PRAGMA foreign_key_list('${entry.key}')",
          const [],
        );
        final actual = foreignKeys
            .map((row) => '${row['from']}:${row['table']}:${row['to']}')
            .toList()
          ..sort();
        final expected = List<String>.of(entry.value)..sort();
        expect(actual, expected, reason: 'Foreign-key shape mismatch for ${entry.key}');
      }

      // Deterministic historical data exercises templates, their task rows,
      // applications, legacy Project membership, nullable values and both
      // archived and active Projects against the independent SQLite schema.
      await database.runCustom(
        "INSERT INTO centers (id, name, is_archived, created_at) VALUES ('center-v8-a', 'مرکز تاریخی', 0, '2026-11-01T08:00:00.000Z')",
      );
      await database.runCustom(
        "INSERT INTO project_templates (id, name, is_archived, created_at, updated_at) VALUES ('template-v8-a', 'قالب تاریخی', 0, '2026-11-01T08:00:00.000Z', '2026-11-01T08:00:00.000Z')",
      );
      await database.runCustom(
        "INSERT INTO project_template_tasks (id, template_id, title, description, category, tags_json, checklist_json, ordinal) VALUES ('template-task-v8-a', 'template-v8-a', 'کار قالب', '', NULL, '[]', '[]', 0)",
      );
      await database.runCustom(
        "INSERT INTO tasks (id, title, description, follow_up_enabled, priority, archived, trashed, completed) VALUES ('task-v8-a', 'کار تاریخی', '', 0, 'none', 0, 0, 0)",
      );
      await database.runCustom(
        "INSERT INTO projects (id, name, center_id, template_id, template_name_snapshot) VALUES ('project-v8-active', 'پروژه فعال', 'center-v8-a', 'template-v8-a', 'قالب تاریخی')",
      );
      await database.runCustom(
        "INSERT INTO projects (id, name, is_archived, center_id, template_id, template_name_snapshot) VALUES ('project-v8-archived', 'پروژه بایگانی', 1, 'center-v8-a', 'template-v8-a', NULL)",
      );
      await database.runCustom(
        "INSERT INTO project_items (project_id, task_id, ordinal) VALUES ('project-v8-active', 'task-v8-a', 7)",
      );
      await database.runCustom(
        "INSERT INTO template_task_applications (template_task_id, project_id, task_id) VALUES ('template-task-v8-a', 'project-v8-active', 'task-v8-a')",
      );
      await database.runCustom(
        "INSERT INTO taxonomy_categories (name, created_at) VALUES ('دسته تاریخی', '2026-11-01T08:00:00.000Z')",
      );
      await database.runCustom(
        "INSERT INTO tags (id, name) VALUES ('tag-v8-a', 'برچسب تاریخی')",
      );
      await database.runCustom(
        "INSERT INTO task_tags (task_id, tag_id, ordinal) VALUES ('task-v8-a', 'tag-v8-a', 0)",
      );
      await database.runCustom(
        "INSERT INTO checklist_items (task_id, ordinal, value) VALUES ('task-v8-a', 0, 'مرحله تاریخی')",
      );
      await database.runCustom(
        "INSERT INTO people (id, name, created_at, updated_at) VALUES ('person-v8-a', 'شخص تاریخی', '2026-11-01T08:00:00.000Z', '2026-11-01T08:00:00.000Z')",
      );
      await database.runCustom(
        """INSERT INTO task_people (task_id, person_id, person_json, ordinal)
           VALUES ('task-v8-a', 'person-v8-a', '{"displayName":"شخص تاریخی"}', 0)""",
      );
      await database.runCustom(
        "INSERT INTO follow_ups (id, task_id, date_time, title, note, completed, ordinal) VALUES ('follow-up-v8-a', 'task-v8-a', '2026-11-01T09:00:00.000Z', NULL, 'یادداشت تاریخی', 0, 0)",
      );
      await database.runCustom(
        "INSERT INTO follow_up_people (follow_up_id, person_id, ordinal) VALUES ('follow-up-v8-a', 'person-v8-a', 0)",
      );
      await database.runCustom(
        "INSERT INTO arvin_storage_meta (key, value) VALUES ('historical-v8-fixture', 'seeded')",
      );

      expect(
        await database.runSelect(
          "SELECT id FROM project_templates WHERE id = 'template-v8-a'",
          const [],
        ),
        hasLength(1),
      );
      expect(
        await database.runSelect(
          "SELECT id FROM project_template_tasks WHERE id = 'template-task-v8-a'",
          const [],
        ),
        hasLength(1),
      );
      // Historical v8 applications are keyed by task_id; there is no synthetic id column.
      final applicationRows = await database.runSelect(
        "SELECT task_id FROM template_task_applications WHERE task_id = 'task-v8-a'",
        const [],
      );
      expect(applicationRows, hasLength(1));
      expect(applicationRows.single['task_id'], 'task-v8-a');
      expect(
        await database.runSelect(
          "SELECT ordinal FROM project_items WHERE project_id = 'project-v8-active' AND task_id = 'task-v8-a'",
          const [],
        ),
        hasLength(1),
      );
      final nulls = await database.runSelect(
        "SELECT due_date, follow_up_date, reminder_date, completed_at, recurrence_json FROM tasks WHERE id = 'task-v8-a'",
        const [],
      );
      expect(nulls.single.values, everyElement(isNull));
      final projectStates = await database.runSelect(
        "SELECT id, is_archived FROM projects ORDER BY id",
        const [],
      );
      expect(projectStates.map((row) => row['is_archived']).toList(), <Object?>[0, 1]);
      expect(await database.runSelect('PRAGMA foreign_key_check', const []), isEmpty);

    } finally {
      await database.close();
    }
  });
}
