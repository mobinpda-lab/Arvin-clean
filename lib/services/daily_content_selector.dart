import '../daily_content.dart';

/// Deterministically selects one verified content item for a calendar day.
///
/// Properties:
/// - reopening the same date returns the same item for the same pack/settings;
/// - consecutive days walk through a stable permutation, so no item repeats
///   until the eligible pool is exhausted;
/// - no runtime randomness or new dependency is required;
/// - unpublished/unverifiable items are never selected.
class DailyContentSelector {
  const DailyContentSelector();

  DailyContentItem? selectForDate({
    required DateTime date,
    required DailyContentPack pack,
    Set<DailyContentKind>? enabledKinds,
  }) {
    if (pack.schemaVersion != 1 || pack.contentVersion.trim().isEmpty) {
      return null;
    }

    final candidates = pack.publishableItems.where((item) {
      return enabledKinds == null || enabledKinds.contains(item.kind);
    }).toList(growable: false);

    if (candidates.isEmpty) {
      return null;
    }

    final ordered = List<DailyContentItem>.of(candidates)
      ..sort((a, b) {
        final aKey = _stableHash('${pack.contentVersion}|${a.id}');
        final bKey = _stableHash('${pack.contentVersion}|${b.id}');
        final byHash = aKey.compareTo(bKey);
        return byHash != 0 ? byHash : a.id.compareTo(b.id);
      });

    final utcDay = DateTime.utc(date.year, date.month, date.day);
    final dayNumber = utcDay.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    final index = dayNumber % ordered.length;
    return ordered[index];
  }

  /// 32-bit FNV-1a, implemented locally so selection stays stable across app
  /// launches and does not depend on Dart's runtime hash implementation.
  int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}
