import '../models/task.dart';

class FollowUpAgendaItem {
  const FollowUpAgendaItem({required this.taskId, required this.followUp});

  final String taskId;
  final FollowUp followUp;
}

/// Builds a chronological agenda without changing Task or persistence models.
class FollowUpAgenda {
  const FollowUpAgenda();

  List<FollowUpAgendaItem> build(
    Iterable<Task> tasks, {
    DateTime? from,
    bool futureOnly = false,
  }) {
    final reference = from ?? DateTime.now();
    final result = <FollowUpAgendaItem>[];

    for (final task in tasks) {
      for (final followUp in task.followUps) {
        if (futureOnly && followUp.dateTime.isBefore(reference)) continue;
        result.add(FollowUpAgendaItem(taskId: task.id, followUp: followUp));
      }
    }

    result.sort((a, b) => a.followUp.dateTime.compareTo(b.followUp.dateTime));
    return result;
  }

  List<FollowUpAgendaItem> upcomingNext(
    Iterable<Task> tasks, {
    DateTime? from,
  }) {
    final reference = from ?? DateTime.now();
    final result = <FollowUpAgendaItem>[];

    for (final task in tasks) {
      for (final followUp in task.followUps) {
        final next = followUp.nextFollowUp;
        if (next == null || !next.isAfter(reference)) continue;
        result.add(FollowUpAgendaItem(taskId: task.id, followUp: followUp));
      }
    }

    result.sort((a, b) => a.followUp.nextFollowUp!
        .compareTo(b.followUp.nextFollowUp!));
    return result;
  }
}
