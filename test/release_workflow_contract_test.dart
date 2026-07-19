import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validation follows the direct-main development workflow', () {
    final validation = File(
      '.github/workflows/upgrade-validation.yml',
    ).readAsStringSync();

    expect(validation, contains('branches: [main]'));
    expect(validation, contains('workflow_dispatch:'));
    expect(validation, isNot(contains('pull_request:')));
  });

  test('release workflow validates and publishes changelog notes', () {
    final release = File('.github/workflows/release.yml').readAsStringSync();

    expect(release, contains('tool/extract_changelog.dart'));
    expect(release, contains('bodyFile:'));
    expect(release, contains('generateReleaseNotes: false'));
    expect(release, contains('prerelease:'));
    expect(release, isNot(contains('generateReleaseNotes: true')));

    for (final artifact in <String>[
      'PiliPalaX-android-arm64-v8a-v',
      'PiliPalaX-android-armeabi-v7a-v',
      'PiliPalaX-android-x86_64-v',
      'PiliPalaX-android-universal-v',
      'PiliPalaX-ios-unsigned-v',
    ]) {
      expect(release, contains(artifact), reason: '$artifact must be emitted');
    }
  });

  test('obsolete alpha distribution workflow is removed', () {
    expect(File('.github/workflows/alpha.yml').existsSync(), isFalse);
  });
}
