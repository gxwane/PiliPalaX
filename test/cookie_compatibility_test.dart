import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory cookieDirectory;

  setUp(() async {
    cookieDirectory = await Directory.systemTemp.createTemp(
      'pilipalax-cookie-',
    );
  });

  tearDown(() async {
    if (await cookieDirectory.exists()) {
      await cookieDirectory.delete(recursive: true);
    }
  });

  test('persisted Bilibili cookies survive a cookie jar restart', () async {
    final uri = Uri.parse('https://api.bilibili.com/x/web-interface/nav');
    final originalJar = PersistCookieJar(
      storage: FileStorage(cookieDirectory.path),
    );
    final sessionCookie = Cookie('SESSDATA', 'fixture-session')
      ..domain = '.bilibili.com'
      ..path = '/'
      ..expires = DateTime.utc(2030);

    await originalJar.saveFromResponse(uri, <Cookie>[sessionCookie]);

    final reopenedJar = PersistCookieJar(
      storage: FileStorage(cookieDirectory.path),
    );
    final restoredCookies = await reopenedJar.loadForRequest(uri);

    expect(
      restoredCookies.map((cookie) => '${cookie.name}=${cookie.value}'),
      contains('SESSDATA=fixture-session'),
    );
  });
}
