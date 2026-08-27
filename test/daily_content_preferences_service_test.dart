import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/daily_content.dart';
import 'package:arvin/services/daily_content_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults keep Daily Content visible and notifications opt-in', () async {
    final value = await DailyContentPreferencesService().load();

    expect(value.enabled, isTrue);
    expect(value.notificationEnabled, isFalse);
    expect(value.notificationHour, 8);
    expect(value.notificationMinute, 0);
    expect(value.enabledKinds, containsAll(DailyContentKind.values));
  });

  test('kind switches persist independently', () async {
    final service = DailyContentPreferencesService();

    await service.saveKindEnabled(DailyContentKind.worldQuote, false);
    final value = await service.load();

    expect(value.enabledKinds, isNot(contains(DailyContentKind.worldQuote)));
    expect(value.enabledKinds, contains(DailyContentKind.quran));
  });

  test('notification time validates and persists', () async {
    final service = DailyContentPreferencesService();

    await service.saveNotificationEnabled(true);
    await service.saveNotificationTime(hour: 7, minute: 30);
    final value = await service.load();

    expect(value.notificationEnabled, isTrue);
    expect(value.notificationHour, 7);
    expect(value.notificationMinute, 30);

    expect(
      () => service.saveNotificationTime(hour: 25, minute: 0),
      throwsArgumentError,
    );
  });

  test('unknown stored kinds fail closed without breaking known kinds', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.dailyContent.enabledKinds': ['quran', 'futureUnknownKind'],
    });

    final value = await DailyContentPreferencesService().load();

    expect(value.enabledKinds, {DailyContentKind.quran});
  });
}
