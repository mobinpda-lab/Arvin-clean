import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/automatic_follow_up_background_runner.dart';

void main() {
  test('retired AlarmManager callback is a safe no-op', () async {
    await expectLater(arvinAutomaticFollowUpAlarmCallback(), completes);
  });
}
