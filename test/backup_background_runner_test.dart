import 'package:arvin/backup_background_runner.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/backup_notification_service.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBackupService extends ArvinBackupService {
  _FakeBackupService({this.shouldFail = false});

  final bool shouldFail;
  bool wroteBackup = false;
  String? writtenFileName;
  Map<String, dynamic>? writtenPayload;

  @override
  String createBackupFileName(DateTime dateTime) => 'test-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = false,
  }) async {
    if (shouldFail) throw StateError('backup failed');
    wroteBackup = true;
    writtenFileName = fileName;
    writtenPayload = payload;
  }
}

class _FakeNotificationSink implements BackupNotificationSink {
  final List<String> successes = <String>[];
  final List<String> failures = <String>[];

  @override
  Future<void> showSuccess(String fileName) async => successes.add(fileName);

  @override
  Future<void> showFailure(String message) async => failures.add(message);
}

class _ThrowingTaskStore extends TaskStore {
  @override
  Future<List<Task>> load() async {
    throw const FormatException('invalid stored tasks');
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('persists background backup configuration', () async {
    await BackupBackgroundRunner.saveConfiguration(
      directoryUri: 'content://arvin/backups',
      payload: <String, dynamic>{'tasks': <Map<String, dynamic>>[{'title': 'Task 1'}]},
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(BackupBackgroundRunner.directoryUriKey), 'content://arvin/backups');
    expect(prefs.getString(BackupBackgroundRunner.payloadKey), contains('Task 1'));
  });

  test('returns false when background configuration is missing', () async {
    expect(await const BackupBackgroundRunner().run(), isFalse);
  });

  test('clears background backup configuration', () async {
    await BackupBackgroundRunner.saveConfiguration(
      directoryUri: 'content://arvin/backups',
      payload: <String, dynamic>{'tasks': <dynamic>[]},
    );
    await BackupBackgroundRunner.clearConfiguration();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(BackupBackgroundRunner.directoryUriKey), isFalse);
    expect(prefs.containsKey(BackupBackgroundRunner.payloadKey), isFalse);
  });

  test('backs up the current TaskStore data end to end', () async {
    final taskStore = TaskStore();
    final task = Task(
      id: 'e2e-1',
      title: 'پشتیبان‌گیری واقعی',
      description: 'آخرین اطلاعات کاربر',
      tags: <String>['کار'],
    );
    await taskStore.save(<Task>[task]);
    await BackupBackgroundRunner.saveConfiguration(
      directoryUri: 'content://arvin/backups',
      payload: <String, dynamic>{
        'tasks': <Map<String, dynamic>>[
          {'id': 'stale', 'title': 'Old snapshot'},
        ],
      },
    );

    final service = _FakeBackupService();
    final notifications = _FakeNotificationSink();
    final result = await BackupBackgroundRunner(
      backupService: service,
      notificationSink: notifications,
      taskStore: taskStore,
    ).run();

    expect(result, isTrue);
    final backedUpTasks = service.writtenPayload?['tasks'] as List;
    expect(backedUpTasks, hasLength(1));
    expect(backedUpTasks.single['id'], 'e2e-1');
    expect(backedUpTasks.single['title'], 'پشتیبان‌گیری واقعی');
    expect(backedUpTasks.single['description'], 'آخرین اطلاعات کاربر');
    expect(backedUpTasks.single['tags'], ['کار']);
    expect(notifications.successes, ['test-backup.json']);
  });

  test('uses the latest tasks from TaskStore instead of the scheduled snapshot', () async {
    await BackupBackgroundRunner.saveConfiguration(
      directoryUri: 'content://arvin/backups',
      payload: <String, dynamic>{'tasks': <Map<String, dynamic>>[{'id': 'old', 'title': 'Old snapshot'}]},
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arvin.tasks', '[{"id":"latest","title":"Latest task","description":"Updated","followUpDate":null,"tags":["کار"],"archived":false,"trashed":false}]');
    final service = _FakeBackupService();
    final notifications = _FakeNotificationSink();
    final result = await BackupBackgroundRunner(backupService: service, notificationSink: notifications).run();
    expect(result, isTrue);
    expect(service.writtenPayload?['tasks'], hasLength(1));
    expect((service.writtenPayload?['tasks'] as List).single['title'], 'Latest task');
    expect(notifications.successes, ['test-backup.json']);
  });

  test('shows success notification after a background backup', () async {
    await BackupBackgroundRunner.saveConfiguration(directoryUri: 'content://arvin/backups', payload: <String, dynamic>{'tasks': <dynamic>[]});
    final service = _FakeBackupService();
    final notifications = _FakeNotificationSink();
    final result = await BackupBackgroundRunner(backupService: service, notificationSink: notifications).run();
    expect(result, isTrue);
    expect(service.wroteBackup, isTrue);
    expect(service.writtenFileName, 'test-backup.json');
    expect(notifications.successes, ['test-backup.json']);
    expect(notifications.failures, isEmpty);
  });

  test('shows failure notification when background backup fails', () async {
    await BackupBackgroundRunner.saveConfiguration(directoryUri: 'content://arvin/backups', payload: <String, dynamic>{'tasks': <dynamic>[]});
    final notifications = _FakeNotificationSink();
    final result = await BackupBackgroundRunner(backupService: _FakeBackupService(shouldFail: true), notificationSink: notifications).run();
    expect(result, isFalse);
    expect(notifications.successes, isEmpty);
    expect(notifications.failures.single, contains('backup failed'));
  });

  test('shows failure notification when stored tasks are invalid', () async {
    await BackupBackgroundRunner.saveConfiguration(directoryUri: 'content://arvin/backups', payload: <String, dynamic>{'tasks': <dynamic>[]});
    final notifications = _FakeNotificationSink();
    final result = await BackupBackgroundRunner(backupService: _FakeBackupService(), notificationSink: notifications, taskStore: _ThrowingTaskStore()).run();
    expect(result, isFalse);
    expect(notifications.failures, hasLength(1));
    expect(notifications.failures.single, contains('invalid stored tasks'));
  });
}
