import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical Calendar launcher owns the system export action', () {
    final source = File(
      'lib/widgets/canonical_calendar_launcher.dart',
    ).readAsStringSync();

    expect(source, contains("import '../services/system_calendar_bridge.dart';"));
    expect(source, contains('.where(SystemCalendarBridge.isEligible)'));
    expect(source, contains('SystemCalendarBridge().insert(selected)'));
    expect(source, contains("heroTag: 'arvin-system-calendar-export'"));
    expect(source, contains("label: const Text('تقویم دستگاه')"));
  });
}
