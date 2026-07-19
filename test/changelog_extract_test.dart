import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/extract_changelog.dart';

void main() {
  const sample = '''
# 更新日志

## [Unreleased]

### 变更

- 尚未发布。

## [1.3.0] - 2026-08-01

### 新增

- 稳定版内容。

## [1.3.0-beta.1] - 2026-07-25

### 修复

- 预发布内容。

[Unreleased]: https://example.com
''';

  test('extracts one release section and accepts a v-prefixed tag', () {
    expect(extractChangelogSection(sample, 'v1.3.0'), '''### 新增

- 稳定版内容。''');
  });

  test('extracts public prerelease sections independently', () {
    expect(extractChangelogSection(sample, '1.3.0-beta.1'), '''### 修复

- 预发布内容。''');
  });

  test('rejects missing or empty release sections', () {
    expect(
      () => extractChangelogSection(sample, '1.2.0'),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => extractChangelogSection('## [1.2.0]\n\n## [1.1.0]', '1.2.0'),
      throwsA(isA<FormatException>()),
    );
  });

  test('repository changelog contains every existing public tag', () {
    final changelog = File('CHANGELOG.md').readAsStringSync();
    for (final tag in <String>[
      'v1.1.1',
      'v1.1.2',
      'v1.1.3',
      'v1.1.4',
      'v1.1.5',
      'v1.2.0',
    ]) {
      expect(
        extractChangelogSection(changelog, tag),
        isNotEmpty,
        reason: '$tag must have release notes',
      );
    }
  });
}
