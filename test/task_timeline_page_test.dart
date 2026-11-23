import 'package:arvin/models/task.dart';
import 'package:arvin/task_timeline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders canonical task history in chronological order',
      (tester) async {
    final task = Task(
      id: 'timeline-1',
      title: 'پرونده مشتری',
      createdAt: DateTime(2026, 8, 26, 8),
      reminderDate: DateTime(2026, 8, 26, 12),
      updatedAt: DateTime(2026, 8, 26, 16),
      followUps: [
        FollowUp(
          id: 'f2',
          dateTime: DateTime(2026, 8, 26, 14),
          note: 'تماس دوم',
          result: 'پاسخ مثبت',
        ),
        FollowUp(
          id: 'f1',
          dateTime: DateTime(2026, 8, 26, 10),
          note: 'تماس اول',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: TaskTimelinePage(task: task)),
    );
    await tester.pumpAndSettle();

    expect(find.text('خط زمانی'), findsOneWidget);
    expect(find.text('ایجاد کار'), findsOneWidget);
    expect(find.text('یادآور'), findsOneWidget);
    expect(find.text('پیگیری'), findsNWidgets(2));
    expect(find.text('آخرین ویرایش'), findsOneWidget);
    expect(find.text('تماس اول'), findsOneWidget);
    expect(find.text('تماس دوم'), findsOneWidget);
    expect(find.text('نتیجه: پاسخ مثبت'), findsOneWidget);

    final labels = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .toList();
    expect(labels.indexOf('ایجاد کار'), lessThan(labels.indexOf('تماس اول')));
    expect(labels.indexOf('تماس اول'), lessThan(labels.indexOf('یادآور')));
    expect(labels.indexOf('یادآور'), lessThan(labels.indexOf('تماس دوم')));
    expect(labels.indexOf('تماس دوم'), lessThan(labels.indexOf('آخرین ویرایش')));
  });

  testWidgets('shows an explicit empty state when no timeline exists',
      (tester) async {
    final task = Task(id: 'empty', title: 'کار بدون تاریخچه');

    await tester.pumpWidget(
      MaterialApp(home: TaskTimelinePage(task: task)),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('هنوز رویدادی برای «کار بدون تاریخچه» ثبت نشده است'),
      findsOneWidget,
    );
  });
}
