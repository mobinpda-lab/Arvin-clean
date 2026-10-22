import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Vazirmatn renders Persian RTL, half-space, digits and weights',
      (tester) async {
    final regular = await rootBundle.load(
      'assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf',
    );
    final medium = await rootBundle.load(
      'assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf',
    );
    final semiBold = await rootBundle.load(
      'assets/fonts/ui/vazirmatn/Vazirmatn-SemiBold.ttf',
    );
    final bold = await rootBundle.load(
      'assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf',
    );
    expect(regular.lengthInBytes, greaterThan(1000));
    expect(medium.lengthInBytes, greaterThan(1000));
    expect(semiBold.lengthInBytes, greaterThan(1000));
    expect(bold.lengthInBytes, greaterThan(1000));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Vazirmatn'),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Column(
              children: [
                Text('بسم الله الرحمن الرحیم'),
                Text('می‌روم'),
                Text('۱۴۰۵/۰۷/۰۱'),
                Text('وزیرمتن', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w400)),
                Text('وزیرمتن', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w500)),
                Text('وزیرمتن', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600)),
                Text('وزیرمتن', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('بسم الله الرحمن الرحیم'), findsOneWidget);
    expect(find.text('می‌روم'), findsOneWidget);
    expect(find.text('۱۴۰۵/۰۷/۰۱'), findsOneWidget);
    final samples = tester.widgetList<Text>(find.text('وزیرمتن')).toList();
    expect(samples, hasLength(4));
    expect(samples.map((text) => text.style?.fontFamily).toSet(), {'Vazirmatn'});
    expect(samples.map((text) => text.style?.fontWeight).toSet(), {
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    });
    expect(tester.takeException(), isNull);
  });
}
