import '../models/task.dart';

/// Pure, case-insensitive search across canonical task and follow-up text.
///
/// Persian and Arabic character variants, diacritics, spaces, and zero-width
/// separators are normalized so visually equivalent user input matches.
/// Multi-term queries use AND semantics and may match across different fields,
/// for example a title term plus a tag or follow-up term.
///
/// A small set of explicit, high-confidence task-management aliases is expanded
/// locally. Aliases use OR semantics inside one query term while separate query
/// terms keep the existing AND semantics. Unknown terms always fall back to the
/// exact normalized substring behavior.
///
/// This service deliberately does not touch persistence or UI so it can be
/// reused by the Home page, FollowUp office, and future global search UI.
class TaskSearchService {
  const TaskSearchService();

  static const List<List<String>> _semanticAliasGroups = [
    ['تماس', 'زنگ'],
    ['جلسه', 'ملاقات'],
    ['فوری', 'ضروری'],
    ['پرداخت', 'واریز'],
    ['ارسال', 'فرستادن'],
  ];

  List<Task> search(Iterable<Task> tasks, String query) {
    final groups = _queryGroups(query);
    if (groups.isEmpty) return List<Task>.of(tasks);

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

      return groups.every(
        (group) => group.any(
          (term) => fields.any((field) => _contains(field, term)),
        ),
      );
    }).toList();
  }

  List<Set<String>> _queryGroups(String value) {
    final normalized = _canonicalize(value)
        .replaceAll(RegExp(r'[\u200B-\u200D\u2060]+'), '')
        .trim();
    if (normalized.isEmpty) return const [];

    return normalized
        .split(RegExp(r'\s+'))
        .map(_normalize)
        .where((term) => term.isNotEmpty)
        .toSet()
        .map(_semanticGroup)
        .toList();
  }

  Set<String> _semanticGroup(String term) {
    for (final aliases in _semanticAliasGroups) {
      final normalizedAliases = aliases.map(_normalize).toSet();
      if (normalizedAliases.contains(term)) return normalizedAliases;
    }
    return {term};
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
