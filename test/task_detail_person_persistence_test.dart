import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'arvin.tasks': '[]'});
    await TaskStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  testWidgets('Task Details Follow-up person selection persists through canonical Person and relation tables', (tester) async {
    final store = TaskStore();
    final task = Task(id: 'task-detail-person-persistence', title: 'پیگیری مشتری');
    final person = PersonReference(id: 'person-canonical-42', displayName: 'سارا احمدی');
    await store.save([task]);
    await store.mergePeopleDirectory([person]);

    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: task,
        onAddFollowUp: (current, followUp) async {
          await store.addFollowUp(current.id, followUp);
          return (await store.load()).single;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final add = find.byKey(const ValueKey('task-detail-add-followup'));
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('follow-up-entry-waiting-for-response')));
    await tester.pumpAndSettle();
    final personChip = find.byKey(const ValueKey('follow-up-person-person-canonical-42'));
    await tester.ensureVisible(personChip);
    await tester.tap(personChip);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-save')));
    await tester.pumpAndSettle();

    final reloaded = (await store.load()).single;
    final directory = await store.loadPeopleDirectory();
    expect(directory.map((value) => value.id), contains(person.id));
    expect(reloaded.followUps, hasLength(1));
    expect(reloaded.followUps.single.waitingForResponse, isTrue);
    expect(reloaded.followUps.single.personIds, contains(person.id));
  });
}
