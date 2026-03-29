import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:lockd/src/generator.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  ensureLockdProjectRoot();

  final fieldRename = loadLockdFieldRenameFromProjectRoot();
  final includeGlobs = loadLockdIncludeGlobs();

  final dartFiles = <String, File>{};
  for (final pattern in includeGlobs) {
    final glob = Glob(pattern);
    for (final entity in glob.listSync()) {
      if (entity is! File) continue;
      final path = entity.path;
      if (!path.endsWith('.dart')) continue;
      if (path.endsWith('.lockd.dart')) continue;
      dartFiles[p.normalize(path)] = entity as File;
    }
  }

  if (dartFiles.isEmpty) {
    stdout.writeln('No matching .dart files found.');
    return;
  }

  final sourceCache = <String, String>{};

  String readSource(String path) {
    return sourceCache.putIfAbsent(path, () {
      final f = File(path);
      return f.existsSync() ? f.readAsStringSync() : '';
    });
  }

  // host library path → set of all member paths (host itself + its parts).
  final libraryGroups = <String, Set<String>>{};

  for (final filePath in dartFiles.keys) {
    final source = readSource(filePath);
    final partOfUri = _partOfUri(source);
    if (partOfUri != null) {
      final hostPath = p.normalize(p.join(p.dirname(filePath), partOfUri));
      libraryGroups.putIfAbsent(hostPath, () => {}).add(filePath);
    } else {
      libraryGroups.putIfAbsent(filePath, () => {}).add(filePath);
    }
  }

  // For every host library, also discover all `part` directives so we include
  // every part file in the generation even if the glob didn't match it.
  for (final hostPath in libraryGroups.keys.toList()) {
    final hostSource = readSource(hostPath);
    if (hostSource.isEmpty) continue;
    libraryGroups[hostPath]!.add(hostPath);
    for (final partUri in _partUris(hostSource)) {
      if (partUri.endsWith('.lockd.dart')) continue;
      final partPath = p.normalize(p.join(p.dirname(hostPath), partUri));
      libraryGroups[hostPath]!.add(partPath);
    }
  }

  var generated = 0;
  for (final entry in libraryGroups.entries) {
    final hostPath = entry.key;
    final memberPaths = entry.value;

    final hostSource = readSource(hostPath);
    if (hostSource.isEmpty) continue;

    final stem = p.basenameWithoutExtension(hostPath);
    final expectedPart = '$stem.lockd.dart';

    // Only generate when the host library declares `part '<stem>.lockd.dart';`.
    final hostPartUris = _partUris(hostSource);
    if (!hostPartUris.contains(expectedPart)) continue;

    final ordered = <String>[
      if (memberPaths.contains(hostPath)) hostPath,
      ...(memberPaths.where((m) => m != hostPath).toList()..sort()),
    ];
    final sourceTexts = <String>[
      for (final mp in ordered)
        if (readSource(mp).isNotEmpty) readSource(mp),
    ];
    if (sourceTexts.isEmpty) continue;

    final output = lockdModulePartDartContents(
      moduleStem: stem,
      sourceTexts: sourceTexts,
      fieldRename: fieldRename,
    );
    if (output == null) continue;

    final outPath = p.join(p.dirname(hostPath), '$stem.lockd.dart');
    File(outPath).writeAsStringSync(output);
    stdout.writeln('  ${p.relative(outPath)}');
    generated++;
  }

  if (generated == 0) {
    stdout.writeln('No files generated.');
  } else {
    stdout.writeln('Generated $generated file(s).');
  }
}

/// Extracts the URI string from a `part of '...';` directive, or `null` if the
/// file is not a part or uses library-name syntax.
String? _partOfUri(String source) {
  final unit = parseString(content: source, throwIfDiagnostics: false).unit;
  for (final d in unit.directives) {
    if (d is PartOfDirective) {
      final uri = d.uri;
      if (uri is SimpleStringLiteral) return uri.value;
      if (uri is StringLiteral) return uri.stringValue;
    }
  }
  return null;
}

/// Extracts all URI strings from `part '...';` directives.
List<String> _partUris(String source) {
  final unit = parseString(content: source, throwIfDiagnostics: false).unit;
  final uris = <String>[];
  for (final d in unit.directives) {
    if (d is PartDirective) {
      final v = d.uri.stringValue;
      if (v != null) uris.add(v);
    }
  }
  return uris;
}
