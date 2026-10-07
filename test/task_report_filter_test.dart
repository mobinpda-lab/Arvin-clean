import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_report_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 7, 10);

  test('combined filters use AND semantics', () {
    final matching = Task(
      id: 'matching',
      title: 'کار منطبق',
      dueDate: DateTime(2026, 10, 7, 15),
      category: 'مدرسه',
      tags: ['مهم'],
    );
    final wrongTag = Task(
      id: 'wrong-tag',
      title: 'برچسب دیگر',
      dueDate: DateTime(2026, 10, 7, 15),
      category: 'مدرسه',
      tags: ['عادی'],
    );
    final wrongTime = Task(
      id: 'wrong-time',
      title: 'ساعت دیگر',
      dueDate: DateTime(2026, 10, 7, 18),
      category: 'مدرسه',
      tags: ['مهم'],
    );

    final result = const TaskReportFilter(
      timePreset: ReportTimePreset.today,
      fromTime: Duration(hours: 14),
      toTime: Duration(hours: 17),
      category: 'مدرسه',
      tag: 'مهم',
    ).apply([matching, wrongTag, wrongTime], now: now);

    expect(result.map((task) => task.id), ['matching']);
  });

  test('precise date/time ranges exclude undated tasks', () {
    final undated = Task(id: 'undated', title: 'بدون موعد');
    final dated = Task(
      id: 'dated',
      title: 'دارای موعد',
      dueDate: DateTime(2026, 10, 7, 15),
    );

    final result = const TaskReportFilter(
      fromDate: DateTime(2026, 10, 7),
      toDate: DateTime(2026, 10, 7),
      fromTime: Duration(hours: 14),
      toTime: Duration(hours: 17),
    ).apply([undated, dated], now: now);

    expect(result.map((task) => task.id), ['dated']);
  });

  test('status filter keeps archived tasks out of the open set', () {
    final open = Task(id: 'open', title: 'باز');
    final archived = Task(id: 'archived', title: 'بایگانی');
    archived.archived = true;

    final result = const TaskReportFilter(
      status: ReportStatusFilter.open,
    ).apply([open, archived], now: now);

    expect(result.map((task) => task.id), ['open']);
  });

  test('trashed tasks never enter reports', () {
    final active = Task(id: 'active', title: 'فعال');
    final trashed = Task(id: 'trashed', title: 'سطل زباله');
    trashed.trashed = true;

    final result = const TaskReportFilter().apply([active, trashed], now: now);

    expect(result.map((task) => task.id), ['active']);
  });
}
