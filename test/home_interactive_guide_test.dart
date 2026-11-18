import 'package:arvin/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first-run guide remains disabled', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('1/3'), findsNothing);
    expect(find.text('جست‌وجو'), findsNothing);
    expect(find.text('رد کردن'), findsNothing);
  });
}
