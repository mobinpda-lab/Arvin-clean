import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/daily_content_settings_page.dart';
import 'package:arvin/services/daily_content_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows all approved Daily Content categories', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DailyContentSettingsPage(
          service: DailyContentPreferencesService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('قرآن کریم'), findsOneWidget);
    expect(find.text('نهج‌البلاغه'), findsOneWidget);
    expect(find.text('حدیث معتبر شیعه'), findsOneWidget);
    expect(find.text('صحیفه سجادیه'), findsOneWidget);
    expect(find.text('سخن بزرگان ایران'), findsOneWidget);
    expect(find.text('سخن بزرگان جهان'), findsOneWidget);
  });

  testWidgets('notification is opt-in by default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DailyContentSettingsPage(
          service: DailyContentPreferencesService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'اعلان پیام روز'),
    );
    expect(tile.value, isFalse);
  });
}
