import 'package:arvin/backup_manager.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/center_store.dart';
import 'package:arvin/services/project_backup_bridge.dart';
import 'package:arvin/services/project_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('canonical Backup Restore preserves Project identity and M2M relationships', () async {
    final database = NativeDatabase.memory();
    addTearDown(database.close);
    final centers = CenterStore(executor: database);
    await centers.create(id: 'center-a', name: 'مرکز الف');
    await centers.create(id: 'center-b', name: 'مرکز ب');
    await database.runInsert(
      '''INSERT INTO categories
         (id, name, legacy_name, storage_ordinal, is_archived, created_at, updated_at)
         VALUES ('category-a', 'دسته الف', NULL, 0, 0, '2026-01-01', '2026-01-01')''',
      const [],
    );
    final store = ProjectStore(executor: database);
    final bridge = ProjectBackupBridge(projectStore: store);
    final project = ProjectPlan(
      id: 'backup-project',
      title: 'پروژه پشتیبان',
      centerIds: const ['center-a', 'center-b'],
      categoryIds: const ['category-a'],
      legacyFields: const {'createdAt': '2026-01-01T00:00:00.000Z'},
    );
    final candidate = (
      tasks: const [],
      settings: null,
      projects: <ProjectPlan>[project],
      hasProjects: true,
      calendarLinks: null,
      categories: null,
      tags: null,
      people: null,
      hasPeople: false,
    );

    await bridge.restoreProjects(candidate);

    final restored = (await store.load()).single;
    expect(restored.id, 'backup-project');
    expect(restored.centerIds, ['center-a', 'center-b']);
    expect(restored.categoryIds, ['category-a']);
    expect(restored.legacyFields['createdAt'], '2026-01-01T00:00:00.000Z');
  });
}
