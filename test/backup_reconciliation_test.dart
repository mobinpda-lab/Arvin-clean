import 'package:arvin/backup_manager.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/app_settings_service.dart';
import 'package:flutter_test/flutter_test.dart';

Task task(String id, String title) => Task(id: id, title: title);

void main() {
  group('backup reconciliation', () {
    test('updates matching Task IDs and keeps local-only records', () {
      final current = [
        task('shared', 'عنوان فعلی'),
        task('local-only', 'فقط روی این دستگاه'),
      ];
      final backup = [
        task('shared', 'عنوان پشتیبان'),
        task('backup-only', 'فقط در پشتیبان'),
      ];

      final result = ArvinBackupManager.reconcileTasksById(
        current: current,
        backup: backup,
      );

      expect(result.map((item) => item.id), [
        'shared',
        'local-only',
        'backup-only',
      ]);
      expect(result.first.title, 'عنوان پشتیبان');
      expect(result[1].title, 'فقط روی این دستگاه');
      expect(result.last.title, 'فقط در پشتیبان');
    });

    test('keeps local-only notebook notes and their checklists', () {
      final note = Task(
        id: 'note-local',
        title: 'یادداشت شخصی',
        description: 'متن یادداشت',
        notebookKind: NotebookItemKind.checklist,
        checklist: const ['مورد اول', 'مورد دوم'],
      );

      final result = ArvinBackupManager.reconcileTasksById(
        current: [note],
        backup: [task('backup-only', 'کار پشتیبان')],
      );

      final retained = result.singleWhere((item) => item.id == 'note-local');
      expect(retained.isNotebookItem, isTrue);
      expect(retained.description, 'متن یادداشت');
      expect(retained.checklist, ['مورد اول', 'مورد دوم']);
    });

    test('updates matching Projects and retains local-only memberships', () {
      final current = [
        ProjectPlan(
          id: 'shared-project',
          title: 'عنوان قدیمی',
          itemIds: const ['backup-task', 'local-task'],
        ),
        ProjectPlan(
          id: 'local-project',
          title: 'پروژه فقط محلی',
          itemIds: const ['local-task'],
        ),
      ];
      final backup = [
        ProjectPlan(
          id: 'shared-project',
          title: 'عنوان پشتیبان',
          itemIds: const ['backup-task'],
        ),
        ProjectPlan(
          id: 'backup-project',
          title: 'پروژه جدید',
          itemIds: const ['backup-task'],
        ),
      ];

      final result = ArvinBackupManager.reconcileProjectsById(
        current: current,
        backup: backup,
        localOnlyTaskIds: {'local-task'},
      );

      expect(result.map((item) => item.id), [
        'shared-project',
        'backup-project',
        'local-project',
      ]);
      expect(result.first.title, 'عنوان پشتیبان');
      expect(result.first.itemIds, containsAll(['backup-task', 'local-task']));
      expect(result.last.itemIds, ['local-task']);
    });

    test('explicit nullable defaults overwrite current custom settings', () {
      final merged = AppSettingsService.mergePortableJson(
        current: {
          'fontFamily': 'VazirHarf',
          'calendarIntegration': {'targetCalendarId': 'local-calendar'},
        },
        incoming: {
          'fontFamily': null,
          'calendarIntegration': {'targetCalendarId': null},
        },
      );

      expect(merged.containsKey('fontFamily'), isFalse);
      expect(
        (merged['calendarIntegration'] as Map)['targetCalendarId'],
        isNull,
      );
    });

    test('legacy settings only update keys present in backup', () {
      final merged = AppSettingsService.mergePortableJson(
        current: {
          'themeMode': 'dark',
          'fontSize': 18,
          'fontFamily': 'VazirHarf',
          'calendarIntegration': {
            'enabled': true,
            'targetCalendarId': 'local-calendar',
          },
          'backupSchedule': {
            'enabled': true,
            'hour': 5,
            'minute': 30,
            'frequency': 'weekly',
          },
        },
        incoming: {
          'themeMode': 'light',
          'calendarIntegration': {'enabled': false},
        },
      );

      expect(merged['themeMode'], 'light');
      expect(merged['fontSize'], 18);
      expect(merged.containsKey('fontFamily'), isFalse);
      expect(merged['calendarIntegration'], {
        'enabled': false,
        'targetCalendarId': 'local-calendar',
      });
      expect(merged['backupSchedule'], {
        'enabled': true,
        'hour': 5,
        'minute': 30,
        'frequency': 'weekly',
      });
    });
  });
}
