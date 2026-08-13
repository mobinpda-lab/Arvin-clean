import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/dropbox_cloud_backup_provider.dart';

void main() {
  test('Dropbox provider builds the expected upload request', () async {
    String? method;
    String? url;
    String? token;
    Map<String, String>? headers;
    Uint8List? body;

    final client = DropboxHttpClient(
      request: ({required m, required u, required t, required h, b}) async {
        method = m;
        url = u;
        token = t;
        headers = h;
        body = b;
        return const DropboxHttpResponse(statusCode: 200);
      },
    );

    await DropboxCloudBackupProvider(
      accessToken: 'token',
      client: client,
    ).uploadBackup(
      fileName: 'backup.json',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    expect(method, 'POST');
    expect(url, 'https://content.dropboxapi.com/2/files/upload');
    expect(token, 'token');
    expect(headers!['Content-Type'], 'application/octet-stream');
    expect(headers!['Dropbox-API-Arg'], contains('/Apps/Arvin/backup.json'));
    expect(body, orderedEquals([1, 2, 3]));
  });

  test('Dropbox provider treats not-found download as null', () async {
    final client = DropboxHttpClient(
      request: ({required m, required u, required t, required h, b}) async {
        return DropboxHttpResponse(
          statusCode: 409,
          bodyBytes: Uint8List.fromList(
            'error_summary: path/not_found/'.codeUnits,
          ),
        );
      },
    );

    final provider = DropboxCloudBackupProvider(
      accessToken: 'token',
      client: client,
    );

    expect(await provider.downloadBackup('missing.json'), isNull);
    expect(await provider.exists('missing.json'), isFalse);
  });

  test('Dropbox provider deletes a backup through files/delete_v2', () async {
    String? url;
    String? body;

    final client = DropboxHttpClient(
      request: ({required m, required u, required t, required h, b}) async {
        url = u;
        body = b == null ? null : String.fromCharCodes(b);
        return const DropboxHttpResponse(statusCode: 200);
      },
    );

    await DropboxCloudBackupProvider(
      accessToken: 'token',
      client: client,
    ).deleteBackup('backup.json');

    expect(url, 'https://api.dropboxapi.com/2/files/delete_v2');
    expect(body, contains('/Apps/Arvin/backup.json'));
  });
}
