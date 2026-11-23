import '../models/task.dart';

class WidgetFollowUpItem {
  const WidgetFollowUpItem({
    required this.taskId,
    required this.title,
    required this.note,
    required this.dateTime,
    this.result,
  });

  final String taskId;
  final String title;
  final String note;
  final String? result;
  final DateTime dateTime;
}

/// Read-only product projection for the native Widget contract.
///
/// It owns no persistence. Android reads the same serialized Task payload and
/// mirrors this rule when the Flutter process is not running.
class WidgetFollowUpProjection {
  const WidgetFollowUpProjection();

  List<WidgetFollowUpItem> project(
    Iterable<Task> tasks, {
    int limit = 3,
  }) {
    if (limit <= 0) return const <WidgetFollowUpItem>[];

    final items = <WidgetFollowUpItem>[];
    for (final task in tasks) {
      if (task.trashed || task.archived || task.completed) continue;
      final followUp = task.lastFollowUp;
      if (followUp == null) continue;

      items.add(
        WidgetFollowUpItem(
          taskId: task.id,
          title: task.title.trim().isEmpty ? 'بدون عنوان' : task.title,
          note: followUp.note,
          result: followUp.result,
          dateTime: followUp.dateTime,
        ),
      );
    }

    items.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return List<WidgetFollowUpItem>.unmodifiable(items.take(limit));
  }
}
