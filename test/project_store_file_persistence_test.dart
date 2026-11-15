import 'dart:convert';
import 'dart:io';

import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/project_store.dart';
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
}
