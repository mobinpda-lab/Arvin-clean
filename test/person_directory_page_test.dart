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

  testWidgets(
    'Person directory supports create, normalized search, edit, and safe delete',
    (tester) async {
      final store = TaskStore();
      final person = PersonReference(id: 'person-ali', displayName: 'علی رضایی');
      await store.savePersonDirectoryEntry(person);
      await store.save(<Task>[
        Task(
          id: 'task-call-ali',
          title: 'تماس با علی',
          followUps: <FollowUp>[
            FollowUp(
              id: 'follow-up-call-ali',
              dateTime: DateTime(2026, 10, 14, 9),
              waitingForResponse: true,
              personIds: <String>[person.id],
            ),
          ],
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(home: PersonDirectoryPage(store: store)),
      );
      await tester.pumpAndSettle();

      expect(find.text('علی رضایی'), findsOneWidget);

      // Arabic Yeh in the query must match the Persian Yeh in the stored name.
      await tester.enterText(find.byType(TextField).first, 'علي');
      await tester.pumpAndSettle();
      expect(find.text('علی رضایی'), findsOneWidget);

      await tester.tap(find.byTooltip('ویرایش'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'علی محمدی');
      await tester.tap(find.widgetWithText(FilledButton, 'ذخیره'));
      await tester.pumpAndSettle();
      expect(find.text('علی محمدی'), findsOneWidget);
      expect(find.text('علی رضایی'), findsNothing);

      // Deleting a Person removes only the relation and directory record.
      await tester.tap(find.byTooltip('حذف'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('حذف شخص'),
        ).first,
        findsOneWidget,
      );
      expect(find.textContaining('خود کارها و پیگیری‌ها حذف نمی‌شوند'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'حذف شخص'));
      await tester.pumpAndSettle();

      expect(find.text('هنوز شخصی ثبت نشده است.'), findsOneWidget);
      final remainingTasks = await store.load();
      expect(remainingTasks, hasLength(1));
      expect(remainingTasks.single.id, 'task-call-ali');
      expect(remainingTasks.single.followUps, hasLength(1));
      expect(remainingTasks.single.followUps.single.id, 'follow-up-call-ali');
      expect(remainingTasks.single.followUps.single.personIds, isEmpty);
      expect(await store.loadPeopleDirectory(), isEmpty);
    },
  );
}
