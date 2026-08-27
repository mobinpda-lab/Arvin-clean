import 'package:arvin/main.dart';
import 'package:arvin/services/interactive_guide_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('first-run Home guide appears and is remembered', (tester) async {
    await tester.pumpWidget(const ArvinApp(enableFirstRunGuide: true));
    await tester.pumpAndSettle();

    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('ثبت سریع'), findsOneWidget);
    expect(find.text('رد کردن'), findsOneWidget);

    await tester.tap(find.text('رد کردن'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getBool(InteractiveGuideService.seenKey),
      isTrue,
    );
  });

  testWidgets('seen first-run guide does not open automatically', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      InteractiveGuideService.seenKey: true,
    });

    await tester.pumpWidget(const ArvinApp(enableFirstRunGuide: true));
    await tester.pumpAndSettle();

    expect(find.text('1/4'), findsNothing);
  });
}
