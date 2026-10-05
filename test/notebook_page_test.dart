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
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
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

  testWidgets('approved Notebook reference controls are present', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 6));
    await pumpNotebook(tester, repository);

    expect(find.text('دفترچه'), findsWidgets);
    expect(find.text('یادداشت‌ها و چک‌لیست‌ها'), findsNothing);
    expect(find.byKey(const ValueKey('notebook-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-project-filter')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-category-filter')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-tag-filter')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-create')), findsOneWidget);
  });

  testWidgets('simple-note editor exposes inline writing tools',
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
    expect(find.byKey(const ValueKey('notebook-inline-tools')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-inline-number')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-inline-tick')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-inline-checklist')), findsOneWidget);

    final notes = await repository.loadNotes();
    expect(notes, hasLength(1));
    expect(notes.single.checklist, isEmpty);
  });

  testWidgets('inline tools insert and continue number tick checklist text', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 7, 30));
    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('notebook-inline-number')));
    final description = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-description')),
    );
    expect(description.controller!.text, '1. ');

    description.controller!.text = '1. اول\n';
    description.onChanged?.call(description.controller!.text);
    expect(description.controller!.text, '1. اول\n2. ');

    await tester.tap(find.byKey(const ValueKey('notebook-inline-tick')));
    expect(
      tester.widget<TextField>(find.byKey(const ValueKey('notebook-description'))).controller!.text,
      '1. اول\n2. ✓ ',
    );

    await tester.tap(find.byKey(const ValueKey('notebook-inline-checklist')));
    expect(
      tester.widget<TextField>(find.byKey(const ValueKey('notebook-description'))).controller!.text,
      '1. اول\n2. ✓ [ ] ',
    );

    await tester.pump(const Duration(milliseconds: 500));
    final notes = await repository.loadNotes();
    expect(notes, hasLength(1));
    expect(notes.single.description, contains('1. اول'));
    expect(notes.single.description, contains('✓ [ ] '));
    expect(notes.single.checklist, isEmpty);
  });

  testWidgets('legacy checklist data remains recoverable in inline editor', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 8));
    final note = await repository.createNote(
      id: 'legacy-checklist',
      title: 'چک‌لیست قدیمی',
      checklist: const ['[x] مورد انجام‌شده', '[ ] مورد باز'],
      notebookKind: NotebookItemKind.checklist,
    );

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(ValueKey('notebook-note-${note.id}')));
    await tester.pumpAndSettle();

    final description = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-description')),
    );
    expect(description.controller!.text, '[x] مورد انجام‌شده\n[ ] مورد باز');

    final persisted = await repository.loadNote(note.id);
    expect(persisted?.checklist, const ['[x] مورد انجام‌شده', '[ ] مورد باز']);
  });
  testWidgets('selected category becomes default for new note and search filters cards',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 11, 30));
    await repository.createNote(id: 'category-seed', title: 'یادداشت دسته', category: 'شخصی');
    await pumpNotebook(tester, repository);

    await tester.tap(find.byKey(const ValueKey('notebook-category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-category-filter-شخصی')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-create')));
    await tester.pumpAndSettle();

    final created = (await repository.loadNotes()).firstWhere((note) => note.title == 'یادداشت جدید');
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

  testWidgets('Notebook list renders Jalali date with Persian digits', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 27, 12));
    await repository.createNote(id: 'jalali-list-date', title: 'تاریخ شمسی');

    await pumpNotebook(tester, repository);

    expect(find.textContaining('۱۴۰۵'), findsOneWidget);
    expect(find.textContaining('2026'), findsNothing);
  });

  testWidgets('Notebook editor renders Jalali date with Persian digits', (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 8, 30, 10, 30));
    final note = await repository.createNote(
      id: 'jalali-editor-date',
      title: 'تاریخ ویرایشگر',
    );

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(ValueKey('notebook-note-${note.id}')));
    await tester.pumpAndSettle();

    final date = find.byKey(const ValueKey('notebook-editor-date'));
    expect(date, findsOneWidget);
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
    expect(find.byKey(const ValueKey('notebook-inline-tools')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('notebook-edit')));
    await tester.pump();
    expect(find.byKey(const ValueKey('notebook-inline-tools')), findsOneWidget);
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
    await tester.tap(find.byKey(const ValueKey('notebook-project-rollbox')));
    await tester.pumpAndSettle();
    expect(find.text('پروژه آروین'), findsOneWidget);
    expect(find.text('پروژه بایگانی'), findsNothing);

    await tester.tap(find.text('پروژه آروین').last);
    await tester.pumpAndSettle();

    expect(await repository.projectIdForNote('project-note'), 'project-a');
    expect((await repository.loadNote('project-note'))?.id, 'project-note');
    expect(find.text('پروژه آروین'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('notebook-project-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-project-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بدون پروژه').last);
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
    await tester.tap(find.byKey(const ValueKey('notebook-tags-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('قدیمی').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعمال'));
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
    await tester.tap(find.byKey(const ValueKey('notebook-category-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اداری').last);
    await tester.pumpAndSettle();

    expect(find.text('اداری'), findsOneWidget);
    final persisted = await repository.loadNote('target');
    expect(persisted?.id, 'target');
    expect(persisted?.category, 'اداری');
    expect(await repository.loadNotes(), hasLength(2));
  });

  test('Notebook taxonomy reads and writes the canonical catalog', () async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 30, 10));
    await repository.createCategory('دسته مستقل');
    await repository.createTag('برچسب مستقل');

    expect(await repository.loadCategories(), contains('دسته مستقل'));
    expect(await repository.loadTags(), contains('برچسب مستقل'));
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
    await tester.tap(find.byKey(const ValueKey('notebook-category-rollbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ایجاد دسته جدید').last);
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



  testWidgets('Notebook editor keeps content first with immediate taxonomy and delete actions',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 26, 8));
    final note = await repository.createNote(
      id: 'editor-layout',
      title: 'یادداشت محتوایی',
      category: 'شخصی',
    );
    await repository.updateNote(
      id: note.id,
      title: note.title,
      description: 'متن اصلی یادداشت',
      checklist: const [],
    );

    await pumpNotebook(tester, repository);
    await tester.tap(find.byKey(const ValueKey('notebook-note-editor-layout')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notebook-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-description')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-category-picker')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-project-picker')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-tags-picker')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-editor-trash')), findsOneWidget);

    final description = tester.widget<TextField>(
      find.byKey(const ValueKey('notebook-description')),
    );
    expect(description.minLines, greaterThanOrEqualTo(12));
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
    expect(find.text('دفترچه'), findsWidgets);
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
    expect(find.text('دفترچه'), findsWidgets);
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
    expect(find.text('دفترچه'), findsWidgets);
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



  testWidgets('editor exposes undo and redo controls for the focused text field',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 26, 9));
    await repository.createNote(
      id: 'editor-undo-redo',
      title: 'عنوان اولیه',
    );
    await repository.updateNote(
      id: 'editor-undo-redo',
      title: 'عنوان اولیه',
      description: 'متن اولیه',
      checklist: const [],
    );

    await pumpNotebook(tester, repository);
    await tester.tap(
      find.byKey(const ValueKey('notebook-note-editor-undo-redo')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-edit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notebook-editor-undo')), findsOneWidget);
    expect(find.byKey(const ValueKey('notebook-editor-redo')), findsOneWidget);

    final descriptionFinder =
        find.byKey(const ValueKey('notebook-description'));
    await tester.tap(descriptionFinder);
    await tester.pump();

    expect(
      tester.widget<TextField>(descriptionFinder).controller!.text,
      'متن اولیه',
    );

    // The Flutter widget test environment does not reproduce Android IME
    // history exactly; the device-smoke gate validates the real editor path.
    await tester.tap(find.byKey(const ValueKey('notebook-editor-undo')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('notebook-editor-redo')));
    await tester.pump();

    expect(
      tester.widget<TextField>(descriptionFinder).controller!.text,
      'متن اولیه',
    );
  });


  testWidgets(
      'Notebook selectors use canonical Task taxonomy, including unused-by-Notebook entries',
      (tester) async {
    final repository = repositoryAt(DateTime.utc(2026, 9, 30, 10));
    final taskStore = TaskStore(executor: database);
    await taskStore.save([
      Task(
        id: 'taxonomy-source-task',
        title: 'کار منبع taxonomy',
        category: 'کاری',
        tags: const ['مهم'],
      ),
    ]);
    await repository.createNote(
      id: 'taxonomy-note',
      title: 'یادداشت بدون taxonomy',
    );

    await pumpNotebook(tester, repository);
    await tester.tap(
      find.byKey(const ValueKey('notebook-note-taxonomy-note')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('notebook-category-picker')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-category-rollbox')));
    await tester.pumpAndSettle();
    expect(
      find.text('کاری').last,
      findsOneWidget,
    );
    expect(find.text('انتخاب دسته'), findsWidgets);
    expect(find.text('انتخاب دفتر'), findsNothing);
    await tester.tap(find.text('کاری').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('notebook-tags-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notebook-tags-rollbox')));
    await tester.pumpAndSettle();
    expect(find.text('مهم'), findsOneWidget);
    await tester.tap(find.text('مهم').last);
    await tester.tap(find.text('اعمال'));
    await tester.pumpAndSettle();

    final persisted = await repository.loadNote('taxonomy-note');
    expect(persisted?.category, 'کاری');
    expect(persisted?.tags, const ['مهم']);
  });

}
