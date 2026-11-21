import 'dart:io';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/g1_drift_schema.dart';
import 'package:arvin/services/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('TaskStore persists optional Center/Project/Category links without losing legacy memberships or NULL presence', () async {
    final directory = await Directory.systemTemp.createTemp('arvin-task-hierarchy-');
    final file = File('${directory.path}/hierarchy.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    var database = NativeDatabase(file);
    try {
      await G1DriftSchema.install(database);
      await database.runCustom('PRAGMA foreign_keys = ON');
      await database.runInsert(
        'INSERT INTO projects (id, name, color_value, is_archived, legacy_payload_json) VALUES (?, ?, ?, ?, ?)',
        <Object?>['project-rev10-1', 'پروژه آزمایشی', 4283059371, 0, '{}'],
      );
      await database.runInsert(
        'INSERT INTO categories (id, name, legacy_name, is_archived, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>['category-rev10-1', 'دسته آزمایشی', null, 0, '2026-11-21T00:00:00.000Z', '2026-11-21T00:00:00.000Z'],
      );
      await database.runInsert(
        'INSERT INTO centers (id, name, is_archived, created_at, updated_at) VALUES (?, ?, ?, ?, ?)',
        <Object?>['center-rev10-1', 'مرکز آزمایشی', 0, '2026-11-21T00:00:00.000Z', '2026-11-21T00:00:00.000Z'],
      );

      final linked = Task(
        id: 'task-hierarchy-linked',
        title: 'پیوندهای مستقیم REV10',
        centerId: 'center-rev10-1',
        projectId: 'project-rev10-1',
        categoryId: 'category-rev10-1',
      );
      final explicitNull = Task(
        id: 'task-hierarchy-explicit-null',
        title: 'NULL صریح',
        extensionData: const <String, dynamic>{
          'centerId': null,
          'projectId': null,
          'categoryId': null,
        },
      );
      final omitted = Task(
        id: 'task-hierarchy-omitted',
        title: 'فیلدهای حذف‌شده',
      );

      final store = TaskStore(executor: database);
      await store.save(<Task>[linked, explicitNull, omitted]);

      // The historical project_items relation remains a separate preserved edge.
      await database.runInsert(
        'INSERT INTO project_items (project_id, task_id, ordinal) VALUES (?, ?, ?)',
        <Object?>['project-rev10-1', linked.id, 0],
      );
      await store.save(await store.load());

      final rows = await database.runSelect(
        'SELECT id, center_id, project_id, category_id FROM tasks ORDER BY id',
        const [],
      );
      final byId = <String, Map<String, Object?>>{
        for (final row in rows) row['id'] as String: row,
      };
      expect(byId[linked.id]!['center_id'], 'center-rev10-1');
      expect(byId[linked.id]!['project_id'], 'project-rev10-1');
      expect(byId[linked.id]!['category_id'], 'category-rev10-1');
      expect(byId[explicitNull.id]!['center_id'], isNull);
      expect(byId[omitted.id]!['center_id'], isNull);

      final legacyEdges = await database.runSelect(
        'SELECT project_id, task_id, ordinal FROM project_items WHERE task_id = ?',
        <Object?>[linked.id],
      );
      expect(legacyEdges, hasLength(1));
      expect(legacyEdges.single['project_id'], 'project-rev10-1');

      await database.close();
      database = NativeDatabase(file);
      await G1DriftSchema.install(database);
      final reopened = await TaskStore(executor: database).load();
      final reopenedLinked = reopened.singleWhere((task) => task.id == linked.id);
      final reopenedNull = reopened.singleWhere((task) => task.id == explicitNull.id);
      final reopenedOmitted = reopened.singleWhere((task) => task.id == omitted.id);

      expect(reopenedLinked.centerId, 'center-rev10-1');
      expect(reopenedLinked.projectId, 'project-rev10-1');
      expect(reopenedLinked.categoryId, 'category-rev10-1');
      expect(reopenedNull.toJson().containsKey('centerId'), isTrue);
      expect(reopenedNull.toJson()['centerId'], isNull);
      expect(reopenedNull.toJson().containsKey('projectId'), isTrue);
      expect(reopenedNull.toJson()['projectId'], isNull);
      expect(reopenedNull.toJson().containsKey('categoryId'), isTrue);
      expect(reopenedNull.toJson()['categoryId'], isNull);
      expect(reopenedOmitted.toJson().containsKey('centerId'), isFalse);
      expect(reopenedOmitted.toJson().containsKey('projectId'), isFalse);
      expect(reopenedOmitted.toJson().containsKey('categoryId'), isFalse);

      expect(await database.runSelect('PRAGMA integrity_check', const []), isNotEmpty);
      final integrity = await database.runSelect('PRAGMA integrity_check', const []);
      expect(integrity.single.values.first, 'ok');
      expect(await database.runSelect('PRAGMA foreign_key_check', const []), isEmpty);
    } finally {
      await database.close();
    }
  });
}
