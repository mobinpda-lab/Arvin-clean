import '../daily_content.dart';
import 'daily_content_preferences_service.dart';
import 'daily_content_selector.dart';

/// Converts one already-loaded verified pack plus user preferences into the
/// synchronous date resolver required by CalendarPage.
class DailyContentCalendarProjection {
  const DailyContentCalendarProjection({
    DailyContentSelector selector = const DailyContentSelector(),
  }) : _selector = selector;

  final DailyContentSelector _selector;

  DailyContentItem? forDate({
    required DateTime date,
    required DailyContentPack pack,
    required DailyContentPreferences preferences,
  }) {
    if (!preferences.enabled || preferences.enabledKinds.isEmpty) return null;
    return _selector.selectForDate(
      date: date,
      pack: pack,
      enabledKinds: preferences.enabledKinds,
    );
  }

  DailyContentItem? Function(DateTime date) resolver({
    required DailyContentPack pack,
    required DailyContentPreferences preferences,
  }) {
    return (date) => forDate(
          date: date,
          pack: pack,
          preferences: preferences,
        );
  }
}
