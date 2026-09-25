import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/notebook_page.dart';
import 'package:arvin/services/canonical_notebook_repository.dart';
import 'package:arvin/services/project_store.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/services/task_project_assignment_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
  });
  late NativeDatabase database;

  setUp(() {
    database = NativeDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  CanonicalNotebookRepository repositoryAt(DateTime now) {
    return CanonicalNotebookRepository(
      store: TaskStore(executor: database),
      projectAssignmentService: TaskProjectAssignmentService(
        store: ProjectStore(executor: database),
      ),
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

  Future<void> selectChecklistMode(WidgetTester tester) async {
    await tester.tap(find.text('چک‌لیست‌ها'));
    await tester.pumpAndSettle();
  }

  Future<void> openChecklistPreset(
    WidgetTester tester,
    String presetId,
  ) async {
    await selectChecklistMode(tester);
    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();
    final preset = find.byKey(ValueKey('notebook-preset-$presetId'));
    await tester.ensureVisible(preset);
    await tester.tap(preset);
    await tester.pumpAndSettle();
  }

  testWidgets('approved Notebook reference controls are present', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 6));
    await pumpNotebook(tester, repository);

    expect(find.text('دفترچه'), findsOneWidget);
    expect(find.text('یادداشت‌ها و چک‌لیست‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-filter-همه')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-filter-شخصی')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-filter-کاری')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-filter-ایده‌ها')), findsOneWidget);
    expect(find.text('یادداشت‌ها'), findsOneWidget);
    expect(find.text('چک‌لیست‌ها'), findsOneWidget);
  });

  testWidgets('checklist preset chooser cancels without creating a note',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 6, 30));
    await pumpNotebook(tester, repository);

    await selectChecklistMode(tester);
    await tester.tap(find.byKey(const ValueKey('notebook-create')));
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

  testWidgets('selected category becomes default for new note and search filters cards',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 11, 30));
    await pumpNotebook(tester, repository);

    await tester.tap(find.byKey(const ValueKey('notebook-filter-شخصی')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();

    final created = (await repository.loadNotes()).single;
    expect(created.category, 'شخصی');
    expect(created.isNotebookChecklist, isFalse);

    await tester.tap(find.byKey(const ValueKey('notebook-done')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-editor-back')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('notebook-search')),
      'ناموجود',
    );
    await tester.pumpAndSettle();
    expect(find.text('موردی مطابق فیلتر فعلی پیدا نشد'), findsOneWidget);
  });

  testWidgets('empty checklist keeps checklist identity and progress survives persistence',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 11, 45));
    await pumpNotebook(tester, repository);

    await openChecklistPreset(tester, 'blank');
    expect(
      find.byKey(const ValueKey('notebook-checklist-progress')),
      findsOneWidget,
    );
    expect(find.text('چک‌لیست — 0 از 0 انجام شده'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('notebook-checklist-input')),
      'مورد اول',
    );
    await tester.tap(find.byKey(const ValueKey('notebook-checklist-add')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const ValueKey('notebook-check-0')));
    await tester.pump(const Duration(milliseconds: 500));

    final persisted = (await repository.loadNotes()).single;
    expect(persisted.isNotebookChecklist, isTrue);
    expect(persisted.checklist, ['[x] مورد اول']);
    expect(find.text('چک‌لیست — 1 از 1 انجام شده'), findsOneWidget);
  });

  testWidgets('Notebook list renders Jalali date with Persian digits', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 12));
    await repository.createNote(id: 'jalali-list-date', title: 'تاریخ شمسی');

    await pumpNotebook(tester, repository);

    expect(find.textContaining('۱۴۰۵'), findsOneWidget);
    expect(find.textContaining('2026'), findsNothing);
  });

  testWidgets('editor matches content-first reference surface', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 12));
    final note = await repository.createNote(
      id: 'reference-editor',
      title: 'ایده محصول',
      category: 'ایده‌ها',
    );
    await repository.updateNote(
      id: note.id,
      title: 'ایده محصول',
      description: 'متن یادداشت',
      checklist: const [],
    );

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-reference-editor')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notebook-editor-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-category-picker')), findsOneWidget);
    expect(find.text('ایده‌ها'), findsOneWidget);

    final description = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-description')),
    );
    expect(description.maxLines, isNull);
    expect(description.minLines, 12);
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

    expect(find.byKey(const ValueKey('notebook-edit')), findsOneWidget);
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

  testWidgets('project picker assigns and clears the same canonical note',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 18, 12));
    await ProjectStore(executor: database).save([
      ProjectPlan(id: 'project-a', title: 'پروژه آروین'),
      ProjectPlan(id: 'archived', title: 'پروژه بایگانی', isArchived: true),
    ]);
    await repository.createNote(id: 'project-note', title: 'یادداشت پروژه');

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-project-note')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notebook-project-picker')), findsOneWidget);
    expect(find.text('انتخاب پروژه'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('notebook-project-picker')));
    await tester.pumpAndSettle();
    expect(find.text('پروژه آروین'), findsOneWidget);
    expect(find.text('پروژه بایگانی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('notebook-project-project-a')));
    await tester.pumpAndSettle();

    expect(await repository.projectIdForNote('project-note'), 'project-a');
    expect((await repository.loadNote('project-note'))?.id, 'project-note');
    expect(find.text('پروژه آروین'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('notebook-project-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-project-clear')));
    await tester.pumpAndSettle();

    expect(await repository.projectIdForNote('project-note'), isNull);
    expect((await repository.loadNote('project-note'))?.id, 'project-note');
  });

  testWidgets('editor tag picker replaces tags on the same canonical note',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 19, 0));
    await repository.createNote(id: 'tag-note', title: 'یادداشت برچسب');
    await repository.updateTags(id: 'tag-note', tags: const ['قدیمی', 'مهم', 'مشتری']);

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-tag-note')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notebook-tags-picker')), findsOneWidget);
    expect(find.text('#قدیمی #مهم #مشتری'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('notebook-tags-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-tag-قدیمی')));
    await tester.tap(find.byKey(const ValueKey('notebook-tags-save')));
    await tester.pumpAndSettle();

    final persisted = await repository.loadNote('tag-note');
    expect(persisted?.id, 'tag-note');
    expect(persisted?.tags, ['مشتری', 'مهم']);
    expect(find.text('#مشتری #مهم'), findsOneWidget);
    expect(await repository.loadNotes(), hasLength(1));
  });

  testWidgets('editor trash safely moves only the current canonical note', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 28, 0));
    await repository.createNote(id: 'trash-target', title: 'حذف از ویرایشگر');
    await repository.createNote(id: 'trash-keep', title: 'باقی بماند');

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-trash-target')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('notebook-editor-trash')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-editor-trash-confirm')));
    await tester.pumpAndSettle();

    expect((await repository.loadNote('trash-target'))?.trashed, isTrue);
    expect((await repository.loadNote('trash-keep'))?.trashed, isFalse);
    expect((await repository.loadNotes()).map((note) => note.id), ['trash-keep']);
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

    expect(find.text('اداری'), findsOneWidget);
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
    expect(find.text('شخصی'), findsOneWidget);
  });
  testWidgets('long press enables canonical Notebook bulk selection and select-all',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 8, 12));
    await repository.createNote(id: 'bulk-1', title: 'اول');
    await repository.createNote(id: 'bulk-2', title: 'دوم');

    await pumpNotebook(tester, repository);
    await tester.longPress(find.byKey(const ValueKey('notebook-note-bulk-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('task-bulk-selection-bar')), findsOneWidget);
    expect(find.text('1 انتخاب'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('task-bulk-select-all')));
    await tester.pumpAndSettle();

    expect(find.text('2 انتخاب'), findsWidgets);
    expect(find.byKey(const ValueKey('task-bulk-share')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-bulk-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-bulk-tags')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-bulk-trash')), findsOneWidget);
  });

  testWidgets('bulk tag assignment preserves same Notebook ids and unrelated data',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 8, 13));
    await repository.createNote(id: 'bulk-tag-1', title: 'اول');
    await repository.createNote(id: 'bulk-tag-2', title: 'دوم');
    await repository.updateTags(id: 'bulk-tag-1', tags: const ['مهم', 'فوری']);
    await repository.updateTags(id: 'bulk-tag-2', tags: const ['مهم', 'فوری']);

    await pumpNotebook(tester, repository);
    await tester.longPress(find.byKey(const ValueKey('notebook-note-bulk-tag-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-bulk-select-all')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-bulk-tags')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-bulk-tag-فوری')));
    await tester.tap(find.byKey(const ValueKey('notebook-bulk-tags-apply')));
    await tester.pumpAndSettle();

    final first = await repository.loadNote('bulk-tag-1');
    final second = await repository.loadNote('bulk-tag-2');
    expect(first?.id, 'bulk-tag-1');
    expect(second?.id, 'bulk-tag-2');
    expect(first?.tags, <String>['مهم', 'فوری']);
    expect(second?.tags, <String>['مهم', 'فوری']);
    expect(await repository.loadNotes(), hasLength(2));
  });


  testWidgets('bulk category move preserves Notebook identities across reload',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 8, 14));
    await repository.createNote(id: 'bulk-cat-1', title: 'اول', category: 'مشتریان');
    await repository.createNote(id: 'bulk-cat-2', title: 'دوم', category: 'قدیمی');

    await pumpNotebook(tester, repository);
    await tester.longPress(find.byKey(const ValueKey('notebook-note-bulk-cat-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-bulk-select-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-bulk-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-bulk-category-مشتریان')));
    await tester.pumpAndSettle();

    final first = await repository.loadNote('bulk-cat-1');
    final second = await repository.loadNote('bulk-cat-2');
    expect(first?.id, 'bulk-cat-1');
    expect(second?.id, 'bulk-cat-2');
    expect(first?.category, 'مشتریان');
    expect(second?.category, 'مشتریان');
    expect(await repository.loadNotes(), hasLength(2));
  });


  testWidgets('bulk trash affects selected Notebook item only', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 8, 15));
    await repository.createNote(id: 'bulk-trash-1', title: 'اول');
    await repository.createNote(id: 'bulk-trash-2', title: 'دوم');

    await pumpNotebook(tester, repository);
    await tester.longPress(find.byKey(const ValueKey('notebook-note-bulk-trash-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-bulk-trash')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-bulk-trash-confirm')));
    await tester.pumpAndSettle();

    expect(await repository.loadNote('bulk-trash-1'), isNotNull);
    expect((await repository.loadNote('bulk-trash-1'))?.trashed, isTrue);
    expect((await repository.loadNote('bulk-trash-2'))?.trashed, isFalse);
    expect((await repository.loadNotes()).map((note) => note.id), ['bulk-trash-2']);
  });


  testWidgets('bulk report action preserves Notebook selection into export surface',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 8, 16));
    await repository.createNote(id: 'report-1', title: 'گزارش اول');
    await repository.createNote(id: 'report-2', title: 'گزارش دوم');

    await pumpNotebook(tester, repository);
    await tester.longPress(find.byKey(const ValueKey('notebook-note-report-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-bulk-select-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-bulk-share')));
    await tester.pumpAndSettle();

    expect(find.text('گزارش و اشتراک‌گذاری'), findsOneWidget);
    expect(
      tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('report-task-report-1')),
      ).value,
      isTrue,
    );
    expect(
      tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('report-task-report-2')),
      ).value,
      isTrue,
    );
    expect(find.byKey(const ValueKey('report-copy-selected')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-share-selected')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-selected')), findsOneWidget);
  });


  testWidgets('editor back persists pending edits before leaving', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 18, 12));
    final note = await repository.createNote(id: 'safe-back', title: 'عنوان اولیه');

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-safe-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-edit')));
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('notebook-title')),
      'عنوان ذخیره‌شده',
    );
    await tester.enterText(
      find.byKey(const ValueKey('notebook-description')),
      'متن ذخیره‌شده هنگام بازگشت',
    );

    await tester.tap(find.byKey(const ValueKey('notebook-editor-back')));
    await tester.pumpAndSettle();

    final persisted = await repository.loadNote(note.id);
    expect(persisted?.title, 'عنوان ذخیره‌شده');
    expect(persisted?.description, 'متن ذخیره‌شده هنگام بازگشت');
    expect(find.text('دفترچه'), findsOneWidget);
  });


  testWidgets('system back persists pending edits before leaving', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 18, 12, 30));
    final note = await repository.createNote(
      id: 'system-safe-back',
      title: 'عنوان اولیه',
    );

    await pumpNotebook(tester, repository);
    await tester.tap(
      find.byKey(const ValueKey('notebook-note-system-safe-back')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-edit')));
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('notebook-title')),
      'عنوان ذخیره‌شده با برگشت سیستم',
    );
    await tester.enterText(
      find.byKey(const ValueKey('notebook-description')),
      'متن ذخیره‌شده با برگشت سیستم',
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final persisted = await repository.loadNote(note.id);
    expect(persisted?.title, 'عنوان ذخیره‌شده با برگشت سیستم');
    expect(persisted?.description, 'متن ذخیره‌شده با برگشت سیستم');
    expect(find.text('دفترچه'), findsOneWidget);
  });

  testWidgets('empty checklist reopens in checklist mode', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 18, 13));
    await repository.createNote(
      id: 'empty-checklist-reopen',
      title: 'چک‌لیست خالی',
      notebookKind: NotebookItemKind.checklist,
    );

    await pumpNotebook(tester, repository);
    await selectChecklistMode(tester);
    await tester.tap(
      find.byKey(const ValueKey('notebook-note-empty-checklist-reopen')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notebook-checklist-progress')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-description')), findsNothing);
  });

  testWidgets('editor converts note to task on same canonical identity',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 19, 0));
    await repository.createNote(
      id: 'convert-ui',
      title: 'یادداشت قابل تبدیل',
      category: 'کاری',
    );
    await repository.updateTags(
      id: 'convert-ui',
      tags: const ['مهم'],
    );

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-convert-ui')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notebook-convert-to-task')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('notebook-convert-to-task')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-convert-confirm')));
    await tester.pumpAndSettle();

    final convertedNote = await repository.loadNote('convert-ui');
    expect(convertedNote, isNotNull);
    expect(convertedNote?.id, 'convert-ui');
    final converted = convertedNote!;
    expect(converted.title, 'یادداشت قابل تبدیل');
    expect(converted.category, 'کاری');
    expect(converted.tags, const ['مهم']);
    expect(converted.followUpEnabled, isTrue);
    expect(converted.notebookKind, NotebookItemKind.note);
    expect(find.text('دفترچه'), findsOneWidget);
  });


  testWidgets('Notebook trash restores the same canonical note identity',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 19, 1));
    await repository.createNote(
      id: 'restore-note',
      title: 'یادداشت بازیابی',
      category: 'کاری',
    );
    await repository.updateTags(
      id: 'restore-note',
      tags: const ['مهم'],
    );
    await repository.moveSelectedToTrash(const ['restore-note']);

    await pumpNotebook(tester, repository);
    expect(find.text('یادداشت بازیابی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('notebook-trash-view')));
    await tester.pumpAndSettle();
    expect(find.text('یادداشت بازیابی'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('notebook-restore-restore-note')),
    );
    await tester.pumpAndSettle();
    expect(find.text('یادداشت بازیابی'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('notebook-trash-view')));
    await tester.pumpAndSettle();

    final restored = await repository.loadNote('restore-note');
    expect(restored?.id, 'restore-note');
    expect(restored?.trashed, isFalse);
    expect(restored?.category, 'کاری');
    expect(restored?.tags, const ['مهم']);
    expect(find.text('یادداشت بازیابی'), findsOneWidget);
    expect(await repository.loadNotes(), hasLength(1));
  });


}
