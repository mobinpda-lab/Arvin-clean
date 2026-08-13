import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'cloud_backup_provider.dart';

class DropboxCloudBackupProviderV2 implements CloudBackupProvider {
  DropboxCloudBackupProviderV2({required this.accessToken, this.rootPath = '/Apps/Arvin', DropboxHttpClient? client})
      : _client = client ?? DropboxHttpClient();

  final String accessToken;
  final String rootPath;
  final DropboxHttpClient _client;

  String _path(String fileName) => '${rootPath.replaceFirst(RegExp(r'/$'), '')}/${fileName.replaceFirst(RegExp(r'^/'), '')}';

  @override
  Future<void> uploadBackup({required String fileName, required Uint8List bytes}) => _client.upload(accessToken, _path(fileName), bytes);

  @override
  Future<Uint8List?> downloadBackup(String fileName) async {
    try { return await _client.download(accessToken, _path(fileName)); }
    on DropboxApiException catch (e) { if (e.isNotFound) return null; rethrow; }
  }

  @override
  Future<void> deleteBackup(String fileName) => _client.delete(accessToken, _path(fileName));

  @override
  Future<bool> exists(String fileName) async {
    try { await _client.metadata(accessToken, _path(fileName)); return true; }
    on DropboxApiException catch (e) { if (e.isNotFound) return false; rethrow; }
  }
}

typedef DropboxRequestHandler = Future<DropboxHttpResponse> Function({required String method, required String url, required String token, required Map<String, String> headers, Uint8List? body});

class DropboxHttpClient {
  DropboxHttpClient({DropboxRequestHandler? request}) : _request = request ?? _defaultRequest;
  static const _api = 'https://api.dropboxapi.com/2';
  static const _content = 'https://content.dropboxapi.com/2';
  final DropboxRequestHandler _request;

  Future<void> upload(String token, String path, Uint8List bytes) async => _check(await _request(method: 'POST', url: '$_content/files/upload', token: token, headers: {'Content-Type': 'application/octet-stream', 'Dropbox-API-Arg': jsonEncode({'path': path, 'mode': 'overwrite', 'autorename': false, 'mute': true, 'strict_conflict': false})}, body: bytes));
  Future<Uint8List> download(String token, String path) async { final r = await _request(method: 'POST', url: '$_content/files/download', token: token, headers: {'Content-Type': 'application/octet-stream', 'Dropbox-API-Arg': jsonEncode({'path': path})}); _check(r); return r.bodyBytes; }
  Future<void> delete(String token, String path) async => _check(await _request(method: 'POST', url: '$_api/files/delete_v2', token: token, headers: {'Content-Type': 'application/json'}, body: Uint8List.fromList(utf8.encode(jsonEncode({'path': path})))));
  Future<void> metadata(String token, String path) async => _check(await _request(method: 'POST', url: '$_api/files/get_metadata', token: token, headers: {'Content-Type': 'application/json'}, body: Uint8List.fromList(utf8.encode(jsonEncode({'path': path})))));

  static Future<DropboxHttpResponse> _defaultRequest({required String method, required String url, required String token, required Map<String, String> headers, Uint8List? body}) async {
    final client = HttpClient();
    try { final request = await client.openUrl(method, Uri.parse(url)); request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token'); headers.forEach(request.headers.set); if (body != null) request.add(body); final response = await request.close(); final bytes = await response.fold<List<int>>(<int>[], (a, b) => a..addAll(b)); return DropboxHttpResponse(statusCode: response.statusCode, bodyBytes: Uint8List.fromList(bytes)); }
    finally { client.close(force: true); }
  }
  void _check(DropboxHttpResponse r) { if (r.statusCode < 200 || r.statusCode >= 300) throw DropboxApiException(r.statusCode, r.bodyText); }
}

class DropboxHttpResponse { const DropboxHttpResponse({required this.statusCode, this.bodyBytes = const <int>[]}); final int statusCode; final Uint8List bodyBytes; String get bodyText => utf8.decode(bodyBytes, allowMalformed: true); }
class DropboxApiException implements Exception { const DropboxApiException(this.statusCode, this.message); final int statusCode; final String message; bool get isNotFound => statusCode == 409 && message.contains('not_found'); @override String toString() => 'DropboxApiException($statusCode): $message'; }
