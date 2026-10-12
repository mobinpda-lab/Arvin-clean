import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/dropbox_cloud_backup_provider.dart';

void main() {
  DropboxHttpResponse responseFor({int statusCode = 200, String body = ''}) =>
      DropboxHttpResponse(
        statusCode: statusCode,
        bodyBytes: Uint8List.fromList(utf8.encode(body)),
      );

  test('Dropbox provider builds the expected upload request', () async {
    final captured = <String, dynamic>{};
    final client = DropboxHttpClient(
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

    await DropboxCloudBackupProvider(accessToken: 'token', client: client)
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

    final provider = DropboxCloudBackupProvider(
      accessToken: 'token',
      client: client,
    );
    expect(await provider.downloadBackup('missing.json'), isNull);
    expect(await provider.exists('missing.json'), isFalse);
  });

  test('Dropbox provider deletes a backup through files/delete_v2', () async {
    final captured = <String, dynamic>{};
    final client = DropboxHttpClient(
      request: ({
        required String method,
        required String url,
        required String token,
        required Map<String, String> headers,
        Uint8List? body,
      }) async {
        captured['url'] = url;
        captured['body'] = body;
        return responseFor();
      },
    );

    await DropboxCloudBackupProvider(
      accessToken: 'token',
      client: client,
    ).deleteBackup('backup.json');

    expect(captured['url'], 'https://api.dropboxapi.com/2/files/delete_v2');
    expect(captured['body'], isNotNull);
    expect(utf8.decode(captured['body'] as Uint8List),
        contains('/Apps/Arvin/backup.json'));
  });
}
