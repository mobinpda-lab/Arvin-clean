import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/task_detail_page.dart';

void main() {
  testWidgets('Task Details category and tags use shared filter selectors', (tester) async {
    var saved = Task(
      id: 'detail-metadata',
      title: 'کار آزمایشی',
      category: 'کاری',
      tags: ['مهم'],
    );

    await tester.pumpWidget(MaterialApp(
      home: TaskDetailPage(
        task: saved,
        categoryOptions: const ['کاری', 'شخصی'],
        tagOptions: const ['مهم', 'فوری'],
        onTaskChanged: (updated) async {
          saved = updated;
          return updated;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RadioListTile<Object?>, 'شخصی'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-tags')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'فوری'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-detail-inline-edit-toggle')));
    await tester.pumpAndSettle();

    expect(saved.category, 'شخصی');
    expect(saved.tags.toSet(), {'مهم', 'فوری'});
  });
}
