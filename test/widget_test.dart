import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/main.dart';

void main() {
  testWidgets('Arvin starts with the final Persian title', (tester) async {
    await tester.pumpWidget(const ArvinApp());

    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'), findsOneWidget);
    expect(find.text('مدیریت کارها وپیگیری آروین'), findsOneWidget);
  });
}
