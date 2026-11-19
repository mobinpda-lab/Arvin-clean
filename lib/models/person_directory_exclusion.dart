/// A durable record that a Person was explicitly removed from the active
/// directory while historical Task and Follow-up references remain intact.
class PersonDirectoryExclusion {
  const PersonDirectoryExclusion({
    required this.personId,
    required this.excludedAt,
  });

  final String personId;
  final DateTime excludedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'personId': personId,
        'excludedAt': excludedAt.toIso8601String(),
      };

  factory PersonDirectoryExclusion.fromJson(Map<String, dynamic> json) {
    final personId = json['personId'];
    final rawExcludedAt = json['excludedAt'];
    if (personId is! String || personId.isEmpty ||
        rawExcludedAt is! String || rawExcludedAt.isEmpty) {
      throw const FormatException('Person directory exclusion fields are invalid');
    }
    final excludedAt = DateTime.tryParse(rawExcludedAt);
    if (excludedAt == null) {
      throw const FormatException('Person directory exclusion timestamp is invalid');
    }
    return PersonDirectoryExclusion(
      personId: personId,
      excludedAt: excludedAt,
    );
  }
}
