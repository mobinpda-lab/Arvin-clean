import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/services/app_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Vazirmatn is the default font preference', () async {
    final settings = await AppSettingsService().load();
    expect(settings.fontPreference, 'vazirmatn');
  });

  test('System Default preference survives a fresh service instance', () async {
    final service = AppSettingsService();
    await service.saveFontPreference('system-default');

    final reopened = await AppSettingsService().load();
    expect(reopened.fontPreference, 'system-default');
  });

  test('only the two approved font preference values are accepted', () async {
    final service = AppSettingsService();
    await expectLater(
      service.saveFontPreference('other-font'),
      throwsArgumentError,
    );
    await service.saveFontPreference('vazirmatn');
    expect((await service.load()).fontPreference, 'vazirmatn');
  });
}
