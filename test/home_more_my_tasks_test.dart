import 'package:arvin/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('More exposes category and tag management', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-more-taxonomy')), findsOneWidget);
    expect(find.text('دسته‌ها و برچسب‌ها'), findsOneWidget);
  });
}
