import '../models/task.dart';

/// Creates a new independent Task from an existing Task without copying
/// completion or historical Follow-up state and without duplicating alarms.
class TaskCloneService {
  const TaskCloneService();

  Task clone(Task source, {DateTime? at, String? id}) {
    final now = at ?? DateTime.now();
    final payload = Map<String, dynamic>.from(source.toJson());
    payload['id'] = id ?? now.microsecondsSinceEpoch.toString();
    payload['title'] = 'کپی — ${source.title}';
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
}
