import 'dart:io';

import 'package:arvin/models/center.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Center CRUD, M2M links and archive state survive SQLite close/reopen',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final directory =
        await Directory.systemTemp.createTemp('arvin-center-store-');
    final file = File('\${directory.path}/center-store.sqlite');
    NativeDatabase? database;

    try {
      database = NativeDatabase(file);
      final projects = ProjectStore(executor: database);
      await projects.save(<ProjectPlan>[
        ProjectPlan(id: 'center-store-project-a', title: 'پروژه الف'),
        ProjectPlan(id: 'center-store-project-b', title: 'پروژه ب'),
      ]);

      final centers = CenterStore(executor: database);
      final centerA = await centers.create(id: 'center-a', name: 'مرکز الف');
      final centerB = await centers.create(id: 'center-b', name: 'مرکز ب');
      expect(centerA.name, 'مرکز الف');
      expect(centerB.name, 'مرکز ب');

      await centers.linkProject('center-a', 'center-store-project-a');
      await centers.linkProject('center-a', 'center-store-project-b');
      await centers.linkProject('center-b', 'center-store-project-a');
      await centers.linkProject('center-a', 'center-store-project-a');

      expect(
        await centers.projectIdsForCenter('center-a'),
        <String>['center-store-project-a', 'center-store-project-b'],
      );
      expect(
        await centers.centerIdsForProject('center-store-project-a'),
        <String>['center-a', 'center-b'],
      );

      await centers.rename('center-a', 'مرکز الف ویرایش‌شده');
      await centers.archive('center-b');
      expect(
        (await centers.load(includeArchived: false)).map((item) => item.id),
        <String>['center-a'],
      );
      await centers.restore('center-b');

      await expectLater(
        centers.delete('center-a'),
        throwsA(isA<CenterDeleteBlocked>()),
      );

      await database.close();
      database = null;
      expect(file.existsSync(), isTrue);
      expect(await file.length(), greaterThan(0));

      database = NativeDatabase(file);
      final reopened = CenterStore(executor: database);
      final loaded = await reopened.load();
      expect(loaded, hasLength(2));
      final restoredA = loaded.singleWhere((item) => item.id == 'center-a');
      expect(restoredA.name, 'مرکز الف ویرایش‌شده');
      expect(restoredA.isArchived, isFalse);
      expect(
        await reopened.projectIdsForCenter('center-a'),
        <String>['center-store-project-a', 'center-store-project-b'],
      );
      expect(
        await reopened.centerIdsForProject('center-store-project-a'),
        <String>['center-a', 'center-b'],
      );

      await reopened.unlinkProject('center-a', 'center-store-project-b');
      expect(
        await reopened.projectIdsForCenter('center-a'),
        <String>['center-store-project-a'],
      );
      expect(await projects.load(), hasLength(2));

      await reopened.unlinkProject('center-a', 'center-store-project-a');
      await reopened.delete('center-a');
      expect(await reopened.findById('center-a'), isNull);
      expect(await reopened.findById('center-b'), isNotNull);
      expect(
        await reopened.centerIdsForProject('center-store-project-a'),
        <String>['center-b'],
      );

      final integrity = await database.runSelect(
        'PRAGMA integrity_check',
        const <Object?>[],
      );
      expect(integrity.single['integrity_check'], 'ok');
      final foreignKeys = await database.runSelect(
        'PRAGMA foreign_key_check',
        const <Object?>[],
      );
      expect(foreignKeys, isEmpty);
    } finally {
      await database?.close();
      await directory.delete(recursive: true);
    }
  });
}
