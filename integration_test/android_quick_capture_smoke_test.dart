import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android Quick Capture cancel is zero-write and submit persists canonical Task',
      (tester) async {
    final seedFollowUp = FollowUp(
      id: 'seed-followup',
      dateTime: DateTime(2026, 9, 7, 10, 30),
      note: 'سابقه پیگیری',
    );
    final seed = Task(
      id: 'seed-task',
      title: 'پرونده موجود',
      createdAt: DateTime(2026, 9, 1, 8),
      followUpEnabled: true,
      followUps: <FollowUp>[seedFollowUp],
      tags: <String>['قدیمی'],
    );
    final store = TaskStore();
    await store.save(<Task>[seed]);

    app.main();
    await tester.pumpAndSettle();

    final skipGuide = find.text('رد کردن');
    if (skipGuide.evaluate().isNotEmpty) {
      await tester.tap(skipGuide);
      await tester.pumpAndSettle();
    }

    Future<void> waitForFinder(Finder finder, {int attempts = 100}) async {
      for (var attempt = 0; attempt < attempts; attempt++) {
        if (finder.evaluate().isNotEmpty) return;
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> openQuickCapture() async {
      final homeMenu = find.byKey(const ValueKey('home-menu'));
      await tester.ensureVisible(homeMenu);
      await tester.tap(homeMenu);
      await tester.pumpAndSettle();

      final quick = find.byKey(const ValueKey('home-more-quick-capture'));
      await waitForFinder(quick);
      expect(quick, findsOneWidget);
      await tester.ensureVisible(quick);
      await tester.tap(quick);

      final dialog = find.byKey(const ValueKey('quick-capture-dialog'));
      await waitForFinder(dialog);
      expect(dialog, findsOneWidget);
      await tester.pumpAndSettle();
    }

    await openQuickCapture();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'این مورد نباید ذخیره شود #لغو',
    );
    final cancel = find.byKey(const ValueKey('quick-capture-cancel'));
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();

    final afterCancel = await TaskStore().load();
    expect(afterCancel, hasLength(1));
    expect(afterCancel.single.id, seed.id);
    expect(afterCancel.single.followUps, hasLength(1));
    expect(afterCancel.single.followUps.single.id, seedFollowUp.id);

    await openQuickCapture();
    await tester.enterText(
      find.byKey(const ValueKey('quick-capture-input')),
      'تماس با علی #مشتری #فوری',
    );
    final submit = find.byKey(const ValueKey('quick-capture-submit'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final persisted = await TaskStore().load();
    expect(persisted, hasLength(2));
    final original = persisted.singleWhere((task) => task.id == seed.id);
    final captured = persisted.singleWhere((task) => task.id != seed.id);
    expect(original.followUps, hasLength(1));
    expect(original.followUps.single.note, 'سابقه پیگیری');
    expect(captured.title, 'تماس با علی');
    expect(captured.tags, containsAll(<String>['مشتری', 'فوری']));
    expect(captured.createdAt, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    app.main();
    await tester.pumpAndSettle();

    final skipGuideAfterReload = find.text('رد کردن');
    if (skipGuideAfterReload.evaluate().isNotEmpty) {
      await tester.tap(skipGuideAfterReload);
      await tester.pumpAndSettle();
    }
    final reloaded = await TaskStore().load();
    expect(reloaded.any((task) => task.title == 'تماس با علی'), isTrue);
    expect(reloaded.any((task) => task.title == 'پرونده موجود'), isTrue);
  });
}
