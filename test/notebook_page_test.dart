import 'package:arvin/notebook_page.dart';
import 'package:arvin/services/canonical_notebook_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('existing note opens read-only then autosaves edits and checklist',
      (tester) async {
    final repository = CanonicalNotebookRepository(
      store: TaskStore(),
      now: () => DateTime.utc(2026, 8, 26, 10),
    );
    final note = await repository.createNote(id: 'ui-note');
    await repository.updateNote(
      id: note.id,
      title: 'یادداشت اولیه',
      description: 'متن اولیه',
      checklist: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: NotebookPage(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('notebook-note-ui-note')));
    await tester.pumpAndSettle();

    final initialTitle = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-title')),
    );
    expect(initialTitle.readOnly, isTrue);

    await tester.tap(find.byKey(const ValueKey('notebook-edit')));
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('notebook-title')),
      'یادداشت ویرایش‌شده',
    );
    await tester.enterText(
      find.byKey(const ValueKey('notebook-description')),
      'متن ذخیره‌شده خودکار',
    );
    await tester.enterText(
      find.byKey(const ValueKey('notebook-checklist-input')),
      'ارسال گزارش',
    );
    await tester.tap(find.byKey(const ValueKey('notebook-checklist-add')));
    await tester.pump(const Duration(milliseconds: 500));

    final persisted = await repository.loadNote('ui-note');
    expect(persisted?.title, 'یادداشت ویرایش‌شده');
    expect(persisted?.description, 'متن ذخیره‌شده خودکار');
    expect(persisted?.checklist, ['[ ] ارسال گزارش']);

    await tester.tap(find.byKey(const ValueKey('notebook-check-0')));
    await tester.pump(const Duration(milliseconds: 500));
    expect((await repository.loadNote('ui-note'))?.checklist, ['[x] ارسال گزارش']);

    await tester.tap(find.byKey(const ValueKey('notebook-done')));
    await tester.pumpAndSettle();
    final readOnlyAgain = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-title')),
    );
    expect(readOnlyAgain.readOnly, isTrue);
  });
}
