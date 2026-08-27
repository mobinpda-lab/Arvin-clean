import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
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

  test('canonical backup carries settings in the same document', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);

    await manager.backupCanonicalTasks(
      [_completeTask()],
      settings: const <String, dynamic>{
        'themeMode': 'dark',
        'usePersianDate': true,
        'fontFamily': 'Vazirmatn',
      },
    );

    expect(service.writtenPayload?['settings'], {
      'themeMode': 'dark',
      'usePersianDate': true,
      'fontFamily': 'Vazirmatn',
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

  test('canonical restore candidate returns tasks and optional settings together', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_completeTask().toJson()],
        'settings': <String, dynamic>{
          'themeMode': 'light',
          'usePersianDate': true,
        },
      };
    final manager = ArvinBackupManager(service: service);

    final candidate = await manager.restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.tasks.single.id, 'task-full');
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
}
