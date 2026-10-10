import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/calendar_sync_plan_service.dart';
import 'package:arvin/services/external_calendar_link_store.dart';
import 'package:arvin/services/task_store.dart';
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

    final fileName = await manager.backupCanonicalTasks([_completeTask()]);

    expect(fileName, 'canonical-backup.json');
    final rawTasks = service.writtenPayload?['tasks'] as List<dynamic>;
    final restored = Task.fromJson(
      Map<String, dynamic>.from(rawTasks.single as Map),
    );

    expect(restored.id, 'task-full');
    expect(restored.category, 'فروش');
    expect(restored.checklist, ['تماس', 'ارسال فایل']);
    expect(restored.reminderDate, DateTime(2026, 8, 28, 10, 30));
    expect(restored.followUps, hasLength(1));
    expect(restored.followUps.single.note, 'تماس اول');
    expect(restored.followUps.single.result, 'منتظر پاسخ');
    expect(
      restored.followUps.single.nextFollowUp,
      DateTime(2026, 8, 28, 10, 30),
    );
    expect(restored.recurrence?.frequency, RecurrenceFrequency.weekly);
    expect(restored.recurrence?.interval, 2);
    expect(restored.createdAt, DateTime(2026, 8, 20, 8));
    expect(restored.updatedAt, DateTime(2026, 8, 26, 12));
  });

  test('canonical backup preserves Calendar link identity in the same document', () async {
    final service = _FakeBackupService();
    final link = ExternalCalendarEventLink(
      reminderId: 'task-due:task-full',
      calendarId: 'calendar-1',
      eventId: 'event-9',
      lastSyncedFingerprint: 'fingerprint-1',
    );
    await ExternalCalendarLinkStore().save([link]);

    await ArvinBackupManager(
      service: service,
    ).backupCanonicalTasks([_completeTask()]);

    final links = service.writtenPayload?['calendarLinks'] as List<dynamic>;
    expect(links, hasLength(1));
    final restoredLink = ExternalCalendarEventLink.fromJson(
      Map<String, dynamic>.from(links.single as Map),
    );
    expect(restoredLink.eventId, 'event-9');
  });

  test('canonical backup carries projects in the same document', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);
    final project = ProjectPlan(id: 'project-1', title: 'پروژه اصلی', itemIds: const ['task-full']);

    await manager.backupCanonicalTasks([_completeTask()], projects: [project]);

    expect(service.writtenPayload?['projects'], isNotEmpty);
    expect((service.writtenPayload?['projects'] as List).single['id'], 'project-1');
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

  test('canonical restore decodes Calendar links without provider writes', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
        'calendarLinks': [
          {
            'reminderId': 'task-due:task-full',
            'calendarId': 'calendar-1',
            'eventId': 'event-9',
            'lastSyncedFingerprint': 'fingerprint-1',
          },
        ],
      };

    final candidate = await ArvinBackupManager(
      service: service,
    ).restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.calendarLinks, hasLength(1));
    expect(candidate.calendarLinks!.single.calendarId, 'calendar-1');
    expect(candidate.calendarLinks!.single.eventId, 'event-9');
    expect((await ExternalCalendarLinkStore().load()), isEmpty);
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
    expect(candidate.calendarLinks, isNull);
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

}
