import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/dropbox_cloud_backup_provider.dart';

void main() {
  DropboxHttpResponse responseFor({int statusCode = 200, String body = ''}) =>
      DropboxHttpResponse(
        statusCode: statusCode,
        bodyBytes: Uint8List.fromList(body.codeUnits),
      );

  test('Dropbox provider builds the expected upload request', () async {
    String? method;
    String? url;
    String? token;
    Map<String, String>? headers;
    Uint8List? body;

    final client = DropboxHttpClient(
      request: ({
        required String method: requestMethod,
        required String url: requestUrl,
        required String token: requestToken,
        required Map<String, String> headers: requestHeaders,
        Uint8List? body: requestBody,
      }) async {
        method = requestMethod;
        url = requestUrl;
        token = requestToken;
        headers = requestHeaders;
        body = requestBody;
        return responseFor();
      },
    );

    await DropboxCloudBackupProvider(accessToken: 'token', client: client)
        .uploadBackup(fileName: 'backup.json', bytes: Uint8List.fromList([1, 2, 3]));

    expect(method, 'POST');
    expect(url, 'https://content.dropboxapi.com/2/files/upload');
    expect(token, 'token');
    expect(headers!['Content-Type'], 'application/octet-stream');
    expect(headers!['Dropbox-API-Arg'], contains('/Apps/Arvin/backup.json'));
    expect(body, orderedEquals([1, 2, 3]));
  });

  test('Dropbox provider treats not-found download as null', () async {
    final client = DropboxHttpClient(
      request: ({
        required String method,
        required String url,
        required String token,
        required Map<String, String> headers,
        Uint8List? body,
      }) async => responseFor(
        statusCode: 409,
        body: 'error_summary: path/not_found/',
      ),
    );

    final provider = DropboxCloudBackupProvider(accessToken: 'token', client: client);

    expect(await provider.downloadBackup('missing.json'), isNull);
    expect(await provider.exists('missing.json'), isFalse);
  });

  test('Dropbox provider deletes a backup through files/delete_v2', () async {
    String? url;
    String? body;

    final client = DropboxHttpClient(
      request: ({
        required String method,
        required String url: requestUrl,
        required String token,
        required Map<String, String> headers,
        Uint8List? body: requestBody,
      }) async {
        url = requestUrl;
        body = requestBody == null ? null : String.fromCharCodes(requestBody);
        return responseFor();
      },
    );

    await DropboxCloudBackupProvider(accessToken: 'token', client: client)
        .deleteBackup('backup.json');

    expect(url, 'https://api.dropboxapi.com/2/files/delete_v2');
    expect(body, contains('/Apps/Arvin/backup.json'));
  });
}
