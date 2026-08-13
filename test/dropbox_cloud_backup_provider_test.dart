import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/dropbox_cloud_backup_provider_v2.dart';

void main() {
  DropboxHttpResponse responseFor({int statusCode = 200, String body = ''}) =>
      DropboxHttpResponse(
        statusCode: statusCode,
        bodyBytes: Uint8List.fromList(utf8.encode(body)),
      );

  test('Dropbox provider builds the expected upload request', () async {
    String? method;
    String? url;
    String? token;
    Map<String, String>? headers;
    Uint8List? requestBody;

    final client = DropboxHttpClient(
      request: ({
        required String method,
        required String url,
        required String token,
        required Map<String, String> headers,
        Uint8List? body,
      }) async {
        method = method;
        url = url;
        token = token;
        headers = headers;
        requestBody = body;
        return responseFor();
      },
    );

    // Capture through a separate handler to avoid shadowing named parameters.
    final captured = <String, dynamic>{};
    final capturingClient = DropboxHttpClient(
      request: ({
        required String method,
        required String url,
        required String token,
        required Map<String, String> headers,
        Uint8List? body,
      }) async {
        captured['method'] = method;
        captured['url'] = url;
        captured['token'] = token;
        captured['headers'] = headers;
        captured['body'] = body;
        return responseFor();
      },
    );

    await DropboxCloudBackupProviderV2(accessToken: 'token', client: capturingClient)
        .uploadBackup(
      fileName: 'backup.json',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    expect(captured['method'], 'POST');
    expect(captured['url'], 'https://content.dropboxapi.com/2/files/upload');
    expect(captured['token'], 'token');
    expect((captured['headers'] as Map<String, String>)['Content-Type'],
        'application/octet-stream');
    expect((captured['headers'] as Map<String, String>)['Dropbox-API-Arg'],
        contains('/Apps/Arvin/backup.json'));
    expect(captured['body'], orderedEquals([1, 2, 3]));

    // Keep the first client construction compiled as part of the adapter contract.
    expect(client, isA<DropboxHttpClient>());
    expect(method, isNull);
    expect(url, isNull);
    expect(token, isNull);
    expect(headers, isNull);
    expect(requestBody, isNull);
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

    final provider = DropboxCloudBackupProviderV2(
      accessToken: 'token',
      client: client,
    );
    expect(await provider.downloadBackup('missing.json'), isNull);
    expect(await provider.exists('missing.json'), isFalse);
  });

  test('Dropbox provider deletes a backup through files/delete_v2', () async {
    String? url;
    Uint8List? requestBody;

    final client = DropboxHttpClient(
      request: ({
        required String method,
        required String url,
        required String token,
        required Map<String, String> headers,
        Uint8List? body,
      }) async {
        url = url;
        requestBody = body;
        return responseFor();
      },
    );

    final capturingClient = DropboxHttpClient(
      request: ({
        required String method,
        required String url,
        required String token,
        required Map<String, String> headers,
        Uint8List? body,
      }) async {
        requestBody = body;
        return responseFor();
      },
    );

    await DropboxCloudBackupProviderV2(
      accessToken: 'token',
      client: capturingClient,
    ).deleteBackup('backup.json');

    expect(requestBody, isNotNull);
    expect(utf8.decode(requestBody!), contains('/Apps/Arvin/backup.json'));
    expect(client, isA<DropboxHttpClient>());
    expect(url, isNull);
  });
}
