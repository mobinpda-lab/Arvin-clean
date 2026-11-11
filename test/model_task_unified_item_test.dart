import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';

void main() {
  test('All-Day due dates serialize as floating calendar dates', () {
    final task = Task(
      id: 'all-day-due',
      title: 'کار بدون ساعت',
      dueDate: DateTime(2026, 11, 8),
      allDay: true,
    );

    expect(task.toJson()['dueDate'], '2026-11-08');
    expect(task.toJson()['allDay'], isTrue);
  });

  test('an ordinary task without follow-ups is not a Notebook note', () {
    final task = Task(id: 'task-1', title: 'کار عادی');

    expect(task.isSimpleNote, isFalse);
    expect(task.isNotebookItem, isFalse);
    expect(task.followUpEnabled, isFalse);
  });

  test('an explicit Notebook note remains a note after follow-up is enabled', () {
    final task = Task(
      id: 'note-1',
      title: 'یادداشت پیگیری‌دار',
      notebookKind: NotebookItemKind.note,
      followUpEnabled: true,
      followUps: [
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 9, 19, 11),
          note: 'پیگیری ثبت شد',
        ),
      ],
    );

    expect(task.isSimpleNote, isTrue);
    expect(task.isNotebookItem, isTrue);
  });

  test('direct legacy Follow-up constructor inputs survive as inert metadata', () {
    final legacyTaskDate = DateTime(2026, 8, 14, 9, 30);
    final legacyNextDate = DateTime(2026, 8, 16, 11, 45);
    final task = Task(
      id: 'direct-legacy-follow-up',
      title: 'حفظ سازگاری',
      followUpEnabled: true,
      followUpDate: legacyTaskDate,
      followUps: [
        FollowUp(
          id: 'legacy-follow-up-record',
          completedAt: DateTime(2026, 8, 12, 8),
          nextFollowUp: legacyNextDate,
        ),
      ],
    );
    expect(task.taskReminders, isEmpty);
    expect(task.legacyFollowUpMetadata['taskLevel'], {
      'followUpEnabled': true,
      'followUpDate': legacyTaskDate.toIso8601String(),
    });
    expect(task.legacyFollowUpMetadata['followUps'], [
      {
        'id': 'legacy-follow-up-record',
        'nextFollowUp': legacyNextDate.toIso8601String(),
      },
    ]);
    final reopened = Task.fromJson(task.toJson());
    expect(reopened.taskReminders, isEmpty);
    expect(reopened.legacyFollowUpMetadata, task.legacyFollowUpMetadata);
  });

  test('enabling follow-up keeps the same item and exposes follow-up state', () {
    final task = Task(
      id: '1',
      title: 'کار',
      followUpEnabled: true,
    );

    expect(task.isSimpleNote, isFalse);
    expect(task.id, '1');
  });

  test('new unified fields survive serialization without breaking legacy fields', () {
    final created = DateTime(2026, 8, 14, 10, 30);
    final reminder = DateTime(2026, 8, 15, 9);
    final task = Task(
      id: '1',
      title: 'کار',
      description: 'توضیح',
      createdAt: created,
      category: 'پیگیری مشتری',
      followUpEnabled: true,
      checklist: const ['تماس', 'ثبت نتیجه'],
      taskReminders: [TaskReminder(id: 'roundtrip-reminder', title: 'یادآوری', date: reminder, sequence: 1)],
      followUps: [
        FollowUp(id: 'f1', dateTime: created, note: 'تماس انجام شد'),
      ],
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.id, '1');
    expect(restored.createdAt, created);
    expect(restored.category, 'پیگیری مشتری');
    expect(restored.followUpEnabled, isTrue);
    expect(restored.checklist, ['تماس', 'ثبت نتیجه']);
    expect(restored.reminderDate, reminder);
    expect(restored.followUps.single.note, 'تماس انجام شد');
  });

  test('legacy Task follow-up schedule survives as non-scheduling metadata', () {
    const legacyDate = '2026-08-13T12:00:00.000';
    final task = Task.fromLegacyJson({
      'id': 'legacy',
      'title': 'قدیمی',
      'followUpEnabled': true,
      'followUpDate': legacyDate,
    });

    expect(task.taskReminders, isEmpty);
    expect(task.legacyFollowUpMetadata['taskLevel'], {
      'followUpEnabled': true,
      'followUpDate': legacyDate,
    });

    final reopened = Task.fromJson(task.toJson());
    expect(reopened.legacyFollowUpMetadata, task.legacyFollowUpMetadata);
    expect(reopened.taskReminders, isEmpty);
  });

  test('disabled legacy Task follow-up metadata is also retained without scheduling', () {
    const legacyDate = '2026-08-14T09:00:00.000';
    final task = Task.fromLegacyJson({
      'id': 'legacy-disabled',
      'title': 'پیگیری غیرفعال',
      'followUpEnabled': false,
      'followUpDate': legacyDate,
    });

    expect(task.taskReminders, isEmpty);
    expect(task.legacyFollowUpMetadata['taskLevel'], {
      'followUpEnabled': false,
      'followUpDate': legacyDate,
    });
  });

  test('legacy Follow-up nextFollowUp alone does not seed a Reminder', () {
    final task = Task.fromLegacyJson({
      'id': 'legacy-follow-up',
      'title': 'پیگیری مشتری',
      'followUps': [
        {
          'id': 'follow-up-1',
          'dateTime': '2026-08-13T12:00:00.000',
          'nextFollowUp': '2026-08-15T10:30:00.000',
        },
      ],
    });

    expect(task.followUps, hasLength(1));
    expect(task.followUps.single.nextFollowUp, isNull);
    expect(task.taskReminders, isEmpty);
    expect(task.legacyFollowUpMetadata['followUps'], [
      {
        'id': 'follow-up-1',
        'nextFollowUp': '2026-08-15T10:30:00.000',
      },
    ]);
    final reopened = Task.fromJson(task.toJson());
    expect(reopened.legacyFollowUpMetadata, task.legacyFollowUpMetadata);
  });

  test('missing category remains backward-compatible with legacy data', () {
    final task = Task.fromJson({
      'id': 'legacy',
      'title': 'قدیمی',
    });

    expect(task.category, isNull);
    expect(task.toJson()['category'], isNull);
  });


  test('legacy presence preserves Missing, NULL, FALSE and TRUE independently', () {
    final missing = Task.fromLegacyJson({
      'id': 'presence-missing',
      'title': 'بدون فیلد',
    });
    expect(missing.legacyFollowUpMetadata['taskLevel'], isNull);

    final explicitNull = Task.fromLegacyJson({
      'id': 'presence-null',
      'title': 'مقدار تهی',
      'reminderDate': null,
      'followUpDate': null,
      'followUpEnabled': null,
      'followUps': [
        {
          'id': 'follow-null',
          'dateTime': '2026-11-11T08:00:00.000',
          'nextFollowUp': null,
        },
      ],
    });
    final nullTaskLevel =
        explicitNull.legacyFollowUpMetadata['taskLevel'] as Map;
    for (final field in const ['reminderDate', 'followUpDate', 'followUpEnabled']) {
      expect(nullTaskLevel.containsKey(field), isTrue);
      expect(nullTaskLevel[field], isNull);
    }
    expect(
      (explicitNull.legacyFollowUpMetadata['followUps'] as List).single,
      containsPair('nextFollowUp', null),
    );

    final explicitFalse = Task.fromLegacyJson({
      'id': 'presence-false',
      'title': 'غیرفعال',
      'followUpEnabled': false,
    });
    final falseLevel =
        explicitFalse.legacyFollowUpMetadata['taskLevel'] as Map;
    expect(falseLevel.containsKey('followUpEnabled'), isTrue);
    expect(falseLevel['followUpEnabled'], isFalse);

    final explicitTrue = Task.fromLegacyJson({
      'id': 'presence-true',
      'title': 'فعال',
      'followUpEnabled': true,
    });
    final trueLevel =
        explicitTrue.legacyFollowUpMetadata['taskLevel'] as Map;
    expect(trueLevel.containsKey('followUpEnabled'), isTrue);
    expect(trueLevel['followUpEnabled'], isTrue);

    for (final task in [explicitNull, explicitFalse, explicitTrue]) {
      final restored = Task.fromJson(task.toJson());
      expect(
        restored.legacyFollowUpMetadata,
        task.legacyFollowUpMetadata,
      );
    }
  });

  test('unknown legacy Task and Follow-up fields survive serialization', () {
    final task = Task.fromLegacyJson({
      'id': 'unknown-legacy',
      'title': 'فیلد ناشناخته',
      'futureTaskFlag': {'enabled': false, 'note': null},
      'followUps': [
        {
          'id': 'future-follow-up',
          'dateTime': '2026-11-11T09:00:00.000',
          'nextFollowUp': null,
          'futureFollowUpPayload': ['a', 'b'],
        },
      ],
    });

    final restored = Task.fromJson(task.toJson());
    expect(
      (restored.legacyFollowUpMetadata['unknownFields'] as Map)
          ['futureTaskFlag'],
      {'enabled': false, 'note': null},
    );
    expect(
      (restored.legacyFollowUpMetadata['followUps'] as List).single
          ['futureFollowUpPayload'],
      ['a', 'b'],
    );
    expect(restored.legacyFollowUpMetadata, task.legacyFollowUpMetadata);
  });


  test('D01: legacy followUpEnabled presence matrix survives serialization', () {
    const validDate = '2026-11-12T10:30:00.000';
    final scenarios = <({
      String name,
      Map<String, dynamic> fields,
      Map<String, dynamic> expected,
    })>[
      (name: 'A Missing', fields: {}, expected: {}),
      (name: 'B Explicit NULL', fields: {'followUpEnabled': null}, expected: {'followUpEnabled': null}),
      (name: 'C FALSE without date', fields: {'followUpEnabled': false}, expected: {'followUpEnabled': false}),
      (name: 'D FALSE with date NULL', fields: {'followUpEnabled': false, 'followUpDate': null}, expected: {'followUpEnabled': false, 'followUpDate': null}),
      (name: 'E TRUE without date', fields: {'followUpEnabled': true}, expected: {'followUpEnabled': true}),
      (name: 'F TRUE with valid date', fields: {'followUpEnabled': true, 'followUpDate': validDate}, expected: {'followUpEnabled': true, 'followUpDate': validDate}),
      (name: 'G NULL with valid date', fields: {'followUpEnabled': null, 'followUpDate': validDate}, expected: {'followUpEnabled': null, 'followUpDate': validDate}),
    ];

    for (final scenario in scenarios) {
      final decoded = Task.fromLegacyJson({
        'id': 'd01-${scenario.name}',
        'title': scenario.name,
        ...scenario.fields,
      });
      final encoded = decoded.toJson();
      final encodedMetadata = encoded['legacyFollowUpMetadata'] as Map<String, dynamic>?;
      final encodedTaskLevel = encodedMetadata?['taskLevel'] as Map<String, dynamic>?;
      expect(encodedTaskLevel ?? <String, dynamic>{}, scenario.expected,
          reason: '${scenario.name}: serialized historical presence');

      final restored = Task.fromJson(encoded);
      final restoredTaskLevel = restored.legacyFollowUpMetadata['taskLevel'] as Map<String, dynamic>?;
      expect(restoredTaskLevel ?? <String, dynamic>{}, scenario.expected,
          reason: '${scenario.name}: decoded historical presence');
      expect(restored.followUpEnabled, isFalse,
          reason: '${scenario.name}: computed getter uses actual history');
    }
  });

  test('D01: computed getter is independent from historical metadata', () {
    final historicalTrueWithoutRecords = Task.fromJson({
      'id': 'd01-getter-history-true',
      'title': 'metadata says true',
      'legacyFollowUpMetadata': {'taskLevel': {'followUpEnabled': true}},
    });
    expect(historicalTrueWithoutRecords.followUpEnabled, isFalse);
    expect((historicalTrueWithoutRecords.legacyFollowUpMetadata['taskLevel'] as Map)['followUpEnabled'], isTrue);

    final actualRecordWithHistoricalFalse = Task.fromJson({
      'id': 'd01-getter-history-false',
      'title': 'actual history exists',
      'legacyFollowUpMetadata': {'taskLevel': {'followUpEnabled': false}},
      'followUps': [{
        'id': 'actual-history',
        'completedAt': '2026-11-11T08:00:00.000',
        'note': 'ثبت واقعی',
      }],
    });
    expect(actualRecordWithHistoricalFalse.followUpEnabled, isTrue);
    expect((actualRecordWithHistoricalFalse.legacyFollowUpMetadata['taskLevel'] as Map)['followUpEnabled'], isFalse);
  });

  test('D02: nextFollowUp and nextFollowUpAllDay preserve NULL TRUE and FALSE', () {
    final cases = <Map<String, dynamic>>[
      {'id': 'all-day-true', 'nextFollowUpAllDay': true},
      {'id': 'all-day-false', 'nextFollowUpAllDay': false},
      {'id': 'all-day-null', 'nextFollowUpAllDay': null},
      {'id': 'next-date-null', 'nextFollowUp': null},
    ];
    for (final legacyFields in cases) {
      final followUpFields = Map<String, dynamic>.from(legacyFields)..remove('id');
      final decoded = Task.fromLegacyJson({
        'id': 'd02-${legacyFields['id']}',
        'title': 'D02 presence',
        'followUps': [{
          'id': legacyFields['id'],
          'dateTime': '2026-11-11T09:00:00.000',
          ...followUpFields,
        }],
      });
      final encoded = decoded.toJson();
      final records = (encoded['legacyFollowUpMetadata'] as Map)['followUps'] as List;
      final record = records.single as Map<String, dynamic>;
      for (final key in const ['nextFollowUp', 'nextFollowUpAllDay']) {
        if (legacyFields.containsKey(key)) {
          expect(record.containsKey(key), isTrue, reason: '$key presence');
          expect(record[key], legacyFields[key], reason: '$key value');
        }
      }
      var restored = Task.fromJson(encoded);
      for (var cycle = 0; cycle < 3; cycle++) {
        final nextEncoded = restored.toJson();
        final nextRecords = (nextEncoded['legacyFollowUpMetadata'] as Map)['followUps'] as List;
        expect(nextRecords, hasLength(1));
        expect(nextRecords.single, record);
        restored = Task.fromJson(nextEncoded);
      }
      expect(restored.legacyFollowUpMetadata, decoded.legacyFollowUpMetadata);
    }
  });

  test('D02: existing metadata is preserved and incoming colliding keys win', () {
    final decoded = Task.fromLegacyJson({
      'id': 'd02-collision',
      'title': 'collision',
      'followUpEnabled': false,
      'futureTaskField': {'source': 'incoming', 'value': 2},
      'legacyFollowUpMetadata': {
        'taskLevel': {'followUpEnabled': true, 'olderTaskKey': 'keep-task-level'},
        'unknownFields': {
          'futureTaskField': {'source': 'stored', 'value': 1},
          'olderUnknownField': 'keep-unknown',
        },
        'followUps': [{
          'id': 'same-follow-up',
          'olderFollowUpField': 'keep-follow-up',
          'collisionField': 'stored',
        }],
        'unrelatedEnvelopeKey': {'keep': true},
      },
      'followUps': [{
        'id': 'same-follow-up',
        'dateTime': '2026-11-11T10:00:00.000',
        'collisionField': 'incoming',
        'newFollowUpField': null,
      }],
    });
    final metadata = decoded.legacyFollowUpMetadata;
    expect(metadata['unrelatedEnvelopeKey'], {'keep': true});
    expect(metadata['taskLevel'], {'followUpEnabled': false, 'olderTaskKey': 'keep-task-level'});
    expect(metadata['unknownFields'], {
      'futureTaskField': {'source': 'incoming', 'value': 2},
      'olderUnknownField': 'keep-unknown',
    });
    expect(metadata['followUps'], [{
      'id': 'same-follow-up',
      'olderFollowUpField': 'keep-follow-up',
      'collisionField': 'incoming',
      'newFollowUpField': null,
    }]);
  });

  test('D02: repeated serialization and multiple round trips are idempotent', () {
    final initial = Task.fromLegacyJson({
      'id': 'd02-idempotent',
      'title': 'idempotent',
      'futureTaskField': {'nested': [1, 2, null]},
      'legacyFollowUpMetadata': {
        'unknownFields': {'preExisting': 'preserve'},
        'followUps': [{'id': 'follow-up-1', 'existingPayload': {'flag': true}}],
        'otherMetadata': ['keep', 'once'],
      },
      'followUps': [{
        'id': 'follow-up-1',
        'dateTime': '2026-11-11T11:00:00.000',
        'nextFollowUp': null,
        'nextFollowUpAllDay': false,
        'futureFollowUpPayload': {'nested': null, 'values': [3, 4]},
      }],
    });
    final firstJson = initial.toJson();
    expect(initial.toJson(), firstJson);
    var current = Task.fromJson(firstJson);
    for (var cycle = 1; cycle <= 5; cycle++) {
      final encoded = current.toJson();
      expect(encoded, firstJson, reason: 'encode cycle $cycle');
      current = Task.fromJson(encoded);
      expect(current.legacyFollowUpMetadata, initial.legacyFollowUpMetadata,
          reason: 'decode cycle $cycle');
      final records = current.legacyFollowUpMetadata['followUps'] as List;
      expect(records, hasLength(1), reason: 'no duplicate metadata records');
    }
  });



  test('D02: unknown Task-level fields survive independent round trips', () {
    final decoded = Task.fromLegacyJson({
      'id': 'd02-unknown-task-only',
      'title': 'unknown task field',
      'futureTaskOnly': {'enabled': false, 'nullable': null},
    });
    final unknown =
        decoded.legacyFollowUpMetadata['unknownFields'] as Map<String, dynamic>;
    expect(unknown, {'futureTaskOnly': {'enabled': false, 'nullable': null}});

    final restored = Task.fromJson(decoded.toJson());
    expect(
      restored.legacyFollowUpMetadata['unknownFields'],
      {'futureTaskOnly': {'enabled': false, 'nullable': null}},
    );
  });

  test('D02: unknown Follow-up fields survive independent round trips', () {
    final decoded = Task.fromLegacyJson({
      'id': 'd02-unknown-follow-up-only',
      'title': 'unknown Follow-up field',
      'followUps': [{
        'id': 'unknown-follow-up-only',
        'dateTime': '2026-11-11T12:00:00.000',
        'futureFollowUpOnly': {'value': null, 'items': ['x', 'y']},
      }],
    });
    expect(decoded.legacyFollowUpMetadata['followUps'], [{
      'id': 'unknown-follow-up-only',
      'futureFollowUpOnly': {'value': null, 'items': ['x', 'y']},
    }]);

    final restored = Task.fromJson(decoded.toJson());
    expect(restored.legacyFollowUpMetadata['followUps'], [{
      'id': 'unknown-follow-up-only',
      'futureFollowUpOnly': {'value': null, 'items': ['x', 'y']},
    }]);
  });

}
