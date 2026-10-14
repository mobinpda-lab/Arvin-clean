import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PersonBackupService extends ArvinBackupService {
  Map<String, dynamic>? restoreDocument;

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async =>
      restoreDocument;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await TaskStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  test('restore rejects structured Follow-up Person links without directory field', () async {
    final service = _PersonBackupService()
      ..restoreDocument = <String, dynamic>{
        'tasks': <Map<String, dynamic>>[
          Task(
            id: 'task-ali',
            title: 'تماس با علی',
            followUps: [
              FollowUp(
                id: 'follow-up-ali',
                dateTime: DateTime(2026, 10, 14, 9),
                waitingForResponse: true,
                personIds: const ['person-ali'],
              ),
            ],
          ).toJson(),
        ],
      };
    final manager = ArvinBackupManager(service: service);

    await expectLater(
      manager.restoreCanonicalBackup(),
      throwsA(isA<FormatException>()),
    );
  });

  test('restore rejects dangling Person IDs before applying data', () async {
    final service = _PersonBackupService()
      ..restoreDocument = <String, dynamic>{
        'tasks': <Map<String, dynamic>>[
          Task(
            id: 'task-ali',
            title: 'تماس با علی',
            followUps: [
              FollowUp(
                id: 'follow-up-ali',
                dateTime: DateTime(2026, 10, 14, 9),
                personIds: const ['person-unknown'],
              ),
            ],
          ).toJson(),
        ],
        'people': <Map<String, dynamic>>[
          PersonReference(id: 'person-sara', displayName: 'سارا').toJson(),
        ],
      };
    final manager = ArvinBackupManager(service: service);

    await expectLater(
      manager.restoreCanonicalBackup(),
      throwsA(isA<FormatException>()),
    );
  });

  test('valid directory round-trip retains stable IDs and legacy backups remain readable', () async {
    final person = PersonReference(id: 'person-ali', displayName: 'علی رضایی');
    final task = Task(
      id: 'task-ali',
      title: 'تماس با علی',
      followUps: [
        FollowUp(
          id: 'follow-up-ali',
          dateTime: DateTime(2026, 10, 14, 9),
          waitingForResponse: true,
          personIds: [person.id],
          nextFollowUp: DateTime(2026, 10, 15, 10),
          reminderDate: DateTime(2026, 10, 14, 18),
        ),
      ],
    );
    final service = _PersonBackupService()
      ..restoreDocument = <String, dynamic>{
        'tasks': <Map<String, dynamic>>[task.toJson()],
        'people': <Map<String, dynamic>>[person.toJson()],
      };
    final manager = ArvinBackupManager(service: service);
    final candidate = await manager.restoreCanonicalBackup();

    expect(candidate!.people!.single.id, person.id);
    expect(candidate.tasks.single.followUps.single.personIds, [person.id]);
    expect(candidate.tasks.single.followUps.single.waitingForResponse, isTrue);
    expect(
      candidate.tasks.single.followUps.single.nextFollowUp,
      DateTime(2026, 10, 15, 10),
    );
    expect(
      candidate.tasks.single.followUps.single.reminderDate,
      DateTime(2026, 10, 14, 18),
    );

    service.restoreDocument = <String, dynamic>{
      'tasks': <Map<String, dynamic>>[
        Task(id: 'legacy-task', title: 'کار قدیمی').toJson(),
      ],
    };
    final legacy = await manager.restoreCanonicalBackup();
    expect(legacy!.people, isNull);
    expect(legacy.tasks.single.id, 'legacy-task');
  });
  test('injected restore failure rolls back both Person directory and canonical Task/Follow-up data', () async {
    final store = TaskStore();
    final originalPerson = PersonReference(id: 'person-original', displayName: 'شخص اصلی');
    await store.savePersonDirectoryEntry(originalPerson);
    await store.save([
      Task(
        id: 'task-original',
        title: 'کار اصلی',
        followUps: [
          FollowUp(
            id: 'follow-up-original',
            dateTime: DateTime(2026, 10, 14, 9),
            waitingForResponse: true,
            personIds: [originalPerson.id],
          ),
        ],
      ),
    ]);
    final beforeTasks = await store.load();
    final beforePeople = await store.loadPeopleDirectory();

    await expectLater(
      runRestoreWithRollback<void>(
        recoveryBackup: 'in-memory-recovery',
        apply: () async {
          await store.save([
            Task(
              id: 'task-incoming',
              title: 'کار واردشده',
              followUps: [
                FollowUp(
                  id: 'follow-up-incoming',
                  dateTime: DateTime(2026, 10, 15, 9),
                ),
              ],
            ),
          ]);
          await store.restorePeopleDirectoryEntries([
            PersonReference(id: 'person-incoming', displayName: 'شخص واردشده'),
          ], replace: true);
          throw StateError('injected failure after Person restore');
        },
        rollback: () async {
          await store.save(beforeTasks);
          await store.restorePeopleDirectoryEntries(beforePeople, replace: true);
        },
      ),
      throwsA(isA<RestoreExecutionFailure>()),
    );

    final restoredTasks = await store.load();
    expect(restoredTasks.map((task) => task.id), ['task-original']);
    expect(restoredTasks.single.followUps.single.id, 'follow-up-original');
    expect(restoredTasks.single.followUps.single.personIds, [originalPerson.id]);
    expect((await store.loadPeopleDirectory()).map((person) => person.id), [originalPerson.id]);
  });

}
