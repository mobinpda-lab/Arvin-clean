import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/main.dart';

void main() {
  testWidgets('Arvin starts with the final Persian title', (tester) async {
    await tester.pumpWidget(const ArvinApp());

    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'), findsOneWidget);
    expect(find.text('مدیریت کارها وپیگیری آروین'), findsOneWidget);
  });

  testWidgets('HomePage exposes the current legacy workflow controls',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pump();

    expect(find.text('جست‌وجو'), findsOneWidget);
    expect(find.text('فعال'), findsOneWidget);
    expect(find.text('بایگانی'), findsOneWidget);
    expect(find.text('سطل زباله'), findsOneWidget);
    expect(find.text('کار جدید'), findsOneWidget);
    expect(find.byTooltip('پشتیبان'), findsOneWidget);
  });

  testWidgets('HomePage shows the empty-state message after loading',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کاری برای نمایش وجود ندارد'), findsOneWidget);
    expect(find.text('کل'), findsOneWidget);
    expect(find.text('انجام‌شده'), findsOneWidget);
    expect(find.text('عقب‌افتاده'), findsOneWidget);
  });
}
