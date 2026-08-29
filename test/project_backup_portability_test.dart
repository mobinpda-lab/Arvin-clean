import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBackupService extends ArvinBackupService {
  Map<String, dynamic>? writtenPayload;
  Map<String, dynamic>? restoreDocument;

  @override
  String createBackupFileName(DateTime dateTime) => 'projects-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writtenPayload = payload;
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    return restoreDocument;
  }
}

Task _task(String id) => Task(
      id: id,
      title: 'کار $id',
      createdAt: DateTime(2026, 8, 29),
      updatedAt: DateTime(2026, 8, 29),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
    });
  });

  test('projects use the existing canonical backup document', () async {
    final service = _FakeBackupService();
    final manager = ArvinBackupManager(service: service);
    final project = ProjectPlan(
      id: 'project-1',
      title: 'کاری',
      colorValue: 0xFF2F80ED,
      itemIds: const ['task-1'],
    );

    await manager.backupCanonicalTasks(
      [_task('task-1')],
      projects: [project],
    );

    expect(service.writtenPayload?['tasks'], hasLength(1));
    expect(service.writtenPayload?['projects'], [
      {
        'id': 'project-1',
        'title': 'کاری',
        'colorValue': 0xFF2F80ED,
        'itemIds': ['task-1'],
      },
    ]);
  });

  test('canonical restore returns projects with task membership intact', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_task('task-1').toJson()],
        'projects': [
          {
            'id': 'project-1',
            'title': 'کاری',
            'colorValue': 0xFF2F80ED,
            'itemIds': ['task-1'],
          },
        ],
      };

    final candidate =
        await ArvinBackupManager(service: service).restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.projects, hasLength(1));
    expect(candidate.projects.single.title, 'کاری');
    expect(candidate.projects.single.colorValue, 0xFF2F80ED);
    expect(candidate.projects.single.itemIds, ['task-1']);
  });

  test('legacy backup without projects remains valid', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_task('task-1').toJson()],
      };

    final candidate =
        await ArvinBackupManager(service: service).restoreCanonicalBackup();

    expect(candidate, isNotNull);
    expect(candidate!.projects, isEmpty);
  });

  test('restore rejects duplicate canonical project ids', () async {
    final service = _FakeBackupService()
      ..restoreDocument = {
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': [_task('task-1').toJson()],
        'projects': [
          {'id': 'dup', 'title': 'الف'},
          {'id': 'dup', 'title': 'ب'},
        ],
      };

    await expectLater(
      ArvinBackupManager(service: service).restoreCanonicalBackup(),
      throwsA(isA<FormatException>()),
    );
  });
}
