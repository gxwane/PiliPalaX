import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = 'https://github.com/gxwane/PiliPalaX';
  const chineseDescription = '使用 Flutter 开发的哔哩哔哩非官方第三方客户端';
  const aiMaintenanceStatement =
      '本项目采用人机协作方式持续维护。部分代码、问题分析、测试和文档由 OpenAI Codex 协助完成，相关变更在发布前由人工测试。';
  const unofficialStatement =
      'PiliPalaX 是非官方第三方客户端，与哔哩哔哩及其关联主体无隶属、授权或合作关系。本项目仅供学习与技术交流，使用者应遵守当地法律法规及相关平台规则。';

  test('public project copy uses the current repository and disclosures', () {
    final readme = File('README.md').readAsStringSync();
    final aboutPage = File('lib/pages/about/index.dart').readAsStringSync();
    final constants = File('lib/common/constants.dart').readAsStringSync();

    expect(readme, contains(repository));
    expect(readme, contains(chineseDescription));
    expect(readme, contains(aiMaintenanceStatement));
    expect(readme, contains(unofficialStatement));
    expect(aboutPage, contains(aiMaintenanceStatement));
    expect(constants, contains(repository));

    for (final staleText in <String>[
      'github.com/orz12/pilipala',
      't.me/',
      '392176105',
      '123pan',
      '24小时内删除',
    ]) {
      expect(
        '$readme\n$aboutPage\n$constants',
        isNot(contains(staleText)),
        reason: 'public project copy must not contain $staleText',
      );
    }
  });

  test('package and store metadata describe the same application', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final zhShort = File(
      'fastlane/metadata/android/zh-CN/short_description.txt',
    ).readAsStringSync();
    final zhFull = File(
      'fastlane/metadata/android/zh-CN/full_description.txt',
    ).readAsStringSync();
    final enShort = File(
      'fastlane/metadata/android/en-US/short_description.txt',
    ).readAsStringSync();
    final enFull = File(
      'fastlane/metadata/android/en-US/full_description.txt',
    ).readAsStringSync();

    expect(pubspec, contains('description: $chineseDescription。'));
    expect(zhShort.trim(), chineseDescription);
    expect(zhFull, contains(chineseDescription));
    expect(zhFull, contains('OpenAI Codex'));
    expect(enShort.trim(), 'An unofficial Bilibili client built with Flutter');
    expect(enFull, contains('unofficial third-party Bilibili client'));
    expect(enFull, contains('OpenAI Codex'));
  });

  test('mobile application identifiers remain upgrade-compatible', () {
    final android = File('android/app/build.gradle').readAsStringSync();
    final ios = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

    expect(android, contains("namespace = 'com.orz12.PiliPalaX'"));
    expect(android, contains('applicationId = "com.orz12.PiliPalaX"'));
    expect(ios, contains('PRODUCT_BUNDLE_IDENTIFIER = com.orz12.PiliPalaX;'));
  });
}
