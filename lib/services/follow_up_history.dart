class FollowUpHistoryEntry {
  const FollowUpHistoryEntry({
    required this.dateTime,
    this.note = '',
    this.result,
    this.nextFollowUp,
  });

  final DateTime dateTime;
  final String note;
  final String? result;
  final DateTime? nextFollowUp;

  Map<String, dynamic> toJson() => {
        'dateTime': dateTime.toIso8601String(),
        'note': note,
        'result': result,
        'nextFollowUp': nextFollowUp?.toIso8601String(),
      };

  factory FollowUpHistoryEntry.fromJson(Map<String, dynamic> json) {
    return FollowUpHistoryEntry(
      dateTime: DateTime.parse(json['dateTime'] as String),
      note: json['note'] as String? ?? '',
      result: json['result'] as String?,
      nextFollowUp: json['nextFollowUp'] == null
          ? null
          : DateTime.parse(json['nextFollowUp'] as String),
    );
  }
}

/// Pure helpers for follow-up history. Keeping these outside the widgets makes
/// the ordering and legacy migration rules easy to test independently.
class FollowUpHistory {
  const FollowUpHistory._();

  static List<FollowUpHistoryEntry> ordered(
    Iterable<FollowUpHistoryEntry> entries,
  ) {
    final result = entries.toList();
    result.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return result;
  }

  static FollowUpHistoryEntry? latest(
    Iterable<FollowUpHistoryEntry> entries,
  ) {
    final orderedEntries = ordered(entries);
    return orderedEntries.isEmpty ? null : orderedEntries.first;
  }

  /// Preserves the old single follow-up date when upgrading old task data.
  static List<FollowUpHistoryEntry> migrateLegacyDate(DateTime? legacyDate) {
    if (legacyDate == null) return const [];
    return [FollowUpHistoryEntry(dateTime: legacyDate)];
  }
}
