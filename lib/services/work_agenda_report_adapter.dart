import '../models/task.dart';
import 'task_report_projection.dart';
import 'work_agenda_projection.dart';

class WorkAgendaReportItem {
  const WorkAgendaReportItem({
    required this.entry,
    required this.events,
  });

  final TaskReportEntry entry;
  final List<WorkAgendaEvent> events;
}

class WorkAgendaReportDay {
  const WorkAgendaReportDay({
    required this.day,
    required this.items,
  });

  final DateTime day;
  final List<WorkAgendaReportItem> items;
}

class WorkAgendaReport {
  const WorkAgendaReport({
    required this.title,
    required this.generatedAt,
    required this.days,
  });

  final String title;
  final DateTime generatedAt;
  final List<WorkAgendaReportDay> days;
}

/// Thin read-only adapter between the canonical work agenda and the existing
/// Task report projection. It does not introduce a second report foundation.
///
/// Agenda owns day/range scheduling semantics and reason ordering. The existing
/// TaskReportProjection continues to own reportable Task payload shape.
class WorkAgendaReportAdapter {
  const WorkAgendaReportAdapter({
    this.agendaProjection = const WorkAgendaProjection(),
    this.taskReportProjection = const TaskReportProjection(),
  });

  final WorkAgendaProjection agendaProjection;
  final TaskReportProjection taskReportProjection;

  WorkAgendaReport forDay(
    Iterable<Task> tasks, {
    required DateTime day,
    DateTime? generatedAt,
    String title = 'گزارش کارهای روز',
  }) {
    return _build(
      tasks,
      agendaProjection.forDay(tasks, day: day),
      generatedAt: generatedAt,
      title: title,
    );
  }

  WorkAgendaReport forRange(
    Iterable<Task> tasks, {
    required DateTime startDay,
    required DateTime endDay,
    DateTime? generatedAt,
    String title = 'گزارش بازه کاری',
  }) {
    return _build(
      tasks,
      agendaProjection.forRange(
        tasks,
        startDay: startDay,
        endDay: endDay,
      ),
      generatedAt: generatedAt,
      title: title,
    );
  }

  WorkAgendaReport _build(
    Iterable<Task> tasks,
    List<WorkAgendaDay> agenda, {
    required DateTime? generatedAt,
    required String title,
  }) {
    final selectedIds = agenda
        .expand((day) => day.items)
        .map((item) => item.taskId)
        .toSet();

    final taskReport = taskReportProjection.project(
      tasks,
      selectedIds: selectedIds,
      generatedAt: generatedAt,
      title: title,
    );
    final entriesById = {
      for (final entry in taskReport.entries) entry.id: entry,
    };

    final days = agenda.map((agendaDay) {
      final items = agendaDay.items.map((agendaItem) {
        final entry = entriesById[agendaItem.taskId];
        if (entry == null) {
          throw StateError(
            'Agenda task ${agendaItem.taskId} is missing from canonical report projection',
          );
        }
        return WorkAgendaReportItem(
          entry: entry,
          events: List<WorkAgendaEvent>.unmodifiable(agendaItem.events),
        );
      }).toList(growable: false);

      return WorkAgendaReportDay(
        day: agendaDay.day,
        items: List<WorkAgendaReportItem>.unmodifiable(items),
      );
    }).toList(growable: false);

    return WorkAgendaReport(
      title: taskReport.title,
      generatedAt: taskReport.generatedAt,
      days: List<WorkAgendaReportDay>.unmodifiable(days),
    );
  }
}
