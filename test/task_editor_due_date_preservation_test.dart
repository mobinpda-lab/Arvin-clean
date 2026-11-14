import 'package:arvin/models/task.dart';
import 'package:arvin/task_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('editing preserves canonical due date independently', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Task? result;
    final task = Task.fromLegacyJson(<String, dynamic>{
      'id': 'due-safe',
      'title': 'تحویل قرارداد',
      'dueDate': DateTime(2026, 9, 11, 14, 45).toIso8601String(),
      'reminderDate': DateTime(2026, 9, 10, 9, 30).toIso8601String(),
      'reminderAllDay': false,
      'legacyCustomFlag': <String, dynamic>{'source': 'legacy-import-v1', 'enabled': false},
      'followUpEnabled': true,
      'followUpDate': DateTime(2026, 9, 12, 11).toIso8601String(),
      'tags': <String>['قرارداد'],
      'checklist': <String>['[ ] بند اول'],
      'checklistEnabled': true,
      'checklistOccurrences': <String, dynamic>{
        '2026-09-11T14:45:00.000': <String>['[x] بند اول'],
      },
      'occurrenceHistory': <String, dynamic>{
        '2026-09-11T14:45:00.000': <String, dynamic>{
          'completed': true,
          'note': 'سابقه باید محفوظ بماند',
        },
      },
      'notebookKind': 'checklist',
      'isFavorite': true,
      'focusDate': DateTime(2026, 9, 9).toIso8601String(),
      'templateTaskId': 'template-preserve-1',
      'completed': true,
      'completedAt': DateTime(2026, 9, 8, 12).toIso8601String(),
      'priority': 'high',
      'followUps': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'f1',
          'dateTime': DateTime(2026, 9, 8, 10).toIso8601String(),
          'note': 'تماس اولیه',
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<Task>(
                    context: context,
                    builder: (_) => ArvinTaskEditorDialog(task: task),
                  );
                },
                child: const Text('باز کردن'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('باز کردن'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-header-save')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'due-safe');
    expect(result!.dueDate, DateTime(2026, 9, 11, 14, 45));
    expect(result!.reminderDate, DateTime(2026, 9, 10, 9, 30));
    expect(result!.taskReminders, hasLength(1));
    final reminder = result!.taskReminders.single;
    expect(reminder.id, migratedTaskReminderId('due-safe'));
    expect(isMigratedTaskReminder(result!, reminder), isTrue);
    expect(reminder.title, 'یادآوری: تحویل قرارداد');
    expect(reminder.date, DateTime(2026, 9, 10, 9, 30));
    expect(reminder.isAllDay, isFalse);
    expect(reminder.sequence, 1);
    expect(reminder.isEnabled, isTrue);
    expect(reminder.toJson(), <String, dynamic>{
      'id': migratedTaskReminderId('due-safe'),
      'title': 'یادآوری: تحویل قرارداد',
      'date': DateTime(2026, 9, 10, 9, 30).toIso8601String(),
      'isAllDay': false,
      'sequence': 1,
    });
    expect(result!.legacyTaskReminderMigrationVersion, 1);

    final legacyTaskLevel =
        result!.legacyFollowUpMetadata['taskLevel'] as Map<String, dynamic>;
    expect(legacyTaskLevel['followUpDate'],
        DateTime(2026, 9, 12, 11).toIso8601String());
    expect(legacyTaskLevel['followUpEnabled'], isTrue);
    expect(legacyTaskLevel['reminderAllDay'], isFalse);
    final unknownFields = result!.legacyFollowUpMetadata['unknownFields'] as Map<String, dynamic>;
    expect(unknownFields['legacyCustomFlag'], <String, dynamic>{'source': 'legacy-import-v1', 'enabled': false});

    expect(result!.followUps, hasLength(1));
    expect(result!.followUps.single.dateTime, DateTime(2026, 9, 8, 10));
    expect(result!.followUps.single.note, 'تماس اولیه');
    expect(result!.checklistOccurrences, {
      '2026-09-11T14:45:00.000': <String>['[x] بند اول'],
    });
    expect(result!.occurrenceHistory['2026-09-11T14:45:00.000']?['completed'], true);
    expect(result!.notebookKind, NotebookItemKind.checklist);
    expect(result!.isFavorite, isTrue);
    expect(result!.focusDate, DateTime(2026, 9, 9));
    expect(result!.templateTaskId, 'template-preserve-1');
    expect(result!.completed, isTrue);
    expect(result!.completedAt, DateTime(2026, 9, 8, 12));
    expect(result!.priority, TaskPriority.high);
  });
}
