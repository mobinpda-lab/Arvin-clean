import 'package:arvin/models/task.dart';
import 'package:arvin/models/arvin_center.dart';
import 'package:arvin/models/goal_project.dart';
import 'package:arvin/models/project_template.dart';
import 'package:arvin/models/person_reference.dart';
import 'package:arvin/report_center_page.dart';
import 'package:arvin/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _ensureReportFilterTargetVisible(
  WidgetTester tester,
  Finder target,
) async {
  await tester.pumpAndSettle();
  final filterList = find.byKey(const ValueKey('report-filter-scroll'));
  expect(filterList, findsOneWidget);
  for (var attempt = 0; attempt < 20 && !tester.any(target); attempt++) {
    await tester.drag(filterList, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Report Center opens an Arvin bottom-sheet filter panel', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 7, 10),
          tasks: [
            Task(id: 'one', title: 'اول', dueDate: DateTime(2026, 10, 7, 15)),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();

    expect(find.text('فیلتر گزارش‌ها'), findsOneWidget);
    expect(find.text('اهمیت'), findsNothing);
    expect(find.byKey(const ValueKey('report-home-filter-time')), findsOneWidget);
    final todayPreset = find.text('امروز');
    await _ensureReportFilterTargetVisible(tester, todayPreset);
    expect(todayPreset, findsOneWidget);
    expect(find.text('بازه دقیق'), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('report-filter-header'))).height, 64);

    final applyBeforeScroll = tester.getRect(find.byKey(const ValueKey('report-filter-apply')));
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('report-filter-apply')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-filter-clear')), findsOneWidget);
    expect(tester.getRect(find.byKey(const ValueKey('report-filter-apply'))), applyBeforeScroll);
    expect(find.text('بازنشانی'), findsOneWidget);
    expect(find.text('اعمال فیلتر'), findsOneWidget);
  });

  testWidgets(
    'Report Center combines time and category filters and opens that exact report scope',
    (tester) async {
      final now = DateTime(2026, 10, 7, 10);
      await tester.pumpWidget(
        MaterialApp(
          home: ReportCenterPage(
            now: now,
            tasks: [
              Task(
                id: 'match',
                title: 'جلسه امروز',
                category: 'کار',
                tags: ['مهم'],
                dueDate: DateTime(2026, 10, 7, 15),
              ),
              Task(
                id: 'wrong-time',
                title: 'جلسه فردا',
                category: 'کار',
                tags: ['مهم'],
                dueDate: DateTime(2026, 10, 8, 15),
              ),
              Task(
                id: 'wrong-category',
                title: 'خرید امروز',
                category: 'خرید',
                tags: ['مهم'],
                dueDate: DateTime(2026, 10, 7, 15),
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('report-center-filters')));
      await tester.pumpAndSettle();

      final timeSection =
          find.byKey(const ValueKey('report-filter-section-زمان'));
      await _ensureReportFilterTargetVisible(tester, timeSection);
      await tester.ensureVisible(timeSection);
      await tester.pumpAndSettle();
      final todayPreset = find.descendant(
        of: timeSection,
        matching: find.text('امروز'),
      );
      await tester.ensureVisible(todayPreset);
      await tester.tap(todayPreset);
      await tester.pumpAndSettle();

      await _ensureReportFilterTargetVisible(
        tester,
        find.byKey(const ValueKey('report-filter-section-دسته')),
      );
      await tester.tap(find.byKey(const ValueKey('report-filter-section-دسته')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('report-filter-category-کار')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const ValueKey('report-filter-category-کار')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('report-filter-apply')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
      await tester.pumpAndSettle();

      expect(find.text('نتیجه: 1 کار'), findsOneWidget);
      expect(find.text('جلسه امروز'), findsOneWidget);
      expect(find.text('خرید امروز'), findsNothing);
      expect(find.text('جلسه فردا'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('report-center-open-report')));
      await tester.pumpAndSettle();

      expect(find.text('گزارش و اشتراک‌گذاری'), findsOneWidget);
      expect(find.byKey(const ValueKey('report-task-match')), findsOneWidget);
      expect(find.byKey(const ValueKey('report-task-wrong-time')), findsNothing);
      expect(find.byKey(const ValueKey('report-task-wrong-category')), findsNothing);
    },
  );
  testWidgets('Report Center shows separate person-specific active waiting rows', (tester) async {
    final ana = PersonReference(id: 'ana', displayName: 'آنا');
    final reza = PersonReference(id: 'reza', displayName: 'رضا');
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 15, 10),
          people: [ana, reza],
          tasks: [
            Task(
              id: 'task-waiting',
              title: 'پرونده مشتری',
              followUps: [
                FollowUp(
                  id: 'waiting-ana',
                  dateTime: DateTime(2026, 10, 15, 9),
                  note: 'پاسخ آنا',
                  personIds: ['ana'],
                  waitingForResponse: true,
                  nextFollowUp: DateTime(2026, 10, 16, 9),
                  reminderDate: DateTime(2026, 10, 15, 18),
                ),
                FollowUp(
                  id: 'waiting-reza',
                  dateTime: DateTime(2026, 10, 15, 9),
                  note: 'پاسخ رضا',
                  personIds: ['reza'],
                  waitingForResponse: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('report-filter-section-نوع')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('report-filter-section-نوع')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('منتظر پاسخ'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('report-filter-section-نوع')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('منتظر پاسخ'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('report-filter-apply')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('نتیجه: 2 پیگیری'), findsOneWidget);
    expect(find.textContaining('پاسخ آنا'), findsOneWidget);
    expect(find.textContaining('پاسخ رضا'), findsOneWidget);
    expect(find.textContaining('اقدام بعدی:'), findsNothing);
    expect(find.textContaining('یادآور:'), findsNothing);

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    final peopleSection =
        find.byKey(const ValueKey('report-filter-section-اشخاص'));
    await _ensureReportFilterTargetVisible(tester, peopleSection);
    await tester.ensureVisible(peopleSection);
    await tester.pumpAndSettle();
    await tester.tap(peopleSection);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('report-filter-person-ana')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('report-filter-person-ana')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('report-filter-apply')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('نتیجه: 1 پیگیری'), findsOneWidget);
    expect(find.textContaining('پاسخ آنا'), findsOneWidget);
    expect(find.textContaining('پاسخ رضا'), findsNothing);
    final personFilterChip = find.byKey(const ValueKey('report-active-person-ana'));
    expect(personFilterChip, findsOneWidget);
    tester.widget<InputChip>(personFilterChip).onDeleted!();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('report-active-person-ana')), findsNothing);
    expect(find.textContaining('پاسخ رضا'), findsOneWidget);
  });

  testWidgets('Report Center keeps deleted people selectable by stable label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 7, 10),
          tasks: [
            Task(
              id: 'historical',
              title: 'کار تاریخی',
              followUps: [
                FollowUp(
                  id: 'follow-up-deleted-person',
                  dateTime: DateTime(2026, 10, 7, 9),
                  personIds: ['person-deleted-stable-id'],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    final peopleSection =
        find.byKey(const ValueKey('report-filter-section-اشخاص'));
    await _ensureReportFilterTargetVisible(tester, peopleSection);
    await tester.ensureVisible(peopleSection);
    await tester.pumpAndSettle();
    await tester.tap(peopleSection);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('report-filter-person-person-deleted-stable-id')),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('شخص حذف‌شده'), findsOneWidget);
    expect(find.byKey(const ValueKey('report-filter-person-person-deleted-stable-id')), findsOneWidget);
  });


  testWidgets('task and waiting follow-up cards open canonical TaskDetailPage', (tester) async {
    final person = PersonReference(id: 'ana', displayName: 'آنا');
    final task = Task(
      id: 'task-open-from-report',
      title: 'کار با پیگیری',
      followUps: [
        FollowUp(
          id: 'waiting-open-from-report',
          dateTime: DateTime(2026, 10, 15, 9),
          note: 'پاسخ مشتری',
          personIds: ['ana'],
          waitingForResponse: true,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 10, 15, 10),
          people: [person],
          tasks: [task],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('report-task-card-task-open-from-report')));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    final typeSection = find.byKey(
      const ValueKey('report-filter-section-نوع'),
    );
    await tester.scrollUntilVisible(
      typeSection,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(typeSection);
    await tester.pumpAndSettle();
    await tester.tap(typeSection);
    await tester.pumpAndSettle();
    await tester.tap(find.text('منتظر پاسخ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('report-filter-apply')));
    await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('نتیجه: 1 پیگیری'), findsOneWidget);
    await tester.tap(find.text('کار با پیگیری'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailPage), findsOneWidget);
  });



  testWidgets('Report Center exposes center and searchable task controls', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ReportCenterPage(
        now: DateTime(2026, 11, 3, 10),
        centers: [ArvinCenter(id: '511', name: 'مرکز ۵۱۱', createdAt: DateTime(2026, 1, 1))],
        templates: [ProjectTemplate(id: 'tpl', name: 'کالیبراسیون یخچال', tasks: [ProjectTemplateTask(id: 'tt-fan', title: 'بررسی فن')], createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 1, 1))],
        projects: [ProjectPlan(id: 'p511', title: 'پروژه ۵۱۱', centerId: '511', itemIds: const ['t511'])],
        tasks: [Task(id: 't511', title: 'بررسی فن')],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    final centerSection = find.byKey(const ValueKey('report-filter-section-مرکز'));
    await tester.scrollUntilVisible(centerSection, 240, scrollable: find.byType(Scrollable).last);
    await tester.ensureVisible(centerSection);
    await tester.pumpAndSettle();
    await tester.tap(centerSection);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-center-511')), 240, scrollable: find.byType(Scrollable).last);
    expect(find.byKey(const ValueKey('report-filter-center-511')), findsOneWidget);
    final taskSection = find.byKey(const ValueKey('report-filter-section-کار'));
    await tester.scrollUntilVisible(taskSection, 240, scrollable: find.byType(Scrollable).last);
    await tester.tap(taskSection);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-task-search')), 240, scrollable: find.byType(Scrollable).last);
    expect(find.byKey(const ValueKey('report-filter-task-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-filter-task-t511')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-section-قالب پروژه')), 240, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('report-filter-section-قالب پروژه')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-template-tpl')), 240, scrollable: find.byType(Scrollable).last);
    expect(find.byKey(const ValueKey('report-filter-template-tpl')), findsOneWidget);
    expect(find.byKey(const ValueKey('report-filter-template-search')), findsOneWidget);
  });
  testWidgets('Report Center Past preset includes elapsed timed tasks today and excludes completed tasks', (tester) async {
    final now = DateTime(2026, 10, 7, 10);
    await tester.pumpWidget(MaterialApp(
      home: ReportCenterPage(
        now: now,
        tasks: [
          Task(id: 'done-newer', title: 'انجام‌شده جدیدتر', completed: true, dueDate: DateTime(2026, 10, 6, 9)),
          Task(id: 'open-newer', title: 'باز جدیدتر', dueDate: DateTime(2026, 10, 6, 10)),
          Task(id: 'done-older', title: 'انجام‌شده قدیمی‌تر', completed: true, dueDate: DateTime(2026, 10, 3, 9)),
          Task(id: 'open-older', title: 'باز قدیمی‌تر', dueDate: DateTime(2026, 10, 4, 9)),
          Task(id: 'today', title: 'موعد امروز', dueDate: DateTime(2026, 10, 7, 8)),
        ],
      ),
    ));

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();
    final timeSection =
        find.byKey(const ValueKey('report-filter-section-زمان'));
    await _ensureReportFilterTargetVisible(tester, timeSection);
    await tester.ensureVisible(timeSection);
    await tester.pumpAndSettle();
    final pastPreset = find.descendant(
      of: timeSection,
      matching: find.text('گذشته'),
    );
    await tester.ensureVisible(pastPreset);
    await tester.tap(pastPreset);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('report-filter-apply')));
    await tester.tap(find.byKey(const ValueKey('report-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('نتیجه: 3 کار'), findsOneWidget);
    expect(find.byKey(const ValueKey('report-task-card-today')), findsOneWidget);
    final openOlder = find.byKey(const ValueKey('report-task-card-open-older'));
    final openNewer = find.byKey(const ValueKey('report-task-card-open-newer'));
    final todayTimed = find.byKey(const ValueKey('report-task-card-today'));
    expect(find.byKey(const ValueKey('report-task-card-done-older')), findsNothing);
    expect(find.byKey(const ValueKey('report-task-card-done-newer')), findsNothing);
    expect(tester.getTopLeft(openOlder).dy, lessThan(tester.getTopLeft(openNewer).dy));
    expect(tester.getTopLeft(openNewer).dy, lessThan(tester.getTopLeft(todayTimed).dy));
  });

  testWidgets('Report Center active filter chips wrap without overflow on a short RTL viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: ReportCenterPage(
        now: DateTime(2026, 10, 7, 10),
        tasks: [
          Task(id: 'chip-a', title: 'کار اداری', category: 'اداری', tags: ['مهم', 'فوری'], dueDate: DateTime(2026, 10, 6, 9)),
          Task(id: 'chip-b', title: 'کار شخصی', category: 'شخصی', tags: ['پیگیری'], dueDate: DateTime(2026, 10, 5, 9), completed: true),
          Task(id: 'chip-c', title: 'کار مالی', category: 'مالی', tags: ['مهم'], dueDate: DateTime(2026, 10, 4, 9)),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();

    final categorySection = find.byKey(const ValueKey('report-filter-section-دسته'));
    await tester.scrollUntilVisible(categorySection, 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(categorySection);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-category-اداری')), 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('report-filter-category-اداری')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-category-شخصی')), 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('report-filter-category-شخصی')));
    await tester.pumpAndSettle();

    final tagSection = find.byKey(const ValueKey('report-filter-section-برچسب'));
    await tester.scrollUntilVisible(tagSection, 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(tagSection);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-tag-مهم')), 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('report-filter-tag-مهم')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-tag-فوری')), 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('report-filter-tag-فوری')));
    await tester.pumpAndSettle();

    final statusSection = find.byKey(const ValueKey('report-filter-section-وضعیت کار'));
    await tester.scrollUntilVisible(statusSection, 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(statusSection);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-status-open')), 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('report-filter-status-open')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('report-filter-status-completed')), 180, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('report-filter-status-completed')));
    await tester.pumpAndSettle();

    final apply = find.byKey(const ValueKey('report-filter-apply'));
    await tester.ensureVisible(apply);
    await tester.tap(apply);
    await tester.pumpAndSettle();

    expect(find.byType(InputChip), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed follow-up report is selected through unified filters',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCenterPage(
          now: DateTime(2026, 11, 4, 10),
          tasks: [
            Task(
              id: 'follow-up-task',
              title: 'پیگیری نمونه',
              followUps: [
                FollowUp(
                  id: 'follow-up-record',
                  dateTime: DateTime(2026, 11, 4, 9),
                  note: 'تماس انجام شد',
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.byKey(const ValueKey('report-center-completed-follow-ups')),
        findsNothing);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-center-filters')));
    await tester.pumpAndSettle();

    expect(find.byKey(
      const ValueKey('report-filter-type-completed-follow-ups'),
    ), findsOneWidget);
    await tester.tap(find.byKey(
      const ValueKey('report-filter-type-completed-follow-ups'),
    ));
    await tester.pumpAndSettle();

    final apply = find.byKey(const ValueKey('report-filter-apply'));
    await tester.ensureVisible(apply);
    await tester.tap(apply);
    await tester.pumpAndSettle();

    expect(find.text('گزارش پیگیری‌های انجام‌شده'), findsOneWidget);
    expect(
      find.byKey(const ValueKey(
        'completed-follow-up-record-follow-up-task-follow-up-record',
      )),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

}

