import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/persian_date_formatter.dart';
import 'package:arvin/widgets/occurrence_checklist_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TaskStore.resetTestDatabase();
  });

  testWidgets('shared occurrence editor isolates, saves, and reloads one occurrence',
      (tester) async {
    final store = TaskStore();
    final first = DateTime(2026, 10, 8, 9);
    final second = DateTime(2026, 10, 9, 9);
    await store.save([
      Task(
        id: 'occurrence-editor-test',
        title: 'آماده‌سازی مدرسه',
        reminderDate: first,
        checklist: const ['[ ] کیف', '[ ] تکالیف', '[ ] بطری آب'],
        recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      ),
    ]);
    final repository = TaskRecurrenceRepository(
      store: store,
      now: () => DateTime(2026, 10, 8, 8),
    );

    Future<void> mountEditor() async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OccurrenceChecklistEditor(
            task: (await store.load()).single,
            repository: repository,
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    Future<void> choose(DateTime date) async {
      await tester.tap(find.byKey(
        const ValueKey('occurrence-checklist-picker-occurrence-editor-test'),
      ));
      await tester.pumpAndSettle();
      final label = const PersianDateFormatter().format(date, usePersianDate: true);
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    await mountEditor();
    await choose(first);
    final firstKey =
        'occurrence-checklist-item-occurrence-editor-test-${first.toIso8601String()}-0';
    await tester.tap(find.byKey(ValueKey(firstKey)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('occurrence-checklist-save')));
    await tester.pumpAndSettle();

    var saved = (await store.load()).single;
    expect(saved.checklist, const ['[ ] کیف', '[ ] تکالیف', '[ ] بطری آب']);
    expect(saved.checklistOccurrences[first.toIso8601String()]?.first, '[x] کیف');

    await choose(second);
    expect(
      find.byKey(ValueKey(
        'occurrence-checklist-item-occurrence-editor-test-${second.toIso8601String()}-0',
      )),
      findsOneWidget,
    );
    expect(saved.checklistOccurrences[second.toIso8601String()], isNull);
    await tester.tap(find.byKey(const ValueKey('occurrence-checklist-save')));
    await tester.pumpAndSettle();

    saved = (await store.load()).single;
    expect(saved.checklistOccurrences[first.toIso8601String()]?.first, '[x] کیف');
    expect(saved.checklistOccurrences[second.toIso8601String()]?.first, '[ ] کیف');
    expect(saved.checklistOccurrences.length, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await mountEditor();
    await choose(first);
    expect(
      tester.widget<CheckboxListTile>(find.byKey(ValueKey(firstKey))).value,
      isTrue,
    );
    expect((await store.load()).single.checklistOccurrences.length, 2);
  });
}
