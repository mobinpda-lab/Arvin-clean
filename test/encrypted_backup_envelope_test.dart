import 'dart:convert';
import 'dart:typed_data';

import 'package:arvin/backup_service.dart';
import 'package:arvin/services/encrypted_backup_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ArvinEncryptedBackupEnvelope fastEnvelope() {
    return ArvinEncryptedBackupEnvelope(
      memoryKiB: ArvinEncryptedBackupEnvelope.minMemoryKiB,
      iterations: 1,
      parallelism: 1,
    );
  }

  Uint8List canonicalBackup() {
    return ArvinBackupService.encodeBackupDocument({
      'tasks': [
        {'id': 'task-1', 'title': 'پیگیری قرارداد'},
      ],
      'settings': {
        'themeMode': 'dark',
        'usePersianDate': true,
      },
    });
  }

  test('encrypted envelope round-trips canonical backup bytes', () async {
    final envelope = fastEnvelope();
    final original = canonicalBackup();

    final encrypted = await envelope.encrypt(
      original,
      passphrase: 'correct horse battery staple',
    );
    final document = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;

    expect(document['type'], ArvinEncryptedBackupEnvelope.envelopeType);
    expect(
      document['formatVersion'],
      ArvinEncryptedBackupEnvelope.envelopeFormatVersion,
    );
    expect(document['kdf']['name'], ArvinEncryptedBackupEnvelope.kdfName);
    expect(document['cipher']['name'], ArvinEncryptedBackupEnvelope.cipherName);
    expect(utf8.decode(encrypted), isNot(contains('پیگیری قرارداد')));

    final restored = await envelope.decodeForRestore(
      encrypted,
      passphrase: 'correct horse battery staple',
    );

    expect(restored, orderedEquals(original));
    expect(
      ArvinBackupService.validateBackupDocument(
        jsonDecode(utf8.decode(restored)),
      )['tasks'],
      isA<List>(),
    );
  });

  test('passphrase is never serialized into the encrypted envelope', () async {
    final envelope = fastEnvelope();
    const passphrase = 'never-store-this-passphrase';

    final encrypted = await envelope.encrypt(
      canonicalBackup(),
      passphrase: passphrase,
    );
    final text = utf8.decode(encrypted);

    expect(text, isNot(contains(passphrase)));
    expect(text.toLowerCase(), isNot(contains('passphrase')));
    expect(text.toLowerCase(), isNot(contains('password')));
  });

  test('same backup and passphrase produce randomized envelopes', () async {
    final envelope = fastEnvelope();
    final original = canonicalBackup();

    final first = await envelope.encrypt(
      original,
      passphrase: 'same-passphrase',
    );
    final second = await envelope.encrypt(
      original,
      passphrase: 'same-passphrase',
    );

    expect(first, isNot(orderedEquals(second)));
  });

  test('legacy plaintext v1 backup passes through unchanged', () async {
    final envelope = fastEnvelope();
    final legacy = canonicalBackup();

    final restored = await envelope.decodeForRestore(legacy);

    expect(restored, orderedEquals(legacy));
  });

  test('wrong passphrase fails before plaintext is returned', () async {
    final envelope = fastEnvelope();
    final encrypted = await envelope.encrypt(
      canonicalBackup(),
      passphrase: 'right-passphrase',
    );

    expect(
      () => envelope.decodeForRestore(
        encrypted,
        passphrase: 'wrong-passphrase',
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('tampered ciphertext is rejected by authenticated decryption', () async {
    final envelope = fastEnvelope();
    final encrypted = await envelope.encrypt(
      canonicalBackup(),
      passphrase: 'tamper-test-passphrase',
    );
    final document = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(encrypted)) as Map,
    );
    final cipher = Map<String, dynamic>.from(document['cipher'] as Map);
    final cipherText = base64Decode(cipher['cipherText'] as String);
    cipherText[0] ^= 0x01;
    cipher['cipherText'] = base64Encode(cipherText);
    document['cipher'] = cipher;
    final tampered = Uint8List.fromList(utf8.encode(jsonEncode(document)));

    expect(
      () => envelope.decodeForRestore(
        tampered,
        passphrase: 'tamper-test-passphrase',
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('attacker-controlled excessive KDF parameters are rejected', () async {
    final envelope = fastEnvelope();
    final encrypted = await envelope.encrypt(
      canonicalBackup(),
      passphrase: 'resource-bound-passphrase',
    );
    final document = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(encrypted)) as Map,
    );
    final kdf = Map<String, dynamic>.from(document['kdf'] as Map);
    kdf['memoryKiB'] = ArvinEncryptedBackupEnvelope.maxMemoryKiB + 1;
    document['kdf'] = kdf;
    final malicious = Uint8List.fromList(utf8.encode(jsonEncode(document)));

    expect(
      () => envelope.decodeForRestore(
        malicious,
        passphrase: 'resource-bound-passphrase',
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
