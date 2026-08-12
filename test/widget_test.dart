import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/main.dart';

void main() {
  testWidgets('Arvin starts', (tester) async {
    await tester.pumpWidget(const ArvinApp());
    expect(find.text('آروین'), findsWidgets);
  });
}
