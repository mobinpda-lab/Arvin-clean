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

  CanonicalNotebookRepository repositoryAt(DateTime now) {
    return CanonicalNotebookRepository(
      store: TaskStore(),
      now: () => now,
    );
  }

  Future<void> pumpNotebook(
    WidgetTester tester,
    CanonicalNotebookRepository repository,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: NotebookPage(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('create chooser cancels without creating a note', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 6));
    await pumpNotebook(tester, repository);

    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();

    expect(find.text('یادداشت ساده'), findsOneWidget);
    expect(find.text('چک‌لیست'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('notebook-create-cancel')));
    await tester.pumpAndSettle();

    expect(await repository.loadNotes(), isEmpty);
    expect(find.text('هنوز یادداشتی ثبت نشده است'), findsOneWidget);
  });

  testWidgets('simple-note mode preserves the current notebook creation path',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 7));
    await pumpNotebook(tester, repository);

    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-create-note')));
    await tester.pumpAndSettle();

    final title = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-title')),
    );
    expect(title.controller?.text, 'یادداشت جدید');

    final notes = await repository.loadNotes();
    expect(notes, hasLength(1));
    expect(notes.single.title, 'یادداشت جدید');
    expect(notes.single.checklist, isEmpty);
  });

  testWidgets('checklist mode opens directly at checklist input and persists items',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 8));
    await pumpNotebook(tester, repository);

    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-create-checklist')));
    await tester.pumpAndSettle();

    final title = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-title')),
    );
    expect(title.controller?.text, 'چک‌لیست جدید');

    final checklistInput = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-checklist-input')),
    );
    expect(checklistInput.focusNode?.hasFocus, isTrue);

    await tester.enterText(
      find.byKey(const ValueKey('notebook-checklist-input')),
      'شیر',
    );
    await tester.tap(find.byKey(const ValueKey('notebook-checklist-add')));
    await tester.pump(const Duration(milliseconds: 500));

    final notes = await repository.loadNotes();
    expect(notes, hasLength(1));
    expect(notes.single.title, 'چک‌لیست جدید');
    expect(notes.single.checklist, ['[ ] شیر']);
  });

  testWidgets('existing note opens read-only then autosaves edits and checklist',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 26, 10));
    final note = await repository.createNote(id: 'ui-note');
    await repository.updateNote(
      id: note.id,
      title: 'یادداشت اولیه',
      description: 'متن اولیه',
      checklist: const [],
    );

    await pumpNotebook(tester, repository);

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
