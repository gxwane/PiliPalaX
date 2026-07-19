import 'dart:io';

String extractChangelogSection(String changelog, String tagOrVersion) {
  final version = tagOrVersion.trim().replaceFirst(RegExp(r'^[vV]'), '');
  if (version.isEmpty) {
    throw const FormatException('Version must not be empty');
  }

  final headerPattern = RegExp(
    '^## \\[${RegExp.escape(version)}\\](?:\\s+-\\s+.+)?\\s*\$',
    multiLine: true,
  );
  final header = headerPattern.firstMatch(changelog);
  if (header == null) {
    throw FormatException('CHANGELOG.md has no section for $version');
  }

  final boundaryPattern = RegExp(r'^(?:## \[|\[[^\]]+\]:\s)', multiLine: true);
  final boundary = boundaryPattern.firstMatch(changelog.substring(header.end));
  final end = boundary == null ? changelog.length : header.end + boundary.start;
  final notes = changelog.substring(header.end, end).trim();
  if (notes.isEmpty) {
    throw FormatException('CHANGELOG.md section for $version is empty');
  }
  return notes;
}

void main(List<String> arguments) {
  if (arguments.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/extract_changelog.dart <tag-or-version> <output-file>',
    );
    exitCode = 64;
    return;
  }

  try {
    final changelog = File('CHANGELOG.md').readAsStringSync();
    final notes = extractChangelogSection(changelog, arguments[0]);
    final output = File(arguments[1]);
    output.parent.createSync(recursive: true);
    output.writeAsStringSync('$notes\n');
    stdout.writeln('Extracted ${arguments[0]} release notes to ${output.path}');
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}
