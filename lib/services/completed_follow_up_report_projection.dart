import '../models/task.dart';

/// One genuine historical Follow-up joined to its owning Task by stable ID.
class CompletedFollowUpReportRow {
  const CompletedFollowUpReportRow({
    required this.task,
    required this.followUp,
  });

  final Task task;
  final FollowUp followUp;

  String get taskId => task.id;
}

/// Projects only saved Follow-up records. Task completion, due dates, Reminder
/// dates and Task creation/update timestamps are deliberately not consulted.
class CompletedFollowUpReportProjection {
  const CompletedFollowUpReportProjection();

  List<CompletedFollowUpReportRow> forLocalDay(
    Iterable<Task> tasks,
    DateTime selectedDay,
  ) {
    final local = selectedDay.toLocal();
    final start = DateTime(local.year, local.month, local.day);
    // Calendar construction, rather than +24h, handles DST day-length changes.
    final end = DateTime(local.year, local.month, local.day + 1);
    final rows = <CompletedFollowUpReportRow>[];

    for (final task in tasks) {
      for (final followUp in task.followUps) {
        final completedAt = followUp.completedAt.toLocal();
        if (!completedAt.isBefore(start) && completedAt.isBefore(end)) {
          rows.add(CompletedFollowUpReportRow(task: task, followUp: followUp));
        }
      }
    }

    rows.sort((a, b) {
      final byTime = a.followUp.completedAt.compareTo(b.followUp.completedAt);
      if (byTime != 0) return byTime;
      final byTask = a.taskId.compareTo(b.taskId);
      return byTask != 0 ? byTask : a.followUp.id.compareTo(b.followUp.id);
    });
    return rows;
  }
}
