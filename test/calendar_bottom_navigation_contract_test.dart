import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar actions use bottom navigation instead of floating overlays', () {
    final source = File('lib/widgets/canonical_calendar_launcher.dart')
        .readAsStringSync();

    expect(source, contains('bottomNavigationBar: NavigationBar('));
    expect(source, contains("label: 'خانه'"));
    expect(source, contains("label: 'تقویم'"));
    expect(source, contains("label: 'دفترچه'"));
    expect(source, contains("label: 'اقدام بعدی'"));
    expect(source, contains("label: 'بیشتر'"));

    expect(source, isNot(contains('FloatingActionButton.extended')));
    expect(source, isNot(contains('Positioned(')));

    expect(source, contains("Text('تقویم دستگاه')"));
    expect(source, contains("Text('خط زمانی')"));
    expect(source, contains("Text('تداخل‌ها')"));
    expect(source, contains('showModalBottomSheet<_CalendarMoreAction>'));
  });
}
