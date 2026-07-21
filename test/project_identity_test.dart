import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = 'https://github.com/gxwane/PiliPalaZ';
  const chineseDescription = '使用 Flutter 开发的哔哩哔哩非官方第三方客户端';
  const aiMaintenanceStatement =
      '本项目采用人机协作方式持续维护。部分代码、问题分析、测试和文档由 OpenAI Codex 协助完成，相关变更在发布前由人工测试。';
  const unofficialStatement =
      'PiliPalaZ 是非官方第三方客户端，与哔哩哔哩及其关联主体无隶属、授权或合作关系。本项目仅供学习与技术交流，使用者应遵守当地法律法规及相关平台规则。';

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
    expect(readme, contains('orz12/PiliPalaX'));

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

    expect(pubspec, contains('name: pilipalaz'));
    expect(pubspec, contains('description: $chineseDescription。'));
    expect(zhShort.trim(), chineseDescription);
    expect(zhFull, contains(chineseDescription));
    expect(zhFull, contains('OpenAI Codex'));
    expect(enShort.trim(), 'An unofficial Bilibili client built with Flutter');
    expect(enFull, contains('unofficial third-party Bilibili client'));
    expect(enFull, contains('OpenAI Codex'));
  });

  test('mobile application identifiers use the new independent identity', () {
    final android = File('android/app/build.gradle').readAsStringSync();
    final ios = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

    expect(android, contains("namespace = 'io.github.gxwane.pilipalaz'"));
    expect(android, contains('applicationId = "io.github.gxwane.pilipalaz"'));
    expect(
      ios,
      contains('PRODUCT_BUNDLE_IDENTIFIER = io.github.gxwane.pilipalaz;'),
    );
    expect(
      File(
        'android/app/src/main/kotlin/io/github/gxwane/pilipalaz/MainActivity.kt',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        'android/app/src/main/kotlin/com/orz12/PiliPalaX/MainActivity.kt',
      ).existsSync(),
      isFalse,
    );
  });

  test('platform scaffolds use the PiliPalaZ brand', () {
    for (final path in <String>[
      'android/app/src/main/AndroidManifest.xml',
      'ios/Runner/Info.plist',
      'linux/my_application.cc',
      'macos/Runner/Configs/AppInfo.xcconfig',
      'web/manifest.json',
      'windows/runner/Runner.rc',
    ]) {
      expect(
        File(path).readAsStringSync(),
        contains('PiliPalaZ'),
        reason: '$path must expose the current application brand',
      );
    }
  });

  test('Dart sources import the renamed root package', () {
    const oldImportPrefix = 'package:PiliPala' 'X/';
    final dartFiles = <File>[
      ...Directory('lib').listSync(recursive: true).whereType<File>(),
      ...Directory('test').listSync(recursive: true).whereType<File>(),
    ].where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains(oldImportPrefix)),
        reason: '${file.path} still imports the old root package',
      );
    }
  });
}
