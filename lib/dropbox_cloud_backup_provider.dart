import 'dart:convert';
import 'dart:typed_data';

import 'cloud_backup_provider.dart';

/// Minimal Dropbox implementation for Arvin cloud backups.
class DropboxCloudBackupProvider implements CloudBackupProvider {
  DropboxCloudBackupProvider({
    required this.accessToken,
    this.rootPath = '/Apps/Arvin',
    DropboxHttpClient? client,
  }) : _client = client ?? DropboxHttpClient();

  final String accessToken;
  final String rootPath;
  final DropboxHttpClient _client;

  String _path(String fileName) {
    final cleanRoot = rootPath.endsWith('/')
        ? rootPath.substring(0, rootPath.length - 1)
        : rootPath;
    final cleanName = fileName.startsWith('/') ? fileName.substring(1) : fileName;
    return '$cleanRoot/$cleanName';
  }

  @override
  Future<void> uploadBackup({
    required String fileName,
    required Uint8List bytes,
  }) => _client.upload(accessToken, _path(fileName), bytes);

  @override
  Future<Uint8List?> downloadBackup(String fileName) async {
    try {
      return await _client.download(accessToken, _path(fileName));
    } on DropboxApiException catch (error) {
      if (error.isNotFound) return null;
      rethrow;
    }
  }

  @override
  Future<void> deleteBackup(String fileName) =>
      _client.delete(accessToken, _path(fileName));

  @override
  Future<bool> exists(String fileName) async {
    try {
      await _client.metadata(accessToken, _path(fileName));
      return true;
    } on DropboxApiException catch (error) {
      if (error.isNotFound) return false;
      rethrow;
    }
  }
}

class DropboxHttpClient {
  static const _apiBase = 'https://api.dropboxapi.com/2';
  static const _contentBase = 'https://content.dropboxapi.com/2';

  Future<void> upload(String token, String path, Uint8List bytes) async {
    final response = await _request(
      method: 'POST',
      url: '$_contentBase/files/upload',
      token: token,
      headers: {
        'Content-Type': 'application/octet-stream',
        'Dropbox-API-Arg': jsonEncode({
          'path': path,
          'mode': 'overwrite',
          'autorename': false,
          'mute': true,
          'strict_conflict': false,
        }),
      },
      body: bytes,
    );
    _check(response);
  }

  Future<Uint8List> download(String token, String path) async {
    final response = await _request(
      method: 'POST',
      url: '$_contentBase/files/download',
      token: token,
      headers: {
        'Content-Type': 'application/octet-stream',
        'Dropbox-API-Arg': jsonEncode({'path': path}),
      },
    );
    _check(response);
    return Uint8List.fromList(response.bodyBytes);
  }

  Future<void> delete(String token, String path) async {
    final response = await _request(
      method: 'POST',
      url: '$_apiBase/files/delete_v2',
      token: token,
      headers: {'Content-Type': 'application/json'},
      body: Uint8List.fromList(utf8.encode(jsonEncode({'path': path}))),
    );
    _check(response);
  }

  Future<void> metadata(String token, String path) async {
    final response = await _request(
      method: 'POST',
      url: '$_apiBase/files/get_metadata',
      token: token,
      headers: {'Content-Type': 'application/json'},
      body: Uint8List.fromList(utf8.encode(jsonEncode({'path': path}))),
    );
    _check(response);
  }

  Future<DropboxHttpResponse> _request({
    required String method,
    required String url,
    required String token,
    Map<String, String> headers = const {},
    Uint8List? body,
  }) => _defaultRequest(method, url, token, headers, body);

  Future<DropboxHttpResponse> _defaultRequest(
    String method,
    String url,
    String token,
    Map<String, String> headers,
    Uint8List? body,
  ) async {
    throw UnsupportedError(
      'DropboxHttpClient requires a platform HTTP adapter',
    );
  }

  void _check(DropboxHttpResponse response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DropboxApiException(response.statusCode, response.bodyText);
    }
  }
}

class DropboxHttpResponse {
  const DropboxHttpResponse({
    required this.statusCode,
    required this.bodyBytes,
  });

  final int statusCode;
  final Uint8List bodyBytes;

  String get bodyText => utf8.decode(bodyBytes, allowMalformed: true);
}

class DropboxApiException implements Exception {
  const DropboxApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  bool get isNotFound => statusCode == 409 && message.contains('not_found');

  @override
  String toString() => 'DropboxApiException($statusCode): $message';
}
