import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Release signing configuration contract', () {
    late String gradle;

    setUpAll(() {
      gradle = File('android/app/build.gradle.kts').readAsStringSync();
    });

    test('never signs release builds with the debug key', () {
      expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
      expect(gradle, isNot(contains('signingConfig = signingConfigs.getByName("debug")')));
    });

    test('requires complete owner-provided signing inputs for distribution builds', () {
      expect(gradle, contains('arvinReleaseSigningRequired'));
      expect(gradle, contains('ARVIN_RELEASE_KEYSTORE_PATH'));
      expect(gradle, contains('ARVIN_RELEASE_STORE_PASSWORD'));
      expect(gradle, contains('ARVIN_RELEASE_KEY_ALIAS'));
      expect(gradle, contains('ARVIN_RELEASE_KEY_PASSWORD'));
      expect(gradle, contains('Release signing was required'));
      expect(gradle, contains('signingConfigs.getByName("ownerRelease")'));
    });

    test('allows unsigned release validation only when signing is not required', () {
      expect(gradle, contains('Ordinary CI may build an unsigned validation APK'));
      expect(gradle, contains('if (hasCompleteReleaseSigning)'));
    });
  });
}
