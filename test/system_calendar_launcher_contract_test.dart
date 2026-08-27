import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical Calendar launcher owns the system export action', () {
    final source = File(
      'lib/widgets/canonical_calendar_launcher.dart',
    ).readAsStringSync();
    final navigation = File(
      'lib/widgets/arvin_primary_navigation.dart',
    ).readAsStringSync();

    expect(source, contains("import '../services/system_calendar_bridge.dart';"));
    expect(source, contains('.where(SystemCalendarBridge.isEligible)'));
    expect(source, contains('SystemCalendarBridge().insert(selected)'));
    expect(source, contains("title: const Text('تقویم دستگاه')"));
    expect(source, contains('.pop(_CalendarMoreAction.systemCalendar)'));
    expect(source, contains('await _exportToSystemCalendar(context);'));
    expect(source, contains('ArvinPrimaryNavigation('));
    expect(navigation, contains("label: 'بیشتر'"));
    expect(source, isNot(contains("heroTag: 'arvin-system-calendar-export'")));
  });
}
