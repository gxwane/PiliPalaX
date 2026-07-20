import 'package:pilipalay/models/github/latest.dart';
import 'package:pilipalay/utils/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

LatestDataModel release(
  String tag, {
  bool prerelease = false,
  bool draft = false,
  List<AssetItem> assets = const <AssetItem>[],
}) {
  return LatestDataModel(
    tagName: tag,
    htmlUrl: 'https://github.com/gxwane/PiliPalaY/releases/tag/$tag',
    prerelease: prerelease,
    draft: draft,
    assets: assets,
  );
}

void main() {
  group('AppUpdatePolicy.parseVersion', () {
    test('accepts release tags and ignores build metadata for precedence', () {
      expect(AppUpdatePolicy.parseVersion('v1.2.0'), Version(1, 2, 0));
      expect(AppUpdatePolicy.parseVersion('1.2.0+114520'), Version(1, 2, 0));
      expect(
        AppUpdatePolicy.parseVersion(
          '1.2.0+1',
        )!.compareTo(AppUpdatePolicy.parseVersion('1.2.0+999')!),
        0,
      );
      expect(AppUpdatePolicy.parseVersion('not-a-version'), isNull);
    });

    test('orders alpha, beta, rc, and stable versions semantically', () {
      final versions = <Version>[
        AppUpdatePolicy.parseVersion('v1.3.0')!,
        AppUpdatePolicy.parseVersion('v1.3.0-rc.1')!,
        AppUpdatePolicy.parseVersion('v1.3.0-alpha.1')!,
        AppUpdatePolicy.parseVersion('v1.3.0-beta.1')!,
      ]..sort();

      expect(versions.map((version) => version.toString()), <String>[
        '1.3.0-alpha.1',
        '1.3.0-beta.1',
        '1.3.0-rc.1',
        '1.3.0',
      ]);
    });
  });

  group('AppUpdatePolicy.selectRelease', () {
    test('stable builds ignore prereleases and drafts', () {
      final selected = AppUpdatePolicy.selectRelease(
        localVersion: '1.2.0+114520',
        releases: <LatestDataModel>[
          release('v1.3.0-beta.1', prerelease: true),
          release('v1.2.2', draft: true),
          release('v1.2.1'),
        ],
      );

      expect(selected?.tagName, 'v1.2.1');
    });

    test('prerelease builds can advance through prereleases to stable', () {
      final selected = AppUpdatePolicy.selectRelease(
        localVersion: '1.3.0-beta.1+114521',
        releases: <LatestDataModel>[
          release('invalid', prerelease: true),
          release('v1.3.0-rc.1', prerelease: true),
          release('v1.3.0'),
        ],
      );

      expect(selected?.tagName, 'v1.3.0');
    });

    test('returns null when no valid newer release exists', () {
      final selected = AppUpdatePolicy.selectRelease(
        localVersion: 'v1.2.0',
        releases: <LatestDataModel>[
          release('broken'),
          release('v1.2.0'),
          release('v1.1.5'),
        ],
      );

      expect(selected, isNull);
    });
  });

  group('AppUpdatePolicy.selectAndroidAsset', () {
    final assets = <AssetItem>[
      AssetItem(
        name: 'PiliPalaY-android-universal-v1.3.0.apk',
        downloadUrl: 'https://example.invalid/universal.apk',
      ),
      AssetItem(
        name: 'PiliPalaY-android-arm64-v8a-v1.3.0.apk',
        downloadUrl: 'https://example.invalid/arm64.apk',
      ),
    ];

    test('prefers an exact ABI asset', () {
      expect(
        AppUpdatePolicy.selectAndroidAsset(assets, 'arm64-v8a')?.name,
        contains('arm64-v8a'),
      );
    });

    test('falls back to the universal APK', () {
      expect(
        AppUpdatePolicy.selectAndroidAsset(assets, 'x86_64')?.name,
        contains('universal'),
      );
    });

    test('recognizes the legacy universal APK name', () {
      expect(
        AppUpdatePolicy.selectAndroidAsset(<AssetItem>[
          AssetItem(
            name: 'Pili-v1.2.0.apk',
            downloadUrl: 'https://example.invalid/legacy-universal.apk',
          ),
        ], 'x86_64')?.name,
        'Pili-v1.2.0.apk',
      );
    });

    test('returns null when no usable APK exists', () {
      expect(
        AppUpdatePolicy.selectAndroidAsset(<AssetItem>[
          AssetItem(name: 'PiliPalaY-ios-unsigned-v1.3.0.ipa'),
        ], 'arm64-v8a'),
        isNull,
      );
    });
  });
}
