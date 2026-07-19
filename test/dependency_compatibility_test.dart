import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('orientation plugin remains compatible with clean AGP 8 builds', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(
      pubspec,
      contains(RegExp(r'^  auto_orientation_v2: \^2\.3\.8$', multiLine: true)),
    );
    expect(pubspec, isNot(contains('github.com/orz12/auto_orientation.git')));

    for (final path in <String>[
      'lib/plugin/pl_player/utils/fullscreen.dart',
      'lib/pages/video/view.dart',
      'lib/pages/setting/style_setting.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(
        source,
        contains("package:auto_orientation_v2/auto_orientation_v2.dart"),
        reason: '$path must import the namespace-ready orientation plugin',
      );
      expect(
        source,
        isNot(contains('package:auto_orientation/auto_orientation.dart')),
        reason: '$path must not restore the unmaintained Git plugin',
      );
    }
  });

  test('root analysis excludes the standalone fl_pip example app', () {
    final analysisOptions = File('analysis_options.yaml').readAsStringSync();

    expect(
      analysisOptions,
      contains('packages/fl_pip/example/**'),
      reason:
          'the example has its own dependency graph and is not part of the app',
    );
  });
}
