import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../backup_service.dart';

/// Versioned, authenticated encryption envelope for canonical Arvin backup bytes.
///
/// This prototype intentionally does not own Task persistence, SAF, cloud upload,
/// or restore mutation. It wraps/unwraps the single canonical backup byte path so
/// those existing foundations can remain unchanged when encryption is wired in.
class ArvinEncryptedBackupEnvelope {
  ArvinEncryptedBackupEnvelope({
    this.memoryKiB = defaultMemoryKiB,
    this.iterations = defaultIterations,
    this.parallelism = defaultParallelism,
  });

  static const String envelopeType = 'arvin_encrypted_backup';
  static const int envelopeFormatVersion = 1;
  static const String kdfName = 'argon2id';
  static const String cipherName = 'aes-256-gcm';

  // OWASP-recommended Argon2id baseline for password hashing/key derivation.
  static const int defaultMemoryKiB = 19 * 1024;
  static const int defaultIterations = 2;
  static const int defaultParallelism = 1;
  static const int hashLength = 32;
  static const int saltLength = 16;

  // Bounds protect restore from attacker-controlled resource-exhaustion values.
  static const int minMemoryKiB = 1024;
  static const int maxMemoryKiB = 64 * 1024;
  static const int minIterations = 1;
  static const int maxIterations = 6;
  static const int minParallelism = 1;
  static const int maxParallelism = 4;

  final int memoryKiB;
  final int iterations;
  final int parallelism;

  AesGcm get _cipher => AesGcm.with256bits();

  List<int> get _aad => utf8.encode(
        '$envelopeType:$envelopeFormatVersion:$kdfName:$cipherName',
      );

  Future<Uint8List> encrypt(
    Uint8List canonicalBackupBytes, {
    required String passphrase,
  }) async {
    _requirePassphrase(passphrase);
    _validateKdfParameters(
      memory: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      derivedHashLength: hashLength,
    );

    final saltKey = SecretKeyData.random(length: saltLength);
    final salt = Uint8List.fromList(saltKey.bytes);
    saltKey.destroy();

    final derivedKey = await _deriveKey(
      passphrase: passphrase,
      salt: salt,
      memory: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
    );

    try {
      final secretBox = await _cipher.encrypt(
        canonicalBackupBytes,
        secretKey: derivedKey,
        aad: _aad,
      );

      final document = <String, dynamic>{
        'type': envelopeType,
        'formatVersion': envelopeFormatVersion,
        'kdf': <String, dynamic>{
          'name': kdfName,
          'salt': base64Encode(salt),
          'memoryKiB': memoryKiB,
          'iterations': iterations,
          'parallelism': parallelism,
          'hashLength': hashLength,
        },
        'cipher': <String, dynamic>{
          'name': cipherName,
          'nonce': base64Encode(secretBox.nonce),
          'cipherText': base64Encode(secretBox.cipherText),
          'mac': base64Encode(secretBox.mac.bytes),
        },
      };

      return Uint8List.fromList(utf8.encode(jsonEncode(document)));
    } finally {
      derivedKey.destroy();
    }
  }

