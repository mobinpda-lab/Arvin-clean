import '../models/task.dart';

/// Pure, case-insensitive search across canonical task and follow-up text.
///
/// Persian and Arabic character variants, diacritics, spaces, and zero-width
/// separators are normalized so visually equivalent user input matches.
/// Multi-term queries use AND semantics and may match across different fields,
/// for example a title term plus a tag or follow-up term.
///
/// This service deliberately does not touch persistence or UI so it can be
/// reused by the Home page, FollowUp office, and future global search UI.
class TaskSearchService {
  const TaskSearchService();

  List<Task> search(Iterable<Task> tasks, String query) {
    final terms = _queryTerms(query);
    if (terms.isEmpty) return List<Task>.of(tasks);

    return tasks.where((task) {
      final fields = <String>[
        task.title,
        task.description,
        ...task.tags,
        if (task.category != null) task.category!,
        ...task.checklist,
        for (final followUp in task.followUps) ...[
          followUp.note,
          followUp.result ?? '',
        ],
      ];

      return terms.every(
        (term) => fields.any((field) => _contains(field, term)),
      );
    }).toList();
  }

  List<String> _queryTerms(String value) {
    final normalized = _canonicalize(value)
        .replaceAll(RegExp(r'[\u200B-\u200D\u2060]+'), '')
        .trim();
    if (normalized.isEmpty) return const [];

    return normalized
        .split(RegExp(r'\s+'))
        .map(_normalize)
        .where((term) => term.isNotEmpty)
        .toSet()
        .toList();
  }

  String _canonicalize(String value) => value
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ى', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

  String _normalize(String value) => _canonicalize(value)
      .trim()
      .replaceAll(RegExp(r'[\s\u200B-\u200D\u2060]+'), '');

  bool _contains(String value, String query) =>
      _normalize(value).contains(query);
}
