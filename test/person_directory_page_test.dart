import 'package:arvin/models/person_reference.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/person_directory_page.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await TaskStore.resetTestDatabase();
  });

  tearDown(() async {
    await TaskStore.resetTestDatabase();
  });

  testWidgets('duplicate names warn without merging', (tester) async {
    final store = TaskStore();
    final person = PersonReference(id: 'person-stable-1', displayName: 'علی رضایی');
    await store.savePeopleDirectory([person]);
    await store.save([
      Task(
        id: 'task-person-history',
        title: 'تماس با علی',
        people: [person],
        followUps: [
          FollowUp(
            id: 'follow-up-person-history',
            dateTime: DateTime(2026, 11, 18, 9),
            personIds: [person.id],
          ),
        ],
      ),
    ]);

    await tester.pumpWidget(MaterialApp(home: PersonDirectoryPage(store: store)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('افزودن شخص'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'علي رضایی');
    await tester.tap(find.widgetWithText(FilledButton, 'ذخیره'));
    await tester.pumpAndSettle();

    expect(find.text('نام مشابه وجود دارد'), findsOneWidget);
    await tester.tap(find.text('ثبت شخص جداگانه'));
    await tester.pumpAndSettle();

    final directory = await store.loadPeopleDirectory();
    expect(directory, hasLength(2));
    expect(directory.map((value) => value.id).toSet().length, 2);
    final after = await store.load();
    expect(after.single.people.single.id, person.id);
    expect(after.single.followUps.single.personIds, [person.id]);
  });
  testWidgets('removing a referenced Person from directory preserves Task and Follow-up history',
      (tester) async {
    final store = TaskStore();
    final person = PersonReference(id: 'person-history-retained', displayName: 'شخص تاریخی');
    await store.savePeopleDirectory([person]);
    await store.save([
      Task(
        id: 'task-person-history-retained',
        title: 'کار با شخص',
        people: [person],
        followUps: [
          FollowUp(
            id: 'follow-up-person-history-retained',
            dateTime: DateTime(2026, 11, 18, 9),
            personIds: [person.id],
          ),
        ],
      ),
    ]);

    await tester.pumpWidget(MaterialApp(home: PersonDirectoryPage(store: store)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('حذف'));
    await tester.pumpAndSettle();
    expect(find.text('«شخص تاریخی» در سوابق کار یا پیگیری استفاده شده است. حذف فقط این شخص را از دفترچه اشخاص خارج می‌کند؛ شناسه و ارتباط‌های تاریخی Task و Follow-up حفظ می‌شوند.'), findsOneWidget);
    await tester.tap(find.text('حذف از دفترچه'));
    await tester.pumpAndSettle();

    expect(await store.loadPeopleDirectory(), isEmpty);
    final restored = await store.load();
    expect(restored.single.people.single.id, person.id);
    expect(restored.single.people.single.displayName, person.displayName);
    expect(restored.single.followUps.single.personIds, [person.id]);
  });

  test('renaming a Person keeps the stable ID and updates historical Task labels', () async {
    final store = TaskStore();
    final original = PersonReference(id: 'person-rename-stable', displayName: 'نام قبلی');
    await store.savePeopleDirectory([original]);
    await store.save([
      Task(
        id: 'task-person-rename',
        title: 'کار مرتبط',
        people: [original],
      ),
    ]);

    await store.savePeopleDirectory([
      PersonReference(id: original.id, displayName: 'نام جدید'),
    ]);

    final reloaded = await store.load();
    expect(reloaded.single.people.single.id, original.id);
    expect(reloaded.single.people.single.displayName, 'نام جدید');
    expect((await store.loadPeopleDirectory()).single.id, original.id);
  });

}
