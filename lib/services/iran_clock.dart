/// Provides the canonical current time used by Arvin's Iran-first UI.
///
/// Iran uses UTC+03:30 year-round under the current national time policy.
/// Persisted timestamps remain ordinary DateTime values; this helper only
/// supplies the current wall-clock reference for user-facing behavior.
class IranClock {
  const IranClock._();

  static const Duration utcOffset = Duration(hours: 3, minutes: 30);

  static DateTime now() => DateTime.now().toUtc().add(utcOffset);
}
