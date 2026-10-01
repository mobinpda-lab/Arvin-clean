import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/services/startup_permission_service.dart';

void main() {
  test('startup requests notification and calendar permissions once', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    var notifications = 0;
    var calendar = 0;

    final service = StartupPermissionService(
      preferences: preferences,
      notificationPermissionRequester: () async => notifications++,
      calendarPermissionRequester: () async {
        calendar++;
        return true;
      },
    );

    await service.requestOnStartup();
    await service.requestOnStartup();

    expect(notifications, 1);
    expect(calendar, 1);
    expect(
      preferences.getBool('startup_permissions_prompted_v1'),
      isTrue,
    );
  });

  test('denied startup permission does not create a repeated prompt loop', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    var attempts = 0;

    final service = StartupPermissionService(
      preferences: preferences,
      notificationPermissionRequester: () async => attempts++,
      calendarPermissionRequester: () async {
        attempts++;
        return false;
      },
    );

    await service.requestOnStartup();
    await service.requestOnStartup();

    expect(attempts, 2);
    expect(
      preferences.getBool('startup_permissions_prompted_v1'),
      isTrue,
    );
  });
}
