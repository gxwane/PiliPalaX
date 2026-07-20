import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('repository agent guidance is discoverable and current', () {
    final guidanceFile = File('AGENTS.md');

    expect(guidanceFile.existsSync(), isTrue);
    expect(File('.agents/AGENTS.md').existsSync(), isFalse);

    final guidance = guidanceFile.readAsStringSync();
    for (final requiredText in <String>[
      'Flutter 3.38.7',
      'Kotlin Gradle Plugin 2.2.20',
      'Gradle 8.14',
      'flutter pub get --enforce-lockfile',
      'flutter test --no-pub',
      'flutter analyze --no-pub --fatal-warnings --no-fatal-infos',
      '人工测试',
      '不要提交 `docs/`',
    ]) {
      expect(
        guidance,
        contains(requiredText),
        reason: 'AGENTS.md must document $requiredText',
      );
    }

    for (final staleText in <String>[
      'Kotlin 版本为 2.0.20',
      'repo.huaweicloud.com/gradle',
      'kotlin.jvm.target.validation.mode=warning',
      'media_kit_libs_android_video\\v1.1.5',
      r'E:\Documents\PiliPalaX',
      r'E:\PubCache',
      '默认直接在当前 `main` 分支',
    ]) {
      expect(
        guidance,
        isNot(contains(staleText)),
        reason: 'AGENTS.md must not retain stale guidance: $staleText',
      );
    }
  });

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
