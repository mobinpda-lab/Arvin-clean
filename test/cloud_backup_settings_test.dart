import 'package:arvin/cloud_backup_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requires a non-empty access token to be configured', () {
    expect(const CloudBackupSettings(accessToken: '').isConfigured, isFalse);
    expect(const CloudBackupSettings(accessToken: '   ').isConfigured, isFalse);
    expect(const CloudBackupSettings(accessToken: 'token').isConfigured, isTrue);
  });

  test('defaults to the Arvin Dropbox app path', () {
    expect(
      const CloudBackupSettings(accessToken: 'token').rootPath,
      '/Apps/Arvin',
    );
  });

  test('copyWith preserves unspecified settings', () {
    const settings = CloudBackupSettings(
      accessToken: 'token',
      rootPath: '/Apps/Custom',
    );
    final updated = settings.copyWith(accessToken: 'new-token');
    expect(updated.accessToken, 'new-token');
    expect(updated.rootPath, '/Apps/Custom');
  });
}
