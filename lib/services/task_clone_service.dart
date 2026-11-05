import '../models/task.dart';

/// Creates a new independent Task from an existing Task without copying
/// completion or historical Follow-up state and without duplicating alarms.
class TaskCloneService {
  const TaskCloneService();

  Task clone(
    Task source, {
    DateTime? at,
    String? id,
    Iterable<String> existingTitles = const <String>[],
  }) {
    final now = at ?? DateTime.now();
    final payload = Map<String, dynamic>.from(source.toJson());
    payload['id'] = id ?? now.microsecondsSinceEpoch.toString();
    payload['title'] = uniqueCloneTitle(source.title, existingTitles);
    payload['createdAt'] = now.toIso8601String();
    payload['updatedAt'] = now.toIso8601String();
    payload['completed'] = false;
    payload.remove('completedAt');
    payload['followUps'] = <dynamic>[];
    payload['taskReminders'] = <dynamic>[];
    payload.remove('reminderDate');
    payload.remove('followUpEnabled');
    payload.remove('followUpDate');
    payload['checklistOccurrences'] = <String, dynamic>{};
    payload['occurrenceHistory'] = <String, dynamic>{};
    return Task.fromJson(payload);
  }

  /// Produces a stable Persian clone suffix without stacking suffixes.
  /// Existing titles are supplied by the caller from the canonical Task list.
  String uniqueCloneTitle(String sourceTitle, Iterable<String> existingTitles) {
    final suffix = RegExp(r'\s+—\s+رونوشت(?:\s+[۰-۹0-9]+)?$');
    final base = sourceTitle.trim().replaceFirst(suffix, '').trim();
    final occupied = existingTitles.map((title) => title.trim()).toSet();
    final first = '$base — رونوشت';
    if (!occupied.contains(first)) return first;
    for (var index = 2; ; index++) {
      final candidate = '$base — رونوشت ${_toPersianDigits(index)}';
      if (!occupied.contains(candidate)) return candidate;
    }
  }

  String _toPersianDigits(int value) => value.toString().replaceAllMapped(
        RegExp(r'[0-9]'),
        (match) => '۰۱۲۳۴۵۶۷۸۹'[int.parse(match[0]!)],
      );
}
