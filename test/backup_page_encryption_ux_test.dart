import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_page.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBackupService extends ArvinBackupService {
  int writeCount = 0;
  int readCount = 0;
  String? lastEncryptionPassphrase;
  String? lastReadPassphrase;
  Map<String, dynamic>? readResult;
  Map<String, dynamic>? lastPayload;
  Object? readError;

  @override
  String createBackupFileName(DateTime dateTime) => 'backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writeCount += 1;
    lastPayload = payload;
    lastEncryptionPassphrase = encryptionPassphrase;
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    readCount += 1;
    lastReadPassphrase = passphrase;
    final error = readError;
    if (error != null) throw error;
    return readResult;
  }
}

Widget _app({
  required _FakeBackupService service,
  Future<List<Map<String, dynamic>>> Function()? loadTasks,
  Future<void> Function(List<Map<String, dynamic>> tasks)? replaceTasks,
  Future<void> Function(String stage)? restoreStageHook,
}) {
  return MaterialApp(
    home: BackupPage(
      manager: ArvinBackupManager(service: service),
      loadTasks: loadTasks ??
          () async => <Map<String, dynamic>>[
                <String, dynamic>{'id': 'task-1', 'title': 'کار نمونه'},
              ],
      replaceTasks: replaceTasks ?? (_) async {},
      restoreStageHook: restoreStageHook,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
    });
  });

  testWidgets('plaintext backup remains default and does not prompt',
      (tester) async {
    final service = _FakeBackupService();
    final link = ExternalCalendarEventLink(
      reminderId: 'task-due:task-1',
      calendarId: '42',
      eventId: 'event-1',
      lastSyncedFingerprint: 'fingerprint-1',
    );
    await ExternalCalendarLinkStore().save([link]);
    await tester.pumpWidget(_app(service: service));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('backup_passphrase_field')), findsNothing);
    expect(
      tester.widget<SwitchListTile>(
        find.byKey(const Key('backup_encryption_toggle')),
      ).value,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();

    expect(service.writeCount, 1);
    expect(service.lastEncryptionPassphrase, isNull);
    expect(service.lastPayload?['calendarLinks'], [link.toJson()]);
    expect(find.textContaining('پشتیبان ساخته شد'), findsOneWidget);
  });

  testWidgets('encrypted backup requires matching non-empty confirmation',
      (tester) async {
    final service = _FakeBackupService();
    await tester.pumpWidget(_app(service: service));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('backup_encryption_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('backup_passphrase_field')),
      'secret-123',
    );
    await tester.enterText(
      find.byKey(const Key('backup_passphrase_confirm_field')),
      'different',
    );
    await tester.tap(find.byKey(const Key('backup_passphrase_confirm')));
    await tester.pump();

    expect(find.text('دو رمز یکسان نیستند'), findsOneWidget);
    expect(service.writeCount, 0);

    await tester.enterText(
      find.byKey(const Key('backup_passphrase_confirm_field')),
      'secret-123',
    );
    await tester.tap(find.byKey(const Key('backup_passphrase_confirm')));
    await tester.pumpAndSettle();

    expect(service.writeCount, 1);
    expect(service.lastEncryptionPassphrase, 'secret-123');
    expect(find.textContaining('پشتیبان رمزگذاری‌شده ساخته شد'), findsOneWidget);
  });

  testWidgets('cancelling encrypted backup performs no write', (tester) async {
    final service = _FakeBackupService();
    var loadCount = 0;
    await tester.pumpWidget(
      _app(
        service: service,
        loadTasks: () async {
          loadCount += 1;
          return <Map<String, dynamic>>[];
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('backup_encryption_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('backup_passphrase_cancel')));
    await tester.pumpAndSettle();

    expect(loadCount, 0);
    expect(service.writeCount, 0);
  });

  testWidgets('restore confirmation cancel never replaces local tasks',
      (tester) async {
    final service = _FakeBackupService()
      ..readResult = <String, dynamic>{
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'restored-1', 'title': 'بازیابی‌شده'},
        ],
      };
    var replaceCount = 0;

    await tester.pumpWidget(
      _app(
        service: service,
        replaceTasks: (_) async => replaceCount += 1,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(service.readCount, 1);
    expect(find.text('تأیید بازیابی'), findsOneWidget);
    expect(replaceCount, 0);

    await tester.tap(find.byKey(const Key('restore_confirm_cancel')));
    await tester.pumpAndSettle();

    expect(replaceCount, 0);
    expect(find.text('اطلاعات با موفقیت بازیابی شد'), findsNothing);
  });

  testWidgets('encrypted restore reconciles backup and local tasks by ID',
      (tester) async {
    final service = _FakeBackupService()
      ..readResult = <String, dynamic>{
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'restored-1', 'title': 'بازیابی‌شده'},
        ],
      };
    var replaceCount = 0;
    List<Map<String, dynamic>>? replaced;

    await tester.pumpWidget(
      _app(
        service: service,
        replaceTasks: (tasks) async {
          replaceCount += 1;
          replaced = tasks;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restore_encrypted_backup_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('restore_passphrase_field')),
      'restore-secret',
    );
    await tester.tap(find.byKey(const Key('restore_passphrase_confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(service.readCount, 1);
    expect(service.lastReadPassphrase, 'restore-secret');
    expect(find.text('تأیید بازیابی'), findsOneWidget);
    expect(replaceCount, 0);

    await tester.tap(find.byKey(const Key('restore_confirm_apply')));
    await tester.pumpAndSettle();

    expect(replaceCount, 1);
    expect(replaced, hasLength(2));
    expect(replaced!.map((task) => task['id']), containsAll(['task-1', 'restored-1']));
    expect(find.textContaining('بازیابی انجام شد'), findsOneWidget);
  });

  testWidgets('wrong encrypted restore passphrase never mutates local tasks',
      (tester) async {
    final service = _FakeBackupService()
      ..readError = const FormatException('authentication failed');
    var replaceCount = 0;

    await tester.pumpWidget(
      _app(
        service: service,
        replaceTasks: (_) async => replaceCount += 1,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restore_encrypted_backup_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('restore_passphrase_field')),
      'wrong-secret',
    );
    await tester.tap(find.byKey(const Key('restore_passphrase_confirm')));
    await tester.pumpAndSettle();

    expect(service.readCount, 1);
    expect(service.lastReadPassphrase, 'wrong-secret');
    expect(replaceCount, 0);
    expect(find.textContaining('رمز نادرست است'), findsOneWidget);
  });

  testWidgets('Backup page includes canonical Projects in the existing backup', (tester) async {
    await ProjectStore.resetTestDatabase();
    try {
      final project = ProjectPlan(
        id: 'backup-page-project',
        title: 'پروژه پشتیبان',
        itemIds: const [],
      );
      await ProjectStore().save([project]);
      final service = _FakeBackupService();

      await tester.pumpWidget(_app(service: service));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('create_backup_button')));
      await tester.pumpAndSettle();

      final projects = service.lastPayload?['projects'] as List<dynamic>?;
      expect(projects, hasLength(1));
      expect((projects!.single as Map)['id'], 'backup-page-project');
      expect((projects.single as Map)['title'], 'پروژه پشتیبان');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await ProjectStore.resetTestDatabase();
    }
  });

  testWidgets('Backup page restores Projects and rolls back taxonomy after a late restore failure', (tester) async {
    await TaskStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
    try {
      final oldProject = ProjectPlan(
        id: 'old-project',
        title: 'پروژه قبلی',
        itemIds: const [],
      );
      final restoredProject = ProjectPlan(
        id: 'restored-project',
        title: 'پروژه جدید',
        itemIds: const [],
      );
      await ProjectStore().save([oldProject]);
      await TaskStore().createCategory('دسته محلی');
      await TaskStore().createTag('برچسب محلی');
      final service = _FakeBackupService()
        ..readResult = <String, dynamic>{
          'type': ArvinBackupService.backupType,
          'formatVersion': ArvinBackupService.backupFormatVersion,
          'tasks': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'restored-task', 'title': 'کار بازیابی‌شده'},
          ],
          'projects': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': restoredProject.id,
              'title': restoredProject.title,
              'colorValue': restoredProject.colorValue,
              'isArchived': restoredProject.isArchived,
              'itemIds': restoredProject.itemIds,
            },
          ],
          'settings': <String, dynamic>{
            'themeMode': 'light',
            'backupSchedule': <String, dynamic>{
              'enabled': true,
              'hour': 6,
              'minute': 15,
              'frequency': 'daily',
            },
          },
          'calendarLinks': <Map<String, dynamic>>[],
          'categories': <String>['دسته بازیابی‌شده'],
          'tags': <String>['برچسب بازیابی‌شده'],
        };
      var localTasks = <Map<String, dynamic>>[
        <String, dynamic>{'id': 'old-task', 'title': 'کار قبلی'},
      ];

      await tester.pumpWidget(
        _app(
          service: service,
          loadTasks: () async => localTasks,
          replaceTasks: (tasks) async {
            localTasks = tasks.map((task) => Map<String, dynamic>.from(task)).toList();
          },
          restoreStageHook: (stage) async {
            if (stage == 'catalogs') throw StateError('injected after catalogs');
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.byKey(const Key('restore_confirm_apply')));
      await tester.pumpAndSettle();

      expect(localTasks.single['id'], 'old-task');
      expect(await TaskStore().loadCategories(), contains('دسته محلی'));
      expect(await TaskStore().loadCategories(), isNot(contains('دسته بازیابی‌شده')));
      expect(await TaskStore().loadTags(), contains('برچسب محلی'));
      expect(await TaskStore().loadTags(), isNot(contains('برچسب بازیابی‌شده')));
      final projectsAfterRollback = await ProjectStore().load();
      expect(projectsAfterRollback.map((project) => project.id), ['old-project']);
      expect(
        find.text('بازیابی کامل نشد؛ اطلاعات قبلی به حالت پیشین بازگردانده شد.'),
        findsOneWidget,
      );
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await TaskStore.resetTestDatabase();
      await ProjectStore.resetTestDatabase();
    }
  });

  testWidgets('Backup page applies Projects from a modern backup', (tester) async {
    await ProjectStore.resetTestDatabase();
    try {
      final service = _FakeBackupService()
        ..readResult = <String, dynamic>{
          'type': ArvinBackupService.backupType,
          'formatVersion': ArvinBackupService.backupFormatVersion,
          'tasks': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'restored-task', 'title': 'کار بازیابی‌شده'},
          ],
          'projects': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'restored-project',
              'title': 'پروژه بازیابی‌شده',
              'colorValue': 0xFF4A4CAB,
              'isArchived': false,
              'itemIds': <String>[],
            },
          ],
        };

      await tester.pumpWidget(_app(service: service));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.byKey(const Key('restore_confirm_apply')));
      await tester.pumpAndSettle();

      final projects = await ProjectStore().load();
      expect(projects.map((project) => project.id), ['restored-project']);
      expect(projects.single.title, 'پروژه بازیابی‌شده');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await ProjectStore.resetTestDatabase();
    }
  });

  testWidgets('Backup page preserves local Projects for a legacy backup without Projects', (tester) async {
    await ProjectStore.resetTestDatabase();
    try {
      final localProject = ProjectPlan(
        id: 'local-project',
        title: 'پروژه محلی',
        itemIds: const [],
      );
      await ProjectStore().save([localProject]);
      final service = _FakeBackupService()
        ..readResult = <String, dynamic>{
          'type': ArvinBackupService.backupType,
          'formatVersion': ArvinBackupService.backupFormatVersion,
          'tasks': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'legacy-task', 'title': 'کار قدیمی'},
          ],
        };

      await tester.pumpWidget(_app(service: service));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.byKey(const Key('restore_confirm_apply')));
      await tester.pumpAndSettle();

      final projects = await ProjectStore().load();
      expect(projects.map((project) => project.id), ['local-project']);
      expect(projects.single.title, 'پروژه محلی');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await ProjectStore.resetTestDatabase();
    }
  });

  testWidgets('passphrase is operation scoped and never persisted',
      (tester) async {
    final service = _FakeBackupService();
    await tester.pumpWidget(_app(service: service));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('backup_encryption_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('backup_passphrase_field')),
      'memory-only-secret',
    );
    await tester.enterText(
      find.byKey(const Key('backup_passphrase_confirm_field')),
      'memory-only-secret',
    );
    await tester.tap(find.byKey(const Key('backup_passphrase_confirm')));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), <String>{ArvinBackupManager.directoryKey});
    expect(service.lastEncryptionPassphrase, 'memory-only-secret');
  });
}
