import 'dart:convert';
import 'dart:io';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ProjectStore survives independent file-backed SQLite close and reopen',
      () async {
    // TaskStore consults legacy preferences during first-open initialization;
    // keep that unrelated compatibility lookup empty while SQLite stays file-backed.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final directory =
        await Directory.systemTemp.createTemp('arvin-project-store-file-');
    final databaseFile = File('${directory.path}/project-store.sqlite');
    final project = ProjectPlan(
      id: 'command-20e-project-001',
      title: 'پروژه آزمون ماندگاری',
      colorValue: 0xFF3157A4,
      isArchived: true,
      itemIds: const <String>['command-20e-task-a', 'command-20e-task-b'],
      legacyFields: <String, dynamic>{
        'historicalMarker': <String, dynamic>{
          'source': 'command-20e',
          'revision': 7,
          'flags': <String>['keep', 'round-trip'],
        },
        'customMetadata': <String, dynamic>{
          'owner': 'acceptance-suite',
          'opaqueValue': 314159,
        },
      },
    );

    try {
      final firstDatabase = NativeDatabase(databaseFile);
      try {
        await TaskStore(executor: firstDatabase).save(<Task>[
          Task(id: 'command-20e-task-a', title: 'کار مرتبط الف'),
          Task(id: 'command-20e-task-b', title: 'کار مرتبط ب'),
        ]);

        final firstStore = ProjectStore(executor: firstDatabase);
        await firstStore.save(<ProjectPlan>[project]);
        final beforeResave = (await firstStore.load()).single;

        expect(beforeResave.id, project.id);
        expect(beforeResave.itemIds,
            <String>['command-20e-task-a', 'command-20e-task-b']);
        expect(beforeResave.legacyFields['historicalMarker'],
            project.legacyFields['historicalMarker']);
        expect(beforeResave.legacyFields['customMetadata'],
            project.legacyFields['customMetadata']);

        // ProjectStore owns this relation table. Guard it so TaskStore cannot
        // silently become a second writer while replacing canonical Task rows.
        await firstDatabase.runCustom('''
          CREATE TRIGGER block_project_items_delete
          BEFORE DELETE ON project_items
          BEGIN SELECT RAISE(ABORT, 'ProjectStore owns project_items'); END
        ''');
        await firstDatabase.runCustom('''
          CREATE TRIGGER block_project_items_insert
          BEFORE INSERT ON project_items
          BEGIN SELECT RAISE(ABORT, 'ProjectStore owns project_items'); END
        ''');

        final taskStore = TaskStore(executor: firstDatabase);
        final existingTasks = await taskStore.load();
        await taskStore.save(existingTasks);
        final retainedEdges = await firstDatabase.runSelect(
          'SELECT project_id, task_id, ordinal FROM project_items ORDER BY project_id, ordinal',
          const <Object?>[],
        );
        expect(
          retainedEdges.map((row) => row['task_id']).toList(),
          <String>['command-20e-task-a', 'command-20e-task-b'],
        );

        // A Task still referenced by a Project cannot be removed implicitly.
        // Deferred FK validation rejects the transaction and preserves both
        // the original Task rows and their Project membership edges.
        await expectLater(
          taskStore.save(<Task>[]),
          throwsA(predicate<Object>(
            (error) => error.toString().contains('FOREIGN KEY constraint failed'),
          )),
        );
        expect(await taskStore.load(), hasLength(2));
        expect((await firstStore.load()).single.itemIds,
            <String>['command-20e-task-a', 'command-20e-task-b']);

        await firstDatabase.runCustom(
          'DROP TRIGGER block_project_items_delete',
        );
        await firstDatabase.runCustom(
          'DROP TRIGGER block_project_items_insert',
        );

        await firstStore.save(<ProjectPlan>[
          beforeResave.copyWith(
            title: 'پروژه پس از ذخیره مجدد',
          ),
        ]);
        final afterResave = (await firstStore.load()).single;
        expect(afterResave.title, 'پروژه پس از ذخیره مجدد');
        expect(afterResave.itemIds, beforeResave.itemIds);
        expect(afterResave.legacyFields, beforeResave.legacyFields);
        debugPrintSynchronously('PROJECT_STORE_FILE_SAVE_AND_RESAVE=PASS');
      } finally {
        await firstDatabase.close();
      }

      expect(databaseFile.existsSync(), isTrue);
      expect(await databaseFile.length(), greaterThan(0));
      debugPrintSynchronously('PROJECT_STORE_DATABASE_CLOSED=PASS');

      final reopenedDatabase = NativeDatabase(databaseFile);
      try {
        final reopenedStore = ProjectStore(executor: reopenedDatabase);
        final reopenedTaskStore = TaskStore(executor: reopenedDatabase);
        final restored = await reopenedStore.load();
        expect(restored, hasLength(1));
        final loaded = restored.single;

        expect(loaded.id, project.id);
        expect(loaded.title, 'پروژه پس از ذخیره مجدد');
        expect(loaded.colorValue, project.colorValue);
        expect(loaded.isArchived, isTrue);
        expect(loaded.itemIds,
            <String>['command-20e-task-a', 'command-20e-task-b']);
        expect(loaded.legacyFields['historicalMarker'],
            project.legacyFields['historicalMarker']);
        expect(loaded.legacyFields['customMetadata'],
            project.legacyFields['customMetadata']);

        final restoredTasks = await reopenedTaskStore.load();
        expect(restoredTasks, hasLength(2));
        expect(restoredTasks.map((task) => task.id).toSet(),
            <String>{'command-20e-task-a', 'command-20e-task-b'});
        expect(restoredTasks.map((task) => task.title).toSet(),
            <String>{'کار مرتبط الف', 'کار مرتبط ب'});

        final integrityRows = await reopenedDatabase.runSelect(
          'PRAGMA integrity_check',
          const <Object?>[],
        );
        expect(integrityRows.single['integrity_check'], 'ok');
        final foreignKeyRows = await reopenedDatabase.runSelect(
          'PRAGMA foreign_key_check',
          const <Object?>[],
        );
        expect(foreignKeyRows, isEmpty);
        debugPrintSynchronously('PROJECT_STORE_SQLITE_INTEGRITY_AND_FOREIGN_KEYS=PASS');

        final serialized = reopenedStore.codec.encode(loaded);
        expect(serialized['id'], project.id);
        expect(serialized['itemIds'],
            <String>['command-20e-task-a', 'command-20e-task-b']);
        expect(serialized['historicalMarker'],
            project.legacyFields['historicalMarker']);
        expect(serialized['customMetadata'],
            project.legacyFields['customMetadata']);
        expect(jsonDecode(jsonEncode(serialized)), isA<Map<String, dynamic>>());
        debugPrintSynchronously('PROJECT_STORE_INDEPENDENT_REOPEN=PASS');
        debugPrintSynchronously('PROJECT_STORE_ID_METADATA_RELATIONSHIPS_SERIALIZE=PASS');
        debugPrintSynchronously('PROJECT_STORE_FILE_PERSISTENCE=PASS');
      } finally {
        await reopenedDatabase.close();
      }
    } finally {
      await directory.delete(recursive: true);
      expect(directory.existsSync(), isFalse);
      expect(databaseFile.existsSync(), isFalse);
      debugPrintSynchronously('PROJECT_STORE_TEMP_FILE_AND_DIRECTORY_CLEANUP=PASS');
    }
  });

  test('replaceAll preserves existing graph edges and blocks linked Project deletion', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final directory =
        await Directory.systemTemp.createTemp('arvin-project-restore-graph-');
    final databaseFile = File('${directory.path}/restore-graph.sqlite');
    try {
      final database = NativeDatabase(databaseFile);
      try {
        await TaskStore(executor: database).save(<Task>[
          Task(id: 'restore-graph-task', title: 'کار متصل'),
        ]);
        final projects = ProjectStore(executor: database);
        await projects.save(<ProjectPlan>[
          ProjectPlan(
            id: 'restore-graph-project',
            title: 'عنوان اولیه',
            itemIds: const <String>['restore-graph-task'],
            legacyFields: const <String, dynamic>{
              'opaqueRestoreMetadata': <String, dynamic>{'revision': 9},
            },
          ),
        ]);
        final centers = CenterStore(executor: database);
        await centers.create(id: 'restore-graph-center', name: 'مرکز متصل');
        await centers.linkProject('restore-graph-center', 'restore-graph-project');
        await database.runInsert(
          '''INSERT INTO categories
             (id, name, legacy_name, is_archived, created_at, updated_at)
             VALUES (?, ?, ?, 0, ?, ?)''',
          <Object?>[
            'restore-graph-category',
            'دسته متصل',
            'دسته متصل',
            DateTime.utc(2026).toIso8601String(),
            DateTime.utc(2026).toIso8601String(),
          ],
        );
        await database.runInsert(
          'INSERT INTO project_categories (project_id, category_id) VALUES (?, ?)',
          const <Object?>['restore-graph-project', 'restore-graph-category'],
        );

        // The backup omits itemIds. Existing Task membership and both
        // independent graph relations must survive the in-place update.
        await projects.replaceAll(<ProjectPlan>[
          ProjectPlan(
            id: 'restore-graph-project',
            title: 'عنوان بازیابی‌شده',
          ),
        ]);

        final restored = (await projects.load()).single;
        expect(restored.title, 'عنوان بازیابی‌شده');
        expect(restored.itemIds, <String>['restore-graph-task']);
        expect(
          restored.legacyFields['opaqueRestoreMetadata'],
          <String, dynamic>{'revision': 9},
        );
        expect(
          await centers.centerIdsForProject('restore-graph-project'),
          <String>['restore-graph-center'],
        );
        final categoryEdges = await database.runSelect(
          'SELECT category_id FROM project_categories WHERE project_id = ?',
          const <Object?>['restore-graph-project'],
        );
        expect(categoryEdges.map((row) => row['category_id']).toList(),
            <String>['restore-graph-category']);

        // A snapshot that omits a still-linked Project must fail atomically;
        // it must never silently discard Center/Category graph edges.
        await expectLater(
          projects.replaceAll(const <ProjectPlan>[]),
          throwsA(isA<ProjectDeleteBlocked>()),
        );
        expect((await projects.load()).single.id, 'restore-graph-project');
        expect(
          await centers.centerIdsForProject('restore-graph-project'),
          <String>['restore-graph-center'],
        );
        final violations = await database.runSelect(
          'PRAGMA foreign_key_check',
          const <Object?>[],
        );
        expect(violations, isEmpty);
      } finally {
        await database.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
