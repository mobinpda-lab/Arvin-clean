import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Release signing configuration contract', () {
    test('required release signing fails during real Gradle configuration without owner inputs', () {
      final environment = Map<String, String>.from(Platform.environment)
        ..remove('ARVIN_RELEASE_KEYSTORE_PATH')
        ..remove('ARVIN_RELEASE_STORE_PASSWORD')
        ..remove('ARVIN_RELEASE_KEY_ALIAS')
        ..remove('ARVIN_RELEASE_KEY_PASSWORD');

      final result = Process.runSync(
        './gradlew',
        <String>[':app:tasks', '-ParvinReleaseSigningRequired=true'],
        workingDirectory: 'android',
        environment: environment,
        includeParentEnvironment: false,
        runInShell: true,
      );

      expect(result.exitCode, isNot(0), reason: 'Gradle must fail closed when signing is mandatory.');
      expect(
        '${result.stdout}\n${result.stderr}',
        contains('Release signing was required'),
      );
    });

    test('release signing report does not bind Release to the Debug signing config', () {
      final result = Process.runSync(
        './gradlew',
        <String>[':app:signingReport'],
        workingDirectory: 'android',
        runInShell: true,
      );

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      final output = '${result.stdout}\n${result.stderr}';
      final releaseSection = RegExp(
        r'Variant: release([\s\S]*?)(?=Variant:|$)',
      ).firstMatch(output);

      expect(releaseSection, isNotNull, reason: output);
      expect(releaseSection!.group(1), isNot(contains('Config: debug')));
      expect(releaseSection.group(1), isNot(contains('Config: debugSigning')));
    });
  });
}
