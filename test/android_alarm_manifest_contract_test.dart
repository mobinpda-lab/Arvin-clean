import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android alarm manifest supports reboot rescheduling', () async {
    final manifest = await File('android/app/src/main/AndroidManifest.xml')
        .readAsString();

    expect(
      manifest,
      contains('android.permission.SCHEDULE_EXACT_ALARM'),
    );
    expect(
      manifest,
      contains('android.permission.RECEIVE_BOOT_COMPLETED'),
    );
    expect(
      manifest,
      contains(
        'dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver',
      ),
    );

    final receiverStart = manifest.indexOf(
      'dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver',
    );
    final receiverEnd = manifest.indexOf('</receiver>', receiverStart);
    final receiverBlock = manifest.substring(receiverStart, receiverEnd);

    expect(receiverBlock, contains('android:enabled="true"'));
    expect(receiverBlock, contains('android.intent.action.BOOT_COMPLETED'));
  });
}
