import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:lockd/src/exception.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// JSON object key style for generated `fromJson` / `toJson` when
/// `@JsonKey` is omitted.
///
/// Config: `lockd.yaml` → `field_rename`
/// (`camel` | `kebab` | `snake` | `pascal`), optional; default `camel`.
enum LockdFieldRename {
  /// camelCase (unchanged).
  camel,

  /// kebab-case.
  kebab,

  /// snake_case.
  snake,

  /// PascalCase.
  pascal,
}

/// Applies [mode] to a Dart field name for JSON map keys.
String applyLockdFieldRename(String dartName, LockdFieldRename mode) {
  switch (mode) {
    case LockdFieldRename.camel:
      return dartName;
    case LockdFieldRename.snake:
      return dartName.toSnakeCase();
    case LockdFieldRename.kebab:
      return dartName.toParamCase();
    case LockdFieldRename.pascal:
      return dartName.toPascalCase();
  }
}

LockdFieldRename _parseFieldRenameYaml(Object? raw) {
  if (raw == null) return LockdFieldRename.camel;
  if (raw is! String) {
    throw const LockdException(
      'lockd.yaml field_rename must be a string.',
    );
  }
  switch (raw) {
    case 'camel':
      return LockdFieldRename.camel;
    case 'kebab':
      return LockdFieldRename.kebab;
    case 'snake':
      return LockdFieldRename.snake;
    case 'pascal':
      return LockdFieldRename.pascal;
    default:
      throw LockdException(
        'lockd.yaml field_rename: '
        'expected camel, kebab, snake, or pascal; got "$raw".',
      );
  }
}

/// Reads [LockdFieldRename] from `./lockd.yaml` (`field_rename`),
/// defaulting to [LockdFieldRename.camel].
LockdFieldRename loadLockdFieldRenameFromProjectRoot({
  String workingDirectory = '.',
}) {
  final file = File(p.join(workingDirectory, 'lockd.yaml'));
  if (!file.existsSync()) return LockdFieldRename.camel;
  final dynamic yaml = loadYaml(file.readAsStringSync());
  if (yaml is! Map) return LockdFieldRename.camel;
  return _parseFieldRenameYaml(yaml['field_rename']);
}

/// Default glob patterns when no `lockd.yaml` or no `include` key.
const List<String> defaultLockdIncludeGlobs = ['lib/**.dart'];

/// Reads include glob patterns from `./lockd.yaml` (`include`),
/// defaulting to [defaultLockdIncludeGlobs].
List<String> loadLockdIncludeGlobs({
  String workingDirectory = '.',
}) {
  final file = File(p.join(workingDirectory, 'lockd.yaml'));
  if (!file.existsSync()) return defaultLockdIncludeGlobs;
  final dynamic yaml = loadYaml(file.readAsStringSync());
  if (yaml is! Map) return defaultLockdIncludeGlobs;
  final include = yaml['include'];
  if (include is! List || include.isEmpty) {
    return defaultLockdIncludeGlobs;
  }
  return include.cast<String>();
}

/// Throws [LockdException] if [workingDirectory] does not contain
/// `pubspec.yaml`.
void ensureLockdProjectRoot([String workingDirectory = '.']) {
  final pubspec = File(p.join(workingDirectory, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    throw const LockdException('pubspec.yaml not found.');
  }
}
