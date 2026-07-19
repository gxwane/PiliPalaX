import 'package:PiliPalaX/models/github/latest.dart';
import 'package:pub_semver/pub_semver.dart';

class AppUpdatePolicy {
  AppUpdatePolicy._();

  static Version? parseVersion(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim().replaceFirst(RegExp(r'^[vV]'), '');
    if (normalized.isEmpty) {
      return null;
    }
    try {
      final parsed = Version.parse(normalized);
      return Version(
        parsed.major,
        parsed.minor,
        parsed.patch,
        pre: parsed.preRelease.isEmpty ? null : parsed.preRelease.join('.'),
      );
    } on FormatException {
      return null;
    }
  }

  static LatestDataModel? selectRelease({
    required String localVersion,
    required Iterable<LatestDataModel> releases,
  }) {
    final local = parseVersion(localVersion);
    if (local == null) {
      return null;
    }

    final acceptsPrereleases = local.isPreRelease;
    LatestDataModel? selected;
    Version? selectedVersion;

    for (final release in releases) {
      if (release.draft || (!acceptsPrereleases && release.prerelease)) {
        continue;
      }
      final candidate = parseVersion(release.tagName);
      if (candidate == null || candidate <= local) {
        continue;
      }
      if (selectedVersion == null || candidate > selectedVersion) {
        selected = release;
        selectedVersion = candidate;
      }
    }
    return selected;
  }

  static AssetItem? selectAndroidAsset(Iterable<AssetItem> assets, String abi) {
    final apkAssets = assets
        .where((asset) {
          final name = asset.name?.toLowerCase() ?? '';
          return name.endsWith('.apk') && asset.downloadUrl?.isNotEmpty == true;
        })
        .toList(growable: false);
    final normalizedAbi = abi.toLowerCase();

    if (normalizedAbi.isNotEmpty) {
      for (final asset in apkAssets) {
        if (asset.name!.toLowerCase().contains(normalizedAbi)) {
          return asset;
        }
      }
    }
    for (final asset in apkAssets) {
      if (asset.name!.toLowerCase().contains('universal')) {
        return asset;
      }
    }

    const knownAbis = <String>['arm64-v8a', 'armeabi-v7a', 'x86_64'];
    for (final asset in apkAssets) {
      final name = asset.name!.toLowerCase();
      if (!knownAbis.any(name.contains)) {
        return asset;
      }
    }
    return null;
  }
}
