import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar actions use the shared bottom navigation', () {
    final source = File('lib/widgets/canonical_calendar_launcher.dart')
        .readAsStringSync();
    final calendar = File('lib/calendar_page.dart').readAsStringSync();
    final navigation = File('lib/widgets/arvin_primary_navigation.dart')
        .readAsStringSync();

    expect(source, contains('bottomNavigationBar: ArvinPrimaryNavigation('));
    expect(
      source,
      contains('selected: ArvinPrimaryDestination.calendar'),
    );
    expect(navigation, contains("'امروز'"));
    expect(navigation, contains("'تقویم'"));
    expect(navigation, contains("'دفترچه'"));
    expect(navigation, contains("'گزارش‌ها'"));
    expect(navigation.indexOf("'دفترچه'") < navigation.indexOf("'گزارش‌ها'"), isTrue);
    expect(navigation.indexOf("'گزارش‌ها'") < navigation.indexOf("'بیشتر'"), isTrue);
    expect(navigation, isNot(contains("'اقدام بعدی'")));
    expect(navigation, contains("'بیشتر'"));

    expect(source, isNot(contains('FloatingActionButton.extended')));
    expect(source, isNot(contains('Positioned(')));

    expect(source, isNot(contains("Text('تقویم دستگاه')")));
    expect(source, isNot(contains('_exportToSystemCalendar')));
    expect(source, isNot(contains('_retryCalendarSync')));
    expect(source, contains("Text('خط زمانی')"));
    expect(source, contains("Text('تداخل‌ها')"));
    expect(calendar, contains('case CalendarSwipeAction.sync:'));
    expect(File('lib/task_detail_page.dart').readAsStringSync(), contains('task-detail-send-device-calendar'));
    expect(source, contains('showModalBottomSheet<_CalendarMoreAction>'));
    expect(source, contains('ArvinPrimaryPageShell('));
  });
}
