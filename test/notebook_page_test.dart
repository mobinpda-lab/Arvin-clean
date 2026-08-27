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

  Future<void> openChecklistPreset(
    WidgetTester tester,
    String presetId,
  ) async {
    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-create-checklist')));
    await tester.pumpAndSettle();
    final preset = find.byKey(ValueKey('notebook-preset-$presetId'));
    await tester.ensureVisible(preset);
    await tester.tap(preset);
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

  testWidgets('checklist preset chooser cancels without creating a note',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 6, 30));
    await pumpNotebook(tester, repository);

    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-create-checklist')));
    await tester.pumpAndSettle();

    expect(find.text('لیست خرید'), findsOneWidget);
    expect(find.text('وسایل سفر'), findsOneWidget);
    expect(find.text('کارهای امروز'), findsOneWidget);
    expect(find.text('چک‌لیست جدید'), findsOneWidget);

    final cancel = find.byKey(const ValueKey('notebook-preset-cancel'));
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();

    expect(await repository.loadNotes(), isEmpty);
  });

  testWidgets('simple-note editor stays text focused and hides checklist controls',
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
    expect(find.byKey(const ValueKey('notebook-category-picker')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-checklist-input')), findsNothing);
    expect(find.text('چک‌لیست'), findsNothing);

    final notes = await repository.loadNotes();
    expect(notes, hasLength(1));
    expect(notes.single.checklist, isEmpty);
  });

  testWidgets('shopping preset persists editable starter items', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 8));
    await pumpNotebook(tester, repository);

    await openChecklistPreset(tester, 'shopping');

    final title = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-title')),
    );
    expect(title.controller?.text, 'لیست خرید');
    expect(find.text('نان'), findsOneWidget);
    expect(find.text('شیر'), findsOneWidget);
    expect(find.text('میوه'), findsOneWidget);

    var persisted = (await repository.loadNotes()).single;
    expect(persisted.checklist, ['[ ] نان', '[ ] شیر', '[ ] میوه']);

    await tester.tap(find.byKey(const ValueKey('notebook-check-menu-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ویرایش مورد').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('notebook-checklist-edit-input')),
      'نان سنگک',
    );
    await tester.tap(
      find.byKey(const ValueKey('notebook-checklist-edit-save')),
    );
    await tester.pump(const Duration(milliseconds: 500));

    persisted = (await repository.loadNotes()).single;
    expect(persisted.checklist.first, '[ ] نان سنگک');

    await tester.tap(find.byKey(const ValueKey('notebook-check-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف مورد').last);
    await tester.pump(const Duration(milliseconds: 500));

    persisted = (await repository.loadNotes()).single;
    expect(persisted.checklist, ['[ ] نان سنگک', '[ ] میوه']);
  });

  testWidgets('travel preset uses canonical starter checklist', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 9));
    await pumpNotebook(tester, repository);

    await openChecklistPreset(tester, 'travel');

    final persisted = (await repository.loadNotes()).single;
    expect(persisted.title, 'وسایل سفر');
    expect(persisted.checklist, ['[ ] مدارک', '[ ] شارژر', '[ ] لباس']);
  });

  testWidgets('today preset starts empty and focuses checklist entry',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 10));
    await pumpNotebook(tester, repository);

    await openChecklistPreset(tester, 'today');

    final input = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-checklist-input')),
    );
    expect(input.focusNode?.hasFocus, isTrue);

    final persisted = (await repository.loadNotes()).single;
    expect(persisted.title, 'کارهای امروز');
    expect(persisted.checklist, isEmpty);
  });

  testWidgets('blank preset remains available and persists normal additions',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 11));
    await pumpNotebook(tester, repository);

    await openChecklistPreset(tester, 'blank');

    final checklistInput = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-checklist-input')),
    );
    expect(checklistInput.focusNode?.hasFocus, isTrue);

    await tester.enterText(
      find.byKey(const ValueKey('notebook-checklist-input')),
      'ارسال گزارش',
    );
    await tester.tap(find.byKey(const ValueKey('notebook-checklist-add')));
    await tester.pump(const Duration(milliseconds: 500));

    final persisted = (await repository.loadNotes()).single;
    expect(persisted.checklist, ['[ ] ارسال گزارش']);
  });

  testWidgets('existing simple note has explicit edit button and no checklist block',
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

    expect(find.text('ویرایش'), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-checklist-input')), findsNothing);

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
    await tester.pump(const Duration(milliseconds: 500));

    final persisted = await repository.loadNote('ui-note');
    expect(persisted?.title, 'یادداشت ویرایش‌شده');
    expect(persisted?.description, 'متن ذخیره‌شده خودکار');
    expect(persisted?.checklist, isEmpty);
  });

  testWidgets('category selection immediately moves the same canonical note',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 28, 0));
    final first = await repository.createNote(
      id: 'first',
      title: 'یادداشت اول',
      category: 'اداری',
    );
    final target = await repository.createNote(id: 'target', title: 'یادداشت دوم');
    expect(first.category, 'اداری');
    expect(target.category, isNull);

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-target')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('notebook-category-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-category-اداری')));
    await tester.pumpAndSettle();

    expect(find.text('دسته: اداری'), findsOneWidget);
    final persisted = await repository.loadNote('target');
    expect(persisted?.id, 'target');
    expect(persisted?.category, 'اداری');
    expect(await repository.loadNotes(), hasLength(2));
  });

  testWidgets('new category is created and applied without an extra save step',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 28, 1));
    await repository.createNote(id: 'category-note', title: 'دسته‌بندی');

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-category-note')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('notebook-category-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-category-new')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('notebook-category-new-input')),
      'شخصی',
    );
    await tester.tap(find.byKey(const ValueKey('notebook-category-new-save')));
    await tester.pumpAndSettle();

    expect((await repository.loadNote('category-note'))?.category, 'شخصی');
    expect(find.text('دسته: شخصی'), findsOneWidget);
  });
}
