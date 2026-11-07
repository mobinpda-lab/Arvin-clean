import 'package:arvin/core/theme/app_theme_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppThemeManager.instance.load();
  });

  test('uses vivid sky blue as the default when no color was selected', () async {
    expect(AppThemeManager.instance.selectedHex, '#3A86EF');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(AppThemeManager.preferenceKey), isNull);
  });

  test('persists a supported palette choice and restores it on load', () async {
    await AppThemeManager.instance.select('#7209B7');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(AppThemeManager.preferenceKey), '#7209B7');

    await AppThemeManager.instance.select('#3A86EF');
    await preferences.setString(AppThemeManager.preferenceKey, '#7209B7');
    await AppThemeManager.instance.load();
    expect(AppThemeManager.instance.selectedHex, '#7209B7');
  });

  test('clears an unsupported legacy stored color and restores the default', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(AppThemeManager.preferenceKey, '#000080');
    await AppThemeManager.instance.load();
    expect(AppThemeManager.instance.selectedHex, '#3A86EF');
    expect(preferences.getString(AppThemeManager.preferenceKey), isNull);
  });

  test('rejects colors outside the approved nine-color palette', () async {
    expect(
      () => AppThemeManager.instance.select('#000080'),
      throwsArgumentError,
    );
    expect(
      AppThemeManager.palette.map((entry) => entry.hex).toList(),
      <String>['#078B91', '#1B4965', '#2A9D8F', '#4361EE', '#7209B7', '#F77F00', '#D90429', '#3A86EF', '#2B2D42'],
    );
    expect(AppThemeManager.palette[7].hex, '#3A86EF');
  });
}
