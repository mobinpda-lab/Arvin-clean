import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar actions use the shared bottom navigation', () {
    final source = File('lib/widgets/canonical_calendar_launcher.dart')
        .readAsStringSync();
    final navigation = File('lib/widgets/arvin_primary_navigation.dart')
        .readAsStringSync();

    expect(source, contains('bottomNavigationBar: ArvinPrimaryNavigation('));
    expect(
      source,
      contains('selected: ArvinPrimaryDestination.calendar'),
    );
    expect(navigation, contains("label: 'خانه'"));
    expect(navigation, contains("label: 'تقویم'"));
    expect(navigation, contains("label: 'دفترچه'"));
    expect(navigation, contains("label: 'اقدام بعدی'"));
    expect(navigation, contains("label: 'بیشتر'"));

    expect(source, isNot(contains('FloatingActionButton.extended')));
    expect(source, isNot(contains('Positioned(')));

    expect(source, contains("Text('تقویم دستگاه')"));
    expect(source, contains("Text('خط زمانی')"));
    expect(source, contains("Text('تداخل‌ها')"));
    expect(source, contains('showModalBottomSheet<_CalendarMoreAction>'));
    expect(source, contains('ArvinPrimaryPageShell('));
  });
}