  /// Returns canonical plaintext backup bytes for the existing validation path.
  ///
  /// Legacy plaintext v1 backups pass through unchanged. Encrypted envelopes
  /// require a passphrase and authenticate before any bytes are returned.
  Future<Uint8List> decodeForRestore(
    Uint8List bytes, {
    String? passphrase,
  }) async {
    final decoded = _decodeJsonObject(bytes);

    if (decoded['type'] == ArvinBackupService.backupType) {
      if (decoded['formatVersion'] != ArvinBackupService.backupFormatVersion) {
        throw const FormatException('Unsupported legacy Arvin backup version');
      }
      return Uint8List.fromList(bytes);
    }

    if (decoded['type'] != envelopeType) {
      throw const FormatException('Unsupported Arvin backup envelope');
    }
    if (decoded['formatVersion'] != envelopeFormatVersion) {
      throw const FormatException('Unsupported encrypted Arvin backup version');
    }
    if (passphrase == null) {
      throw const FormatException('Encrypted Arvin backup requires a passphrase');
    }
    _requirePassphrase(passphrase);

    final rawKdf = decoded['kdf'];
    final rawCipher = decoded['cipher'];
    if (rawKdf is! Map || rawCipher is! Map) {
      throw const FormatException('Encrypted Arvin backup metadata is invalid');
    }

    final kdf = Map<String, dynamic>.from(rawKdf);
    final cipher = Map<String, dynamic>.from(rawCipher);
    if (kdf['name'] != kdfName || cipher['name'] != cipherName) {
      throw const FormatException('Unsupported encrypted Arvin backup algorithms');
    }

    final memory = _requireInt(kdf, 'memoryKiB');
    final storedIterations = _requireInt(kdf, 'iterations');
    final storedParallelism = _requireInt(kdf, 'parallelism');
    final storedHashLength = _requireInt(kdf, 'hashLength');
    _validateKdfParameters(
      memory: memory,
      iterations: storedIterations,
      parallelism: storedParallelism,
      derivedHashLength: storedHashLength,
    );

    final salt = _decodeBase64(kdf, 'salt');
    if (salt.length != saltLength) {
      throw const FormatException('Encrypted Arvin backup salt is invalid');
    }

    final nonce = _decodeBase64(cipher, 'nonce');
    final cipherText = _decodeBase64(cipher, 'cipherText');
    final mac = _decodeBase64(cipher, 'mac');
    final algorithm = _cipher;
    if (nonce.length != algorithm.nonceLength ||
        mac.length != algorithm.macAlgorithm.macLength) {
      throw const FormatException('Encrypted Arvin backup cipher metadata is invalid');
    }

    final derivedKey = await _deriveKey(
      passphrase: passphrase,
      salt: salt,
      memory: memory,
      iterations: storedIterations,
      parallelism: storedParallelism,
    );

    try {
      try {
        final clearText = await algorithm.decrypt(
          SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
          secretKey: derivedKey,
          aad: _aad,
        );
        return Uint8List.fromList(clearText);
      } catch (_) {
        throw const FormatException(
          'Encrypted Arvin backup authentication failed',
        );
      }
    } finally {
      derivedKey.destroy();
    }
  }

  Future<SecretKey> _deriveKey({
    required String passphrase,
    required List<int> salt,
    required int memory,
    required int iterations,
    required int parallelism,
  }) {
    return Argon2id(
      memory: memory,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: hashLength,
    ).deriveKeyFromPassword(password: passphrase, nonce: salt);
  }

  static Map<String, dynamic> _decodeJsonObject(Uint8List bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        throw const FormatException('Arvin backup document is not an object');
      }
      return Map<String, dynamic>.from(decoded);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Arvin backup document is invalid');
    }
  }

  static Uint8List _decodeBase64(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Encrypted Arvin backup $key is invalid');
    }
    try {
      return Uint8List.fromList(base64Decode(value));
    } catch (_) {
      throw FormatException('Encrypted Arvin backup $key is invalid');
    }
  }

  static int _requireInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! int) {
      throw FormatException('Encrypted Arvin backup $key is invalid');
    }
    return value;
  }

  static void _requirePassphrase(String passphrase) {
    if (passphrase.trim().isEmpty) {
      throw const FormatException('Arvin backup passphrase must not be empty');
    }
  }

  static void _validateKdfParameters({
    required int memory,
    required int iterations,
    required int parallelism,
    required int derivedHashLength,
  }) {
    if (memory < minMemoryKiB || memory > maxMemoryKiB ||
        iterations < minIterations || iterations > maxIterations ||
        parallelism < minParallelism || parallelism > maxParallelism ||
        derivedHashLength != hashLength) {
      throw const FormatException('Encrypted Arvin backup KDF parameters are invalid');
    }
  }
}
