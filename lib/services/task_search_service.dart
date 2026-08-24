import '../models/task.dart';

/// Pure, case-insensitive search across task and follow-up text.
///
/// Persian and Arabic character variants, diacritics, spaces, and zero-width
/// separators are normalized so visually equivalent user input matches.
///
/// This service deliberately does not touch persistence or UI so it can be
/// reused by the Home page, FollowUp office, and future global search UI.
class TaskSearchService {
  const TaskSearchService();

  List<Task> search(Iterable<Task> tasks, String query) {
    final normalized = _normalize(query);
    if (normalized.isEmpty) return List<Task>.of(tasks);

    return tasks.where((task) {
      if (_contains(task.title, normalized) ||
          _contains(task.description, normalized) ||
          task.tags.any((tag) => _contains(tag, normalized))) {
        return true;
      }

      return task.followUps.any((followUp) =>
          _contains(followUp.note, normalized) ||
          _contains(followUp.result ?? '', normalized));
    }).toList();
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ى', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'[\s\u200B-\u200D\u2060]+'), '');

  bool _contains(String value, String query) =>
      _normalize(value).contains(query);
}
