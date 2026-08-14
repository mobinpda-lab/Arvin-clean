import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/backup_manager.dart';
import 'package:arvin/cloud_backup_provider.dart';

class _FakeCloudProvider implements CloudBackupProvider {
  @override
  Future<void> uploadBackup({required String fileName, required Uint8List bytes}) async {}

  @override
  Future<Uint8List?> downloadBackup(String fileName) async => null;

  @override
  Future<void> deleteBackup(String fileName) async {}

  @override
  Future<bool> exists(String fileName) async => false;
}

void main() {
  test('passes a cloud provider into the default backup service', () {
    final provider = _FakeCloudProvider();
    final manager = ArvinBackupManager(cloudProvider: provider);

    expect(manager.service.cloudProvider, same(provider));
  });

  test('an explicitly supplied service remains authoritative', () {
    final provider = _FakeCloudProvider();
    final service = ArvinBackupManager(cloudProvider: provider).service;
    final manager = ArvinBackupManager(service: service);

    expect(manager.service, same(service));
    expect(manager.service.cloudProvider, same(provider));
  });
}
