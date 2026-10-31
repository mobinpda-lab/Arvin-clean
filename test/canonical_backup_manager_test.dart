import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/project_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBackupService extends ArvinBackupService {
  Map<String, dynamic>? writtenPayload;
  Map<String, dynamic>? restoreDocument;
  String? writtenEncryptionPassphrase;
  String? readPassphrase;

  @override
  String createBackupFileName(DateTime dateTime) => 'canonical-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writtenPayload = payload;
    writtenEncryptionPassphrase = encryptionPassphrase;
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    readPassphrase = passphrase;
    return restoreDocument;
  }
}

Task _completeTask() {
  return Task(
    id: 'task-full',
    title: 'کار کامل',
    description: 'همه داده‌های canonical باید منتقل شوند',
    createdAt: DateTime(2026, 8, 20, 8),
    updatedAt: DateTime(2026, 8, 26, 12),
    followUpEnabled: true,
    followUpDate: DateTime(2026, 8, 24, 9),
    tags: const ['مهم', 'مشتری'],
    category: 'فروش',
    checklist: const ['تماس', 'ارسال فایل'],
    reminderDate: DateTime(2026, 8, 28, 10, 30),
    archived: false,
    trashed: false,
    completed: false,
    followUps: [
      FollowUp(
        id: 'fu-1',
        dateTime: DateTime(2026, 8, 24, 9),
        note: 'تماس اول',
        result: 'منتظر پاسخ',
        reminderDate: DateTime(2026, 8, 28, 10, 15),
        nextFollowUp: DateTime(2026, 8, 28, 10, 30),
      ),
    ],
    recurrence: const RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      interval: 2,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
    });
  });

  test('canonical backup preserves the complete Task JSON shape', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);

    final completedAt = DateTime(2026, 8, 25, 16, 20);
    final task = _completeTask()
      ..completed = true
      ..completedAt = completedAt
      ..taskReminders = [
        TaskReminder(
          id: 'backup-r1',
          title: 'تماس — یادآور ۱',
          date: DateTime(2026, 8, 29, 9),
          sequence: 1,
        ),
        TaskReminder(
          id: 'backup-r2',
          title: 'ارسال — یادآور ۲',
          date: DateTime(2026, 8, 30),
          isAllDay: true,
          sequence: 2,
        ),
      ]
      ..nextReminderSequence = 3;
    final fileName = await manager.backupCanonicalTasks([task]);

    expect(fileName, 'canonical-backup.json');
    final rawTasks = service.writtenPayload?['tasks'] as List<dynamic>;
    final restored = Task.fromJson(
      Map<String, dynamic>.from(rawTasks.single as Map),
    );

    expect(restored.id, 'task-full');
    expect(restored.category, 'فروش');
    expect(restored.checklist, ['تماس', 'ارسال فایل']);
    expect(restored.reminderDate, DateTime(2026, 8, 28, 10, 30));
    expect(restored.taskReminders, hasLength(3));
    expect(restored.taskReminders.map((item) => item.id), [
      'backup-r1',
      'backup-r2',
      'legacy-task-reminder',
    ]);
    expect(restored.taskReminders[1].isAllDay, isTrue);
    expect(restored.taskReminders.last.isLegacyTaskReminder, isTrue);
    expect(restored.taskReminders.last.date, restored.reminderDate);
    expect(restored.legacyTaskReminderMigrationVersion, 1);
    expect(restored.nextReminderSequence, 4);
    expect(restored.followUps, hasLength(1));
    expect(restored.followUps.single.note, 'تماس اول');
    expect(restored.followUps.single.result, 'منتظر پاسخ');
    expect(
      restored.followUps.single.reminderDate,
      DateTime(2026, 8, 28, 10, 15),
    );
    expect(
      restored.followUps.single.nextFollowUp,
      DateTime(2026, 8, 28, 10, 30),
    );
    expect(restored.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(restored.recurrence?.interval, 2);
    expect(restored.createdAt, DateTime(2026, 8, 20, 8));
    expect(restored.updatedAt, DateTime(2026, 8, 26, 12));
    expect(restored.completed, isTrue);
    expect(restored.completedAt, completedAt);
  });

  test('canonical backup preserves unassigned Category and Tag catalog entries', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);

    await manager.backupCanonicalTasks(
      [_completeTask()],
      categories: const ['فروش', 'شخصی', 'بدون کار متصل'],
      tags: const ['مهم', 'مشتری', 'بدون کار متصل'],
    );

    expect(service.writtenPayload?['categories'], [
      'فروش',
      'شخصی',
      'بدون کار متصل',
    ]);
    expect(service.writtenPayload?['tags'], [
      'مهم',
      'مشتری',
      'بدون کار متصل',
    ]);
  });

  test('TaskStore merges Category and Tag catalogs additively', () async {
    await TaskStore.resetTestDatabase();
    try {
      final store = TaskStore();
      await store.createCategory('دسته محلی');
      await store.createTag('برچسب محلی');

      await store.mergeCatalogs(
        categories: const ['دسته پشتیبان'],
        tags: const ['برچسب پشتیبان'],
      );

      expect(
        await store.loadCategories(),
        containsAll(['دسته محلی', 'دسته پشتیبان']),
      );
      expect(
        await store.loadTags(),
        containsAll(['برچسب محلی', 'برچسب پشتیبان']),
      );
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });

  test('TaskStore validates catalogs before making any catalog changes', () async {
    await TaskStore.resetTestDatabase();
    try {
      final store = TaskStore();
      await expectLater(
        store.mergeCatalogs(
          categories: const ['دسته جدید', 'دسته جدید'],
          tags: const ['برچسب جدید'],
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(await store.loadCategories(), isNot(contains('دسته جدید')));
      expect(await store.loadTags(), isNot(contains('برچسب جدید')));
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });

  test('canonical restore validates and returns optional Category and Tag catalogs', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
        'categories': ['فروش', 'شخصی'],
        'tags': ['مهم', 'مشتری'],
      };

    final candidate = await ArvinBackupManager(service: service)
        .restoreCanonicalBackup();

    expect(candidate?.categories, ['فروش', 'شخصی']);
    expect(candidate?.tags, ['مهم', 'مشتری']);
  });

  test('canonical restore rejects duplicate Category and Tag catalog entries', () async {
    for (final document in [
      {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
        'categories': ['شخصی', 'شخصی'],
      },
      {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
        'tags': ['مهم', 'مهم'],
      },
    ]) {
      final service = _FakeBackupService()..restoreDocument = document;
      await expectLater(
        ArvinBackupManager(service: service).restoreCanonicalBackup(),
        throwsA(isA<FormatException>()),
      );
    }
  });

  test('canonical backup carries projects in the same document', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);
    final project = ProjectPlan(id: 'project-1', title: 'پروژه اصلی', itemIds: const ['task-full']);

    await manager.backupCanonicalTasks([_completeTask()], projects: [project]);

    expect(service.writtenPayload?['projects'], isNotEmpty);
    expect((service.writtenPayload?['projects'] as List).single['id'], 'project-1');
  });

  test('canonical backup carries calendar link metadata in the same document', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);
    final link = ExternalCalendarEventLink(
      reminderId: 'task-due:task-full',
      calendarId: '42',
      eventId: 'event-1',
      lastSyncedFingerprint: 'fingerprint-1',
    );

    await manager.backupCanonicalTasks([_completeTask()], calendarLinks: [link]);

    expect(service.writtenPayload?['calendarLinks'], [link.toJson()]);
  });

  test('canonical restore returns validated calendar link metadata', () async {
    final link = ExternalCalendarEventLink(
      reminderId: 'task-due:task-full',
      calendarId: '42',
      eventId: 'event-1',
      lastSyncedFingerprint: 'fingerprint-1',
    );
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
        'calendarLinks': [link.toJson()],
      };

    final candidate = await ArvinBackupManager(service: service)
        .restoreCanonicalBackup();

    expect(candidate?.calendarLinks, hasLength(1));
    expect(candidate?.calendarLinks?.single.reminderId, link.reminderId);
    expect(candidate?.calendarLinks?.single.calendarId, link.calendarId);
    expect(candidate?.calendarLinks?.single.eventId, link.eventId);
    expect(
      candidate?.calendarLinks?.single.lastSyncedFingerprint,
      link.lastSyncedFingerprint,
    );
  });

  test('legacy backup without calendar links is distinguished from an empty link list', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
      };

    final candidate = await ArvinBackupManager(service: service)
        .restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.calendarLinks, isNull);
    expect(candidate.categories, isNull);
    expect(candidate.tags, isNull);
    expect(candidate.hasPeople, isFalse);
    expect(candidate.people, isNull);
  });

  test('canonical restore rejects duplicate calendar link identities', () async {
    final link = ExternalCalendarEventLink(
      reminderId: 'task-due:task-full',
      calendarId: '42',
      eventId: 'event-1',
      lastSyncedFingerprint: 'fingerprint-1',
    );
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
        'calendarLinks': [link.toJson(), link.toJson()],
      };

    await expectLater(
      ArvinBackupManager(service: service).restoreCanonicalBackup(),
      throwsA(isA<FormatException>()),
    );
  });

  test('canonical backup carries settings in the same document', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);

    await manager.backupCanonicalTasks(
      [_completeTask()],
      settings: const <String, dynamic>{
        'themeMode': 'dark',
        'usePersianDate': true,
        'fontFamily': 'VazirHarf',
      },
    );

    expect(service.writtenPayload?['settings'], {
      'themeMode': 'dark',
      'usePersianDate': true,
      'fontFamily': 'VazirHarf',
    });
  });

  test('manager routes backup passphrase without persisting it', () async {
    const passphrase = 'operation-only-secret';
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);

    await manager.backupCanonicalTasks(
      [_completeTask()],
      encryptionPassphrase: passphrase,
    );

    expect(service.writtenEncryptionPassphrase, passphrase);
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      expect('${prefs.get(key)}', isNot(contains(passphrase)));
    }
  });

  test('canonical restore decodes the complete Task without mutating storage', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
      };
    final manager = ArvinBackupManager(service: service);

    final restored = await manager.restoreCanonicalTasks();

    expect(restored, isNotNull);
    final task = restored!.single;
    expect(task.id, 'task-full');
    expect(task.category, 'فروش');
    expect(task.checklist, hasLength(2));
    expect(task.followUps.single.id, 'fu-1');
    expect(task.recurrence?.interval, 2);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('arvin.tasks'), isNull);
  });

  test('manager routes restore passphrase to the service', () async {
    const passphrase = 'restore-only-secret';
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
      };
    final manager = ArvinBackupManager(service: service);

    final candidate = await manager.restoreCanonicalBackup(
      passphrase: passphrase,
    );

    expect(candidate, isNotNull);
    expect(service.readPassphrase, passphrase);
  });

  test('canonical restore candidate returns tasks, settings and projects together', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
        'settings': <String, dynamic>{
          'themeMode': 'light',
          'usePersianDate': true,
        },
        'projects': <Map<String, dynamic>>[
          {
            'id': 'project-1',
            'title': 'پروژه اصلی',
            'colorValue': 0xFF4A4CAB,
            'isArchived': false,
            'itemIds': <String>['task-full'],
          },
        ],
      };
    final manager = ArvinBackupManager(service: service);

    final candidate = await manager.restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.tasks.single.id, 'task-full');
    expect(candidate.projects.single.id, 'project-1');
    expect(candidate.projects.single.itemIds, ['task-full']);
    expect(candidate.settings, {
      'themeMode': 'light',
      'usePersianDate': true,
    });
  });

  test('legacy task-only restore candidate remains valid', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
      };
    final manager = ArvinBackupManager(service: service);

    final candidate = await manager.restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.tasks, hasLength(1));
    expect(candidate.settings, isNull);
  });

  test('canonical restore rejects duplicate Task ids', () async {
    final task = _completeTask();
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [task.toJson(), task.toJson()],
      };
    final manager = ArvinBackupManager(service: service);

    await expectLater(
      manager.restoreCanonicalTasks(),
      throwsA(isA<FormatException>()),
    );
  });

  test('golden flow round-trips Task data through canonical backup and restore', () async {
    await TaskStore.resetTestDatabase();
    final task = Task(
      id: 'golden-flow-task',
      title: 'آماده‌سازی جلسه',
      description: 'مسیر کامل انتشار باید بدون از دست رفتن داده حفظ شود',
      createdAt: DateTime(2026, 10, 7, 8, 0),
      updatedAt: DateTime(2026, 10, 7, 8, 30),
      dueDate: DateTime(2026, 10, 8, 9, 15),
      reminderDate: DateTime(2026, 10, 8, 9),
      followUpEnabled: true,
      followUpDate: DateTime(2026, 10, 9, 10),
      tags: const ['مهم', 'جلسه'],
      category: 'کار',
      checklist: const ['[ ] آماده‌سازی فایل', '[x] هماهنگی'],
      checklistOccurrences: {
        '2026-10-08T09:15:00.000': const ['[x] آماده‌سازی فایل', '[x] هماهنگی'],
      },
      occurrenceHistory: {
        '2026-10-08T09:15:00.000': {
          'scheduledDate': '2026-10-08T09:15:00.000',
          'status': RecurrenceOccurrenceStatus.completed.name,
          'completionDate': '2026-10-08T09:30:00.000',
          'result': 'جلسه انجام شد',
        },
      },
      followUps: [
        FollowUp(
          id: 'golden-flow-followup',
          dateTime: DateTime(2026, 10, 9, 10),
          note: 'نتیجه جلسه پیگیری شود',
          result: 'منتظر پاسخ',
          nextFollowUp: DateTime(2026, 10, 10, 11),
        ),
      ],
      recurrence: const RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 2,
      ),
    );

    final store = TaskStore();
    await store.save([task]);

    final backupService = _FakeBackupService();
    final manager = ArvinBackupManager(service: backupService);
    final project = ProjectPlan(
      id: 'golden-flow-project',
      title: 'پروژه انتشار',
      itemIds: const ['golden-flow-task'],
    );

    final persistedBeforeBackup = (await store.load()).single;
    await manager.backupCanonicalTasks(
      [persistedBeforeBackup],
      projects: [project],
      settings: const <String, dynamic>{'themeMode': 'light'},
    );

    backupService.restoreDocument = backupService.writtenPayload;
    final candidate = await manager.restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.projects.single.id, 'golden-flow-project');
    expect(candidate.hasProjects, isTrue);
    expect(candidate.settings, {'themeMode': 'light'});
    expect(candidate.tasks.single.id, 'golden-flow-task');

    await TaskStore.resetTestDatabase();
    await TaskStore().save(candidate.tasks);
    final restored = (await TaskStore().load()).single;

    expect(restored.title, 'آماده‌سازی جلسه');
    expect(restored.dueDate, DateTime(2026, 10, 8, 9, 15));
    expect(restored.reminderDate, DateTime(2026, 10, 8, 9));
    expect(restored.category, 'کار');
    expect(restored.tags, ['مهم', 'جلسه']);
    expect(restored.checklist, ['[ ] آماده‌سازی فایل', '[x] هماهنگی']);
    expect(restored.checklistOccurrences, {
      '2026-10-08T09:15:00.000': const ['[x] آماده‌سازی فایل', '[x] هماهنگی'],
    });
    expect(restored.occurrenceHistory, {
      '2026-10-08T09:15:00.000': {
        'scheduledDate': '2026-10-08T09:15:00.000',
        'status': RecurrenceOccurrenceStatus.completed.name,
        'completionDate': '2026-10-08T09:30:00.000',
        'result': 'جلسه انجام شد',
      },
    });
    expect(restored.recurrence?.frequency, RecurrenceFrequency.daily);
    expect(restored.recurrence?.interval, 2);
    expect(restored.followUps.single.id, 'golden-flow-followup');
    expect(restored.followUps.single.nextFollowUp, DateTime(2026, 10, 10, 11));
  });

  test('restore distinguishes omitted, null, and explicit empty Projects fields', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);
    final base = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'tasks': <Map<String, dynamic>>[],
    };

    service.restoreDocument = Map<String, dynamic>.of(base);
    final legacy = await manager.restoreCanonicalBackup();
    expect(legacy, isNotNull);
    expect(legacy!.hasProjects, isFalse);
    expect(legacy.projects, isEmpty);

    service.restoreDocument = <String, dynamic>{...base, 'projects': null};
    final nullField = await manager.restoreCanonicalBackup();
    expect(nullField, isNotNull);
    expect(nullField!.hasProjects, isFalse);

    service.restoreDocument = <String, dynamic>{
      ...base,
      'projects': <Map<String, dynamic>>[],
    };
    final explicitEmpty = await manager.restoreCanonicalBackup();
    expect(explicitEmpty, isNotNull);
    expect(explicitEmpty!.hasProjects, isTrue);
    expect(explicitEmpty.projects, isEmpty);
  });

  test('canonical backup and restore preserve disabled checklist rows', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);
    final task = Task(
      id: 'disabled-checklist-backup',
      title: 'کار با چک‌لیست خاموش',
      checklist: const ['[ ] کیف', '[x] کتاب'],
      checklistEnabled: false,
    );

    await manager.backupCanonicalTasks([task]);
    service.restoreDocument = service.writtenPayload;
    final restored = await manager.restoreCanonicalTasks();

    expect(restored, hasLength(1));
    expect(restored!.single.checklistEnabled, isFalse);
    expect(restored.single.checklist, const ['[ ] کیف', '[x] کتاب']);
  });

  test('restore failure rolls the user state back before reporting failure', () async {
    var tasks = <String>['old task'];
    var catalogs = <String>['old category'];

    await expectLater(
      runRestoreWithRollback<void>(
        recoveryBackup: 'emergency-backup.json',
        apply: () async {
          tasks = <String>['partially restored task'];
          catalogs = <String>['partially restored category'];
          throw StateError('injected later-stage failure');
        },
        rollback: () async {
          tasks = <String>['old task'];
          catalogs = <String>['old category'];
        },
      ),
      throwsA(
        isA<RestoreExecutionFailure>()
            .having((error) => error.rolledBack, 'rolledBack', isTrue)
            .having((error) => error.recoveryBackup, 'recoveryBackup',
                'emergency-backup.json'),
      ),
    );

    expect(tasks, <String>['old task']);
    expect(catalogs, <String>['old category']);
  });

  test('restore failure preserves emergency backup reference if rollback fails', () async {
    await expectLater(
      runRestoreWithRollback<void>(
        recoveryBackup: 'emergency-backup.json',
        apply: () async => throw StateError('restore failed'),
        rollback: () async => throw StateError('rollback failed'),
      ),
      throwsA(
        isA<RestoreExecutionFailure>()
            .having((error) => error.rolledBack, 'rolledBack', isFalse)
            .having((error) => error.recoveryBackup, 'recoveryBackup',
                'emergency-backup.json'),
      ),
    );
  });


  test('late restore failure rolls back durable stores and preserves catalogs', () async {
    await TaskStore.resetTestDatabase();
    await ProjectStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
      'restore-test.settings': 'old-settings',
    });
    final taskStore = TaskStore();
    final projectStore = ProjectStore();
    final linkStore = ExternalCalendarLinkStore(
      preferencesKey: 'restore-test.calendar-links',
    );
    final oldTask = Task(id: 'old-task', title: 'کار قبلی');
    final restoredTask = Task(id: 'restored-task', title: 'کار بازیابی‌شده');
    final oldProject = ProjectPlan(
      id: 'old-project',
      title: 'پروژه قبلی',
      itemIds: const [],
    );
    final restoredProject = ProjectPlan(
      id: 'restored-project',
      title: 'پروژه بازیابی‌شده',
      itemIds: const [],
    );
    final oldLink = ExternalCalendarEventLink(
      reminderId: 'task-due:old-task',
      calendarId: 'calendar-old',
      eventId: 'event-old',
      lastSyncedFingerprint: 'old-fingerprint',
    );
    final restoredLink = ExternalCalendarEventLink(
      reminderId: 'task-due:restored-task',
      calendarId: 'calendar-new',
      eventId: 'event-new',
      lastSyncedFingerprint: 'new-fingerprint',
    );

    try {
      await taskStore.save([oldTask]);
      await taskStore.createCategory('دسته قبلی');
      await taskStore.createTag('برچسب قبلی');
      await projectStore.save([oldProject]);
      await linkStore.save([oldLink]);

      final prefs = await SharedPreferences.getInstance();
      final oldSettings = prefs.getString('restore-test.settings');

      await expectLater(
        runRestoreWithRollback<void>(
          recoveryBackup: 'emergency-backup.json',
          apply: () async {
            await taskStore.save([restoredTask]);
            await projectStore.save([restoredProject]);
            await linkStore.save([restoredLink]);
            await prefs.setString('restore-test.settings', 'new-settings');
            // Simulates a late restore-stage failure before the final catalog
            // merge, matching the production ordering where catalogs are last.
            throw StateError('injected after durable store writes');
          },
          rollback: () async {
            await taskStore.save([oldTask]);
            await projectStore.save([oldProject]);
            await linkStore.save([oldLink]);
            if (oldSettings == null) {
              await prefs.remove('restore-test.settings');
            } else {
              await prefs.setString('restore-test.settings', oldSettings);
            }
          },
        ),
        throwsA(
          isA<RestoreExecutionFailure>()
              .having((error) => error.rolledBack, 'rolledBack', isTrue)
              .having(
                (error) => error.recoveryBackup,
                'recoveryBackup',
                'emergency-backup.json',
              ),
        ),
      );

      expect((await taskStore.load()).map((task) => task.id), ['old-task']);
      expect((await projectStore.load()).map((project) => project.id), [
        'old-project',
      ]);
      expect((await linkStore.load()).map((link) => link.eventId), [
        'event-old',
      ]);
      expect(prefs.getString('restore-test.settings'), 'old-settings');
      expect(await taskStore.loadCategories(), contains('دسته قبلی'));
      expect(await taskStore.loadTags(), contains('برچسب قبلی'));
      expect(await taskStore.loadCategories(), isNot(contains('دسته بازیابی‌شده')));
      expect(await taskStore.loadTags(), isNot(contains('برچسب بازیابی‌شده')));
    } finally {
      await TaskStore.resetTestDatabase();
      await ProjectStore.resetTestDatabase();
    }
  });


  test('canonical backup preserves standalone people and follow-up associations', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);
    final person = PersonReference(id: 'person-orphan', displayName: 'فرد مستقل');
    final task = _completeTask();
    task.followUps = [
      FollowUp(
        id: 'fu-person-linked',
        dateTime: DateTime(2026, 10, 15, 9),
        note: 'پیگیری مرتبط با فرد',
        personIds: const ['person-orphan'],
      ),
    ];

    await manager.backupCanonicalTasks([task], people: [person]);
    final payload = service.writtenPayload!;
    expect(payload['peopleDirectory'], [person.toJson()]);

    service.restoreDocument = payload;
    final candidate = await manager.restoreCanonicalBackup();
    expect(candidate?.hasPeople, isTrue);
    expect(candidate?.people?.single.id, 'person-orphan');
    expect(candidate?.people?.single.displayName, 'فرد مستقل');
    expect(candidate?.tasks.single.followUps.single.personIds, ['person-orphan']);
  });

  test('TaskStore persists orphan people and follow-up person links', () async {
    await TaskStore.resetTestDatabase();
    try {
      final store = TaskStore();
      final person = PersonReference(id: 'person-orphan', displayName: 'فرد مستقل');
      await store.savePeopleDirectory([person]);
      final task = _completeTask();
      task.followUps = [
        FollowUp(
          id: 'fu-person-linked',
          dateTime: DateTime(2026, 10, 15, 9),
          personIds: const ['person-orphan'],
        ),
      ];
      await store.save([task]);

      final restored = (await store.load()).single;
      expect((await store.loadPeopleDirectory()).map((value) => value.id),
          contains('person-orphan'));
      expect(restored.followUps.single.personIds, ['person-orphan']);
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });


  test('restore rejects dangling follow-up person IDs before mutation', () async {
    final service = _FakeBackupService()
      ..restoreDocument = <String, dynamic>{
        'tasks': [
          (_completeTask()
                ..followUps = [
                  FollowUp(
                    id: 'fu-dangling',
                    dateTime: DateTime(2026, 10, 15, 9),
                    personIds: const ['missing-person'],
                  ),
                ])
              .toJson(),
        ],
        'peopleDirectory': const <Map<String, dynamic>>[],
      };
    final manager = ArvinBackupManager(service: service);

    await expectLater(
      manager.restoreCanonicalBackup(),
      throwsA(isA<FormatException>()),
    );
  });

  test('people directory rolls back after injected restore failure', () async {
    await TaskStore.resetTestDatabase();
    try {
      final store = TaskStore();
      final oldPerson = PersonReference(id: 'person-old', displayName: 'قدیمی');
      final incomingPerson = PersonReference(id: 'person-new', displayName: 'جدید');
      await store.savePeopleDirectory([oldPerson]);

      await expectLater(
        runRestoreWithRollback<void>(
          recoveryBackup: 'emergency-backup.json',
          apply: () async {
            await store.savePeopleDirectory([oldPerson, incomingPerson]);
            throw StateError('injected after people-directory write');
          },
          rollback: () async {
            await store.savePeopleDirectory([oldPerson]);
          },
        ),
        throwsA(isA<RestoreExecutionFailure>().having(
          (error) => error.rolledBack,
          'rolledBack',
          isTrue,
        )),
      );

      expect(
        (await store.loadPeopleDirectory()).map((person) => person.id),
        ['person-old'],
      );
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });


  test('backup restore after clean database preserves a standalone person', () async {
    await TaskStore.resetTestDatabase();
    try {
      final store = TaskStore();
      final person = PersonReference(id: 'person-clean-db', displayName: 'فرد مستقل');
      await store.savePeopleDirectory([person]);
      final service = _FakeBackupService();
      final manager = ArvinBackupManager(service: service);

      await manager.backupCanonicalTasks(await store.load(),
          people: await store.loadPeopleDirectory());
      service.restoreDocument = service.writtenPayload;

      await TaskStore.resetTestDatabase();
      final restored = await manager.restoreCanonicalBackup();
      expect(restored, isNotNull);
      expect(restored!.hasPeople, isTrue);

      final cleanStore = TaskStore();
      await cleanStore.save(restored.tasks);
      await cleanStore.savePeopleDirectory(restored.people!);
      final people = await cleanStore.loadPeopleDirectory();
      expect(people.map((value) => value.id), ['person-clean-db']);
      expect(people.single.displayName, 'فرد مستقل');
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });

  test('backup restore preserves task_people and seeds the directory', () async {
    await TaskStore.resetTestDatabase();
    try {
      final store = TaskStore();
      final person = PersonReference(id: 'person-task-link', displayName: 'همکار');
      final task = Task.fromJson({..._completeTask().toJson(), 'people': [person.toJson()]});
      await store.save([task]);
      expect((await store.loadPeopleDirectory()).map((p) => p.id),
          contains('person-task-link'));

      final service = _FakeBackupService();
      final manager = ArvinBackupManager(service: service);
      await manager.backupCanonicalTasks(await store.load(),
          people: await store.loadPeopleDirectory());
      service.restoreDocument = service.writtenPayload;

      await TaskStore.resetTestDatabase();
      final candidate = await manager.restoreCanonicalBackup();
      expect(candidate, isNotNull);
      final cleanStore = TaskStore();
      await cleanStore.save(candidate!.tasks);
      await cleanStore.savePeopleDirectory(candidate.people!);

      final restoredTask = (await cleanStore.load()).single;
      expect(restoredTask.people.map((p) => p.id), ['person-task-link']);
      expect((await cleanStore.loadPeopleDirectory()).map((p) => p.id),
          contains('person-task-link'));
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });

  test('legacy backup without peopleDirectory restores and migrates task people', () async {
    await TaskStore.resetTestDatabase();
    try {
      final task = Task.fromJson({
        ..._completeTask().toJson(),
        'people': [PersonReference(id: 'person-legacy', displayName: 'قدیمی').toJson()],
      });
      final service = _FakeBackupService()
        ..restoreDocument = <String, dynamic>{
          'tasks': [task.toJson()],
        };
      final manager = ArvinBackupManager(service: service);
      final candidate = await manager.restoreCanonicalBackup();
      expect(candidate, isNotNull);
      expect(candidate!.hasPeople, isFalse);

      final store = TaskStore();
      await store.save(candidate.tasks);
      expect((await store.loadPeopleDirectory()).map((p) => p.id),
          contains('person-legacy'));
    } finally {
      await TaskStore.resetTestDatabase();
    }
  });

}
