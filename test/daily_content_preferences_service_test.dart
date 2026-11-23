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

  test('portable preferences round-trip and preserve omitted legacy fields', () async {
    final service = DailyContentPreferencesService();
    await service.restorePortableJson({
      'enabled': false,
      'notificationEnabled': true,
      'notificationHour': 6,
      'notificationMinute': 45,
      'enabledKinds': ['quran'],
    });
    var value = await service.load();
    expect(value.enabled, isFalse);
    expect(value.notificationEnabled, isTrue);
    expect(value.notificationHour, 6);
    expect(value.notificationMinute, 45);
    expect(value.enabledKinds, {DailyContentKind.quran});

    await service.restorePortableJson({'enabled': true});
    value = await service.load();
    expect(value.enabled, isTrue);
    expect(value.notificationEnabled, isTrue);
    expect(value.notificationHour, 6);
    expect(value.notificationMinute, 45);
    expect(value.enabledKinds, {DailyContentKind.quran});
  });

  test('portable preferences validate before changing values', () async {
    final service = DailyContentPreferencesService();
    await service.saveEnabled(true);
    expect(
      () => service.restorePortableJson({'notificationHour': 25}),
      throwsFormatException,
    );
    expect((await service.load()).enabled, isTrue);
  });

  test('unknown stored kinds fail closed without breaking known kinds', () async {
    SharedPreferences.setMockInitialValues({
      'arvin.dailyContent.enabledKinds': ['quran', 'futureUnknownKind'],
    });

    final value = await DailyContentPreferencesService().load();

    expect(value.enabledKinds, {DailyContentKind.quran});
  });
}
