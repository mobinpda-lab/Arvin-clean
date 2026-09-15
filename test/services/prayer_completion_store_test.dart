import 'package:arvin/services/prayer_completion_projection.dart';
import 'package:arvin/services/prayer_completion_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists latest status for the same prayer identity', () async {
    const store = PrayerCompletionStore();
    final day = DateTime(2026, 9, 15);

    await store.setStatus(
      day: day,
      prayerId: 'prayer-tehran-2026-09-15-fajr',
      status: PrayerCompletionStatus.completed,
      updatedAt: DateTime(2026, 9, 15, 6),
    );
    await store.setStatus(
      day: day,
      prayerId: 'prayer-tehran-2026-09-15-fajr',
      status: PrayerCompletionStatus.notCompleted,
      updatedAt: DateTime(2026, 9, 15, 7),
    );

    final reloaded = await store.load();
    expect(reloaded, hasLength(1));
    expect(reloaded.single.status, PrayerCompletionStatus.notCompleted);
    expect(reloaded.single.prayerId, 'prayer-tehran-2026-09-15-fajr');
  });

  test('stores prayer state outside canonical Task storage', () async {
    const store = PrayerCompletionStore();
    await store.setStatus(
      day: DateTime(2026, 9, 15),
      prayerId: 'prayer-tehran-2026-09-15-dhuhr',
      status: PrayerCompletionStatus.completed,
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), contains(PrayerCompletionStore.key));
    expect(preferences.getKeys(), isNot(contains('arvin.tasks')));
  });

  test('malformed payload fails closed to an empty state', () {
    const store = PrayerCompletionStore();
    expect(store.decode('{bad json'), isEmpty);
    expect(store.decode('{"not":"a-list"}'), isEmpty);
  });
}
