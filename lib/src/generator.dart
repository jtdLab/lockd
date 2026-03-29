// Code generation strings often have adjacent string literals and long lines.
// ignore_for_file: missing_whitespace_between_adjacent_strings
// ignore_for_file: lines_longer_than_80_chars

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:lockd/src/lockd_gen_config.dart';
import 'package:lockd/src/utils.dart';

export 'package:lockd/src/lockd_gen_config.dart'
    show
        LockdFieldRename,
        applyLockdFieldRename,
        defaultLockdIncludeGlobs,
        ensureLockdProjectRoot,
        loadLockdFieldRenameFromProjectRoot,
        loadLockdIncludeGlobs;

// ---------------------------------------------------------------------------
// Enum wire representation
// ---------------------------------------------------------------------------

/// One enum constant's JSON wire value.
final class LockdEnumWire {
  /// Creates a [LockdEnumWire].
  const LockdEnumWire({
    required this.caseName,
    required this.wireLiteral,
    required this.isInt,
  });

  /// The Dart enum case name.
  final String caseName;

  /// Dart expression for the map value (`3`, `'a'`, …).
  final String wireLiteral;

  /// Whether the wire value is an integer.
  final bool isInt;
}

// ---------------------------------------------------------------------------
// Enum registry
// ---------------------------------------------------------------------------

/// Merged enum registry for a module.
Map<String, List<LockdEnumWire>> lockdEnumRegistryForModuleSources(
  Iterable<String> librarySources,
) {
  final merged = <String, List<LockdEnumWire>>{};
  for (final src in librarySources) {
    final parsed = parseString(content: src, throwIfDiagnostics: false);
    _mergeEnumRegistry(merged, _collectLibraryEnums(src, parsed.unit));
  }
  return merged;
}

void _mergeEnumRegistry(
  Map<String, List<LockdEnumWire>> into,
  Map<String, List<LockdEnumWire>> from,
) {
  for (final e in from.entries) {
    final existing = into[e.key];
    if (existing == null) {
      into[e.key] = List<LockdEnumWire>.from(e.value);
    } else {
      final byName = {for (final w in existing) w.caseName: w};
      for (final w in e.value) {
        byName[w.caseName] = w;
      }
      into[e.key] = byName.values.toList();
    }
  }
}

// ---------------------------------------------------------------------------
// String helpers
// ---------------------------------------------------------------------------

String _escapeForSingleQuotedDartString(String s) =>
    s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

String _dartStringLiteralFromValue(String value) =>
    "'${_escapeForSingleQuotedDartString(value)}'";

String _jsonMapKeyForField(_Field f, LockdFieldRename fieldRename) =>
    f.jsonKeyName ?? applyLockdFieldRename(f.name, fieldRename);

String _jsonBracketExpr(String jsonKey) =>
    "json['${_escapeForSingleQuotedDartString(jsonKey)}']";

// ---------------------------------------------------------------------------
// Annotation helpers
// ---------------------------------------------------------------------------

String? _annotationSimpleName(Annotation meta) {
  final n = meta.name;
  return switch (n) {
    SimpleIdentifier(:final name) => name,
    PrefixedIdentifier(:final identifier) => identifier.name,
    LibraryIdentifier(:final name) => name,
  };
}

bool _hasLockdAnnotation(ClassDeclaration decl) {
  for (final meta in decl.metadata) {
    final name = _annotationSimpleName(meta);
    if (name == 'lockd' || name == 'Lockd') return true;
  }
  return false;
}

String? _jsonKeyNameFromAnnotation(Annotation meta) {
  final args = meta.arguments;
  if (args == null) return null;
  for (final arg in args.arguments) {
    if (arg is NamedExpression && arg.name.label.name == 'name') {
      final expr = arg.expression;
      if (expr is SimpleStringLiteral) return expr.value;
      if (expr is StringLiteral) return expr.stringValue;
    }
  }
  for (final arg in args.arguments) {
    if (arg is NamedExpression) continue;
    if (arg is SimpleStringLiteral) return arg.value;
    if (arg is StringLiteral) return arg.stringValue;
    return null;
  }
  return null;
}

String? _jsonKeyNameFromMetadata(AnnotatedNode node) {
  for (final meta in node.metadata) {
    if (_annotationSimpleName(meta) != 'JsonKey') continue;
    final n = _jsonKeyNameFromAnnotation(meta);
    if (n != null) return n;
  }
  return null;
}

bool _enumTypeWireIsInt(
  Map<String, List<LockdEnumWire>> lib,
  String typeName,
) {
  final cases = lib[typeName];
  if (cases == null || cases.isEmpty) return false;
  return cases.first.isInt;
}

// ---------------------------------------------------------------------------
// Generated header
// ---------------------------------------------------------------------------

/// Prepended to every generated `part` file before `part of`.
const String lockdGeneratedPartFileHeader = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

''';

/// Top-level sentinel for generated `copyWith` defaults.
const String lockdHelpersUnsetDeclaration = 'const Object _unset = Object();';

String _composeHelpersBody({
  required bool includeUnset,
  required String enumHelpers,
}) {
  final trimmed = enumHelpers.trim();
  if (!includeUnset && trimmed.isEmpty) return '';
  if (includeUnset && trimmed.isEmpty) return lockdHelpersUnsetDeclaration;
  if (!includeUnset && trimmed.isNotEmpty) return trimmed;
  return '$lockdHelpersUnsetDeclaration\n\n$trimmed';
}

// ---------------------------------------------------------------------------
// Module-level enum helpers
// ---------------------------------------------------------------------------

/// Merged enum JSON maps + decoders for an entire module output file.
String generatedModuleEnumHelpersPart(
  Iterable<String> librarySources, {
  LockdFieldRename fieldRename = LockdFieldRename.camel,
}) {
  final mergedEnums = lockdEnumRegistryForModuleSources(librarySources);
  final allModels = <_CopyableEmitModel>[];
  for (final src in librarySources) {
    final parsed = parseString(content: src, throwIfDiagnostics: false);
    allModels.addAll(
      _parseCopyableEmitModels(
        src,
        unit: parsed.unit,
        libraryEnums: mergedEnums,
        fieldRename: fieldRename,
      ),
    );
  }
  if (allModels.isEmpty) return '';
  final enumPart = _libraryEnumJsonHelpers(allModels, mergedEnums);
  return _composeHelpersBody(
    includeUnset: true,
    enumHelpers: enumPart,
  );
}

// ---------------------------------------------------------------------------
// Full module output
// ---------------------------------------------------------------------------

/// Full text for the generated `part` file, or `null` if nothing to emit.
String? lockdModulePartDartContents({
  required String moduleStem,
  required List<String> sourceTexts,
  LockdFieldRename fieldRename = LockdFieldRename.camel,
}) {
  final mergedEnums = lockdEnumRegistryForModuleSources(sourceTexts);
  final helpersRaw = generatedModuleEnumHelpersPart(
    sourceTexts,
    fieldRename: fieldRename,
  );
  final helpersBlock = helpersRaw.isEmpty
      ? ''
      : dartFile(
          headers: <String>[],
          content: ['// ###### Helpers ####', '', helpersRaw],
        );

  final chunks = <String>[];
  for (final text in sourceTexts) {
    final body = generatedDataClassPart(
      text,
      includeEnumHelpers: false,
      enumRegistryOverride: mergedEnums,
      fieldRename: fieldRename,
    );
    if (body.isNotEmpty) chunks.add(body);
  }

  if (chunks.isEmpty && helpersBlock.isEmpty) return null;

  final barrelName = '$moduleStem.dart';
  final out = StringBuffer()
    ..write(lockdGeneratedPartFileHeader)
    ..write("part of '$barrelName';\n\n");
  if (helpersBlock.isNotEmpty) {
    out
      ..write(helpersBlock)
      ..write('\n\n');
  }
  out.write(chunks.join('\n'));
  return out.toString();
}

// ---------------------------------------------------------------------------
// Per-source generator
// ---------------------------------------------------------------------------

/// Generates code for all data classes found in [librarySource].
String generatedDataClassPart(
  String librarySource, {
  bool includeEnumHelpers = true,
  Map<String, List<LockdEnumWire>>? enumRegistryOverride,
  LockdFieldRename fieldRename = LockdFieldRename.camel,
}) {
  final parsed = parseString(content: librarySource, throwIfDiagnostics: false);
  final unit = parsed.unit;
  final libraryEnums =
      enumRegistryOverride ?? _collectLibraryEnums(librarySource, unit);
  final models = _parseCopyableEmitModels(
    librarySource,
    unit: unit,
    libraryEnums: libraryEnums,
    fieldRename: fieldRename,
  );
  if (models.isEmpty) return '';
  final enumHelpers = includeEnumHelpers
      ? _libraryEnumJsonHelpers(models, libraryEnums)
      : '';
  final helpersPrefix = includeEnumHelpers
      ? [
          '// ###### Helpers ####',
          '',
          _composeHelpersBody(
            includeUnset: true,
            enumHelpers: enumHelpers,
          ),
          '',
        ]
      : <String>[];
  return dartFile(
    headers: <String>[],
    content: [
      ...helpersPrefix,
      for (final m in models) ...[
        '// ########################################################',
        '// ${m.publicName}',
        '// ########################################################',
        '',
        _mixinCopyable(m),
        '',
        _classCopyWith(m),
        '',
        _classPrivateImpl(m),
        '',
      ],
    ],
  );
}

// ---------------------------------------------------------------------------
// Field model
// ---------------------------------------------------------------------------

class _Field {
  _Field({
    required this.name,
    required this.typeSource,
    this.defaultValueSource,
    this.jsonKeyName,
  });

  final String name;
  final String typeSource;
  final String? defaultValueSource;
  final String? jsonKeyName;
}

// ---------------------------------------------------------------------------
// Emit model
// ---------------------------------------------------------------------------

class _CopyableEmitModel {
  _CopyableEmitModel({
    required this.publicName,
    required this.implName,
    required this.fields,
    required this.hasFromJson,
    required this.ctorIsConst,
    required this.libraryEnums,
    required this.fieldRename,
  });

  final String publicName;
  final String implName;
  final List<_Field> fields;
  final bool hasFromJson;
  final bool ctorIsConst;
  final Map<String, List<LockdEnumWire>> libraryEnums;
  final LockdFieldRename fieldRename;

  String get mixinName => '_\$$publicName';
  String get copyWithName => '_${publicName}CopyWith';
}

// ---------------------------------------------------------------------------
// Mixin
// ---------------------------------------------------------------------------

String _mixinCopyable(_CopyableEmitModel m) {
  final getters = m.fields
      .map((f) => '  ${f.typeSource} get ${f.name};')
      .join('\n\n');

  final toJson = m.hasFromJson ? '\n\n  Map<String, dynamic> toJson();' : '';

  return '''
mixin ${m.mixinName} {
$getters

  ${m.copyWithName} get copyWith => ${m.copyWithName}(this);$toJson
}'''
      .trim();
}

// ---------------------------------------------------------------------------
// CopyWith class
// ---------------------------------------------------------------------------

String _classCopyWith(_CopyableEmitModel m) {
  const unset = '_unset';
  final params = m.fields.isEmpty
      ? ''
      : m.fields.map((f) => '    Object? ${f.name} = $unset,').join('\n');

  final body = m.fields.isEmpty
      ? 'return ${m.publicName}();'
      : 'return ${m.publicName}(\n'
            '      ${m.fields.map((f) => '${f.name}: _pick<${f.typeSource}>(${f.name}, _v.${f.name})').join(',\n      ')},\n'
            '    );';

  final signature = m.fields.isEmpty ? '' : '{\n$params\n  }';

  return '''
class ${m.copyWithName} {
  ${m.copyWithName}(this._v);

  final ${m.mixinName} _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  ${m.publicName} call($signature) {
    $body
  }
}'''
      .trim();
}

// ---------------------------------------------------------------------------
// JSON field shapes
// ---------------------------------------------------------------------------

const Set<String> _jsonPrimitiveTypeBases = {
  'dynamic',
  'Object',
  'String',
  'bool',
  'int',
  'double',
  'num',
  'BigInt',
};

bool _fieldTypeIsNullable(String typeSource) => typeSource.trim().endsWith('?');

String _fieldTypeWithoutTrailingNullMarkers(String typeSource) {
  var t = typeSource.trim();
  while (t.endsWith('?')) {
    t = t.substring(0, t.length - 1);
  }
  return t;
}

bool _isJsonMapStringDynamic(String baseNonNull) {
  final compact = baseNonNull.replaceAll(RegExp(r'\s+'), '');
  return compact == 'Map<String,dynamic>';
}

bool _isJsonPrimitiveBase(String baseNonNull) {
  return _jsonPrimitiveTypeBases.contains(baseNonNull.trim()) ||
      _isJsonMapStringDynamic(baseNonNull);
}

bool _isUint8ListBase(String baseNonNull) =>
    _enumLookupKey(baseNonNull) == 'Uint8List';

bool _isDateTimeBase(String baseNonNull) =>
    _enumLookupKey(baseNonNull) == 'DateTime';

bool _isDurationBase(String baseNonNull) =>
    _enumLookupKey(baseNonNull) == 'Duration';

String? _listElementTypeIfListOf(String baseNonNull) {
  final t = baseNonNull.trim();
  final head = RegExp(r'^List\s*<').firstMatch(t);
  if (head == null) return null;
  final innerStart = head.end;
  var depth = 1;
  for (var i = innerStart; i < t.length; i++) {
    final ch = t[i];
    if (ch == '<') {
      depth++;
    } else if (ch == '>') {
      depth--;
      if (depth == 0) {
        return t.substring(innerStart, i).trim();
      }
    }
  }
  return null;
}

enum _JsonFieldShape {
  primitive,
  dateTime,
  duration,
  object,
  enumWire,
  uint8List,
  listPrimitive,
  listDateTime,
  listDuration,
  listObject,
  listEnum,
  listUint8List,
}

String _enumLookupKey(String typeSource) {
  var t = _fieldTypeWithoutTrailingNullMarkers(typeSource).trim();
  final dot = t.lastIndexOf('.');
  if (dot != -1) {
    t = t.substring(dot + 1);
  }
  final angle = t.indexOf('<');
  if (angle != -1) {
    t = t.substring(0, angle);
  }
  return t.trim();
}

String _enumJsonMapIdentifier(String typeName) {
  if (typeName.isEmpty) return '_jsonMap';
  final head = typeName[0].toLowerCase();
  final tail = typeName.length > 1 ? typeName.substring(1) : '';
  return '_$head${tail}JsonMap';
}

String _enumJsonDecodeIdentifier(String typeName) =>
    '_decode${typeName}JsonMap';

String _libraryEnumJsonHelpers(
  List<_CopyableEmitModel> models, [
  Map<String, List<LockdEnumWire>>? enumRegistry,
]) {
  if (models.isEmpty) return '';
  final lib = enumRegistry ?? models.first.libraryEnums;
  final enums = <String>{};
  for (final m in models) {
    if (!m.hasFromJson) continue;
    enums.addAll(_sortedEnumTypesForWire(m.fields, lib));
  }
  if (enums.isEmpty) return '';

  final b = StringBuffer();
  for (final typeName in (enums.toList()..sort())) {
    final cases = lib[typeName];
    if (cases == null || cases.isEmpty) continue;
    final mapId = _enumJsonMapIdentifier(typeName);
    final decodeId = _enumJsonDecodeIdentifier(typeName);
    final wireInt = cases.first.isInt;
    if (!cases.every((w) => w.isInt == wireInt)) {
      throw StateError(
        'Enum $typeName: '
        'JSON wire must be all int or all String.',
      );
    }
    final valueType = wireInt ? 'int' : 'String';
    b.writeln('const Map<$typeName, $valueType> $mapId = {');
    for (final w in cases) {
      b.writeln('  $typeName.${w.caseName}: ${w.wireLiteral},');
    }
    b
      ..writeln('};')
      ..writeln();
    final decodeParam = wireInt ? 'int v' : 'String v';
    b
      ..writeln(
        '$typeName $decodeId($decodeParam) => '
        '$mapId.entries.singleWhere((e) => e.value == v).key;',
      )
      ..writeln();
  }
  return b.toString().trimRight();
}

// ---------------------------------------------------------------------------
// Enum constant parsing
// ---------------------------------------------------------------------------

LockdEnumWire _parseEnumConstant(
  String source,
  EnumConstantDeclaration c,
) {
  final caseName = c.name.lexeme;
  Annotation? jsonValueMeta;
  Annotation? jsonKeyMeta;
  for (final meta in c.metadata) {
    final an = _annotationSimpleName(meta);
    if (an == 'JsonValue') jsonValueMeta = meta;
    if (an == 'JsonKey') jsonKeyMeta = meta;
  }
  if (jsonValueMeta != null) {
    final args = jsonValueMeta.arguments;
    if (args != null && args.arguments.isNotEmpty) {
      final expr = args.arguments.first;
      final lit = source.substring(expr.offset, expr.end).trim();
      final isInt =
          int.tryParse(lit) != null &&
          !lit.startsWith("'") &&
          !lit.startsWith('"');
      return LockdEnumWire(
        caseName: caseName,
        wireLiteral: lit,
        isInt: isInt,
      );
    }
  }
  if (jsonKeyMeta != null) {
    final wire = _jsonKeyNameFromAnnotation(jsonKeyMeta);
    if (wire != null) {
      return LockdEnumWire(
        caseName: caseName,
        wireLiteral: _dartStringLiteralFromValue(wire),
        isInt: false,
      );
    }
  }
  return LockdEnumWire(
    caseName: caseName,
    wireLiteral: _dartStringLiteralFromValue(caseName),
    isInt: false,
  );
}

Map<String, List<LockdEnumWire>> _collectLibraryEnums(
  String source,
  CompilationUnit unit,
) {
  final out = <String, List<LockdEnumWire>>{};
  for (final decl in unit.declarations) {
    if (decl is! EnumDeclaration) continue;
    final name = decl.namePart.typeName.lexeme;
    out[name] = [
      for (final c in decl.body.constants) _parseEnumConstant(source, c),
    ];
  }
  return out;
}

List<String> _sortedEnumTypesForWire(
  List<_Field> fields,
  Map<String, List<LockdEnumWire>> libraryEnums,
) {
  final ids = <String>{};
  for (final f in fields) {
    final base = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
    final inner = _listElementTypeIfListOf(base);
    if (inner != null) {
      final k = _enumLookupKey(inner);
      if (libraryEnums.containsKey(k)) ids.add(k);
    } else {
      final k = _enumLookupKey(base);
      if (libraryEnums.containsKey(k)) ids.add(k);
    }
  }
  return ids.toList()..sort();
}

// ---------------------------------------------------------------------------
// JSON field shape classification
// ---------------------------------------------------------------------------

_JsonFieldShape _jsonFieldShape(
  _Field f,
  Map<String, List<LockdEnumWire>> libraryEnums,
) {
  final base = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
  final inner = _listElementTypeIfListOf(base);
  if (inner != null) {
    final innerNonNull = _fieldTypeWithoutTrailingNullMarkers(inner);
    if (libraryEnums.containsKey(_enumLookupKey(inner))) {
      return _JsonFieldShape.listEnum;
    }
    if (_isUint8ListBase(innerNonNull)) {
      return _JsonFieldShape.listUint8List;
    }
    if (_isDateTimeBase(innerNonNull)) {
      return _JsonFieldShape.listDateTime;
    }
    if (_isDurationBase(innerNonNull)) {
      return _JsonFieldShape.listDuration;
    }
    if (_isJsonPrimitiveBase(innerNonNull)) {
      return _JsonFieldShape.listPrimitive;
    }
    return _JsonFieldShape.listObject;
  }
  if (libraryEnums.containsKey(_enumLookupKey(base))) {
    return _JsonFieldShape.enumWire;
  }
  if (_isUint8ListBase(base)) return _JsonFieldShape.uint8List;
  if (_isDateTimeBase(base)) return _JsonFieldShape.dateTime;
  if (_isDurationBase(base)) return _JsonFieldShape.duration;
  if (_isJsonPrimitiveBase(base)) return _JsonFieldShape.primitive;
  return _JsonFieldShape.object;
}

// ---------------------------------------------------------------------------
// fromJson / toJson expressions
// ---------------------------------------------------------------------------

String _fromJsonAssignment(_Field f, _CopyableEmitModel m) {
  final libraryEnums = m.libraryEnums;
  final jk = _jsonMapKeyForField(f, m.fieldRename);
  final jx = _jsonBracketExpr(jk);
  final shape = _jsonFieldShape(f, libraryEnums);
  final nullable = _fieldTypeIsNullable(f.typeSource);

  String wrapNullable(String expr) {
    if (!nullable) return expr;
    return '$jx == null ? null : $expr';
  }

  switch (shape) {
    case _JsonFieldShape.primitive:
      return '$jx as ${f.typeSource}';
    case _JsonFieldShape.dateTime:
      return wrapNullable(
        'DateTime.parse($jx as String)',
      );
    case _JsonFieldShape.duration:
      return wrapNullable(
        'Duration(microseconds: $jx as int)',
      );
    case _JsonFieldShape.uint8List:
      return wrapNullable(
        'Uint8List.fromList('
        '($jx as List<dynamic>)'
        '.map((e) => (e as num).toInt()).toList())',
      );
    case _JsonFieldShape.enumWire:
      final t = _enumLookupKey(
        _fieldTypeWithoutTrailingNullMarkers(f.typeSource),
      );
      final dec = _enumJsonDecodeIdentifier(t);
      final cast = _enumTypeWireIsInt(libraryEnums, t) ? 'int' : 'String';
      return wrapNullable('$dec($jx as $cast)');
    case _JsonFieldShape.object:
      final t = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      return wrapNullable(
        '$t.fromJson($jx as Map<String, dynamic>)',
      );
    case _JsonFieldShape.listPrimitive:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull)!;
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => e as $inner).toList()',
      );
    case _JsonFieldShape.listDateTime:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull)!;
      final innerElNullable = _fieldTypeIsNullable(inner);
      final mapExpr = innerElNullable
          ? '(e) => e == null '
                '? null : DateTime.parse(e as String)'
          : '(e) => DateTime.parse(e as String)';
      return wrapNullable(
        '($jx as List<dynamic>).map($mapExpr).toList()',
      );
    case _JsonFieldShape.listDuration:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull)!;
      final innerElNullable = _fieldTypeIsNullable(inner);
      final mapExpr = innerElNullable
          ? '(e) => e == null '
                '? null : Duration(microseconds: e as int)'
          : '(e) => Duration(microseconds: e as int)';
      return wrapNullable(
        '($jx as List<dynamic>).map($mapExpr).toList()',
      );
    case _JsonFieldShape.listEnum:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull)!;
      final t = _enumLookupKey(inner);
      final dec = _enumJsonDecodeIdentifier(t);
      final cast = _enumTypeWireIsInt(libraryEnums, t) ? 'int' : 'String';
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => $dec(e as $cast)).toList()',
      );
    case _JsonFieldShape.listUint8List:
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => Uint8List.fromList('
        '(e as List<dynamic>)'
        '.map((b) => (b as num).toInt()).toList())).toList()',
      );
    case _JsonFieldShape.listObject:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull)!;
      final innerClass = _fieldTypeWithoutTrailingNullMarkers(inner);
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => $innerClass.fromJson('
        'e as Map<String, dynamic>)).toList()',
      );
  }
}

String _toJsonValueExpr(_Field f, _CopyableEmitModel m) {
  final libraryEnums = m.libraryEnums;
  final shape = _jsonFieldShape(f, libraryEnums);
  final nullable = _fieldTypeIsNullable(f.typeSource);
  switch (shape) {
    case _JsonFieldShape.primitive:
    case _JsonFieldShape.listPrimitive:
      return f.name;
    case _JsonFieldShape.dateTime:
      return nullable
          ? '${f.name}?.toIso8601String()'
          : '${f.name}.toIso8601String()';
    case _JsonFieldShape.duration:
      return nullable
          ? '${f.name}?.inMicroseconds'
          : '${f.name}.inMicroseconds';
    case _JsonFieldShape.listDateTime:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull)!;
      final innerElNullable = _fieldTypeIsNullable(inner);
      final mapBody = innerElNullable
          ? '(e) => e?.toIso8601String()'
          : '(e) => e.toIso8601String()';
      if (nullable) return '${f.name}?.map($mapBody).toList()';
      return '${f.name}.map($mapBody).toList()';
    case _JsonFieldShape.listDuration:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull)!;
      final innerElNullable = _fieldTypeIsNullable(inner);
      final mapBody = innerElNullable
          ? '(e) => e?.inMicroseconds'
          : '(e) => e.inMicroseconds';
      if (nullable) return '${f.name}?.map($mapBody).toList()';
      return '${f.name}.map($mapBody).toList()';
    case _JsonFieldShape.uint8List:
      if (nullable) {
        return '${f.name} == null ? null : ${f.name}!.toList()';
      }
      return '${f.name}.toList()';
    case _JsonFieldShape.enumWire:
      final t = _enumLookupKey(
        _fieldTypeWithoutTrailingNullMarkers(f.typeSource),
      );
      final mapName = _enumJsonMapIdentifier(t);
      if (nullable) {
        return '${f.name} == null ? null : $mapName[${f.name}]!';
      }
      return '$mapName[${f.name}]!';
    case _JsonFieldShape.object:
      return nullable ? '${f.name}?.toJson()' : '${f.name}.toJson()';
    case _JsonFieldShape.listEnum:
      final inner = _listElementTypeIfListOf(
        _fieldTypeWithoutTrailingNullMarkers(f.typeSource),
      )!;
      final t = _enumLookupKey(inner);
      final mapName = _enumJsonMapIdentifier(t);
      if (nullable) {
        return '${f.name}?.map((e) => $mapName[e]!).toList()';
      }
      return '${f.name}.map((e) => $mapName[e]!).toList()';
    case _JsonFieldShape.listUint8List:
      if (nullable) {
        return '${f.name}?.map((e) => e.toList()).toList()';
      }
      return '${f.name}.map((e) => e.toList()).toList()';
    case _JsonFieldShape.listObject:
      final innerObj = _listElementTypeIfListOf(
        _fieldTypeWithoutTrailingNullMarkers(f.typeSource),
      )!;
      final eltNullable = _fieldTypeIsNullable(innerObj);
      final mapBody = eltNullable ? '(e) => e?.toJson()' : '(e) => e.toJson()';
      if (nullable) {
        return '${f.name}?.map($mapBody).toList()';
      }
      return '${f.name}.map($mapBody).toList()';
  }
}

// ---------------------------------------------------------------------------
// Private impl class
// ---------------------------------------------------------------------------

String _classPrivateImpl(_CopyableEmitModel m) {
  final constKw = m.ctorIsConst ? 'const ' : '';
  final head =
      '$constKw${m.implName}'
      '${_implConstructorParamsThisFormals(m.fields)}';

  final fromJson = m.hasFromJson
      ? '\n\n'
            '  factory ${m.implName}.fromJson('
            'Map<String, dynamic> json) {\n'
            '    return ${m.implName}(\n'
            '      ${m.fields.map((f) => '${f.name}: ${_fromJsonAssignment(f, m)}').join(',\n      ')},\n'
            '    );\n'
            '  }'
      : '';

  final fields = m.fields
      .map(
        (f) => '  @override\n  final ${f.typeSource} ${f.name};',
      )
      .join('\n\n');

  final toJson = m.hasFromJson
      ? '\n\n'
            '  Map<String, dynamic> toJson() {\n'
            '    return {\n'
            '      ${m.fields.map((f) => '${_dartStringLiteralFromValue(_jsonMapKeyForField(f, m.fieldRename))}: ${_toJsonValueExpr(f, m)}').join(',\n      ')},\n'
            '    };\n'
            '  }'
      : '';

  final fieldList = m.fields.map((f) => '${f.name}: \$${f.name}').join(', ');
  final toStringBody = m.fields.isEmpty
      ? "'${m.publicName}()'"
      : "'${m.publicName}($fieldList)'";

  return '''
class ${m.implName} with ${m.mixinName} implements ${m.publicName} {
  $head;$fromJson

$fields$toJson

  @override
  String toString() =>
      $toStringBody;
}'''
      .trim();
}

// ---------------------------------------------------------------------------
// AST parsing
// ---------------------------------------------------------------------------

List<ClassMember> _classMembers(ClassDeclaration decl) {
  final body = decl.body;
  if (body is BlockClassBody) return body.members.toList();
  return const [];
}

String _declaredClassName(ClassDeclaration decl) =>
    decl.namePart.typeName.lexeme;

List<_CopyableEmitModel> _parseCopyableEmitModels(
  String source, {
  CompilationUnit? unit,
  Map<String, List<LockdEnumWire>>? libraryEnums,
  LockdFieldRename fieldRename = LockdFieldRename.camel,
}) {
  final resolvedUnit =
      unit ?? parseString(content: source, throwIfDiagnostics: false).unit;
  final libEnums = libraryEnums ?? _collectLibraryEnums(source, resolvedUnit);
  final out = <_CopyableEmitModel>[];

  for (final decl in resolvedUnit.declarations) {
    if (decl is! ClassDeclaration) continue;
    final publicName = _declaredClassName(decl);
    if (publicName.startsWith('_')) continue;
    if (!_hasLockdAnnotation(decl)) continue;

    var hasFromJson = false;
    for (final m in _classMembers(decl)) {
      if (m is! ConstructorDeclaration) continue;
      if (m.factoryKeyword == null) continue;
      if (m.name?.lexeme == 'fromJson') hasFromJson = true;
    }

    var sawPair = false;
    for (final m in _classMembers(decl)) {
      if (m is! ConstructorDeclaration) continue;
      if (m.factoryKeyword == null) continue;
      if (m.redirectedConstructor == null) continue;
      final implName = m.redirectedConstructor!.type.name.lexeme;
      if (implName != '_$publicName') continue;
      if (sawPair) break;
      sawPair = true;

      final implDecl = resolvedUnit.declarations
          .whereType<ClassDeclaration>()
          .firstWhereOrNull(
            (c) => _declaredClassName(c) == implName,
          );

      late final List<_Field> fields;
      late final bool ctorIsConst;

      if (implDecl != null) {
        final ctor = _unnamedGenerativeConstructor(implDecl);
        fields = _mergeFactoryParametersIntoFields(
          source,
          _collectFields(source, implDecl),
          m.parameters,
        );
        ctorIsConst = ctor?.constKeyword != null;
      } else {
        fields = _collectFieldsFromFormalParameters(
          source,
          m.parameters,
        );
        ctorIsConst = m.constKeyword != null;
      }

      out.add(
        _CopyableEmitModel(
          publicName: publicName,
          implName: implName,
          fields: fields,
          hasFromJson: hasFromJson,
          ctorIsConst: ctorIsConst,
          libraryEnums: libEnums,
          fieldRename: fieldRename,
        ),
      );
    }
  }

  return out;
}

// ---------------------------------------------------------------------------
// Formal parameter helpers
// ---------------------------------------------------------------------------

String? _formalParameterName(FormalParameter param) {
  final inner = param is DefaultFormalParameter ? param.parameter : param;
  return switch (inner) {
    SimpleFormalParameter(:final name?) => name.lexeme,
    FieldFormalParameter(:final name) => name.lexeme,
    _ => null,
  };
}

String? _defaultAnnotationArgumentSource(
  String source,
  AnnotatedNode node,
) {
  for (final meta in node.metadata) {
    final simple = switch (meta.name) {
      SimpleIdentifier(:final name) => name,
      PrefixedIdentifier(:final identifier) => identifier.name,
      LibraryIdentifier(:final name) => name,
    };
    if (simple != 'Default') continue;
    final args = meta.arguments;
    if (args == null || args.arguments.isEmpty) continue;
    final a0 = args.arguments.first;
    return source.substring(a0.offset, a0.end).trim();
  }
  return null;
}

String? _defaultFromFormalParameter(
  String source,
  FormalParameter param,
) {
  final inner = param is DefaultFormalParameter ? param.parameter : param;
  return switch (inner) {
    final SimpleFormalParameter p => _defaultAnnotationArgumentSource(
      source,
      p,
    ),
    final FieldFormalParameter p => _defaultAnnotationArgumentSource(source, p),
    _ => null,
  };
}

String? _jsonKeyFromFormalParameter(
  String source,
  FormalParameter param,
) {
  final inner = param is DefaultFormalParameter ? param.parameter : param;
  return switch (inner) {
    final SimpleFormalParameter p => _jsonKeyNameFromMetadata(p),
    final FieldFormalParameter p => _jsonKeyNameFromMetadata(p),
    _ => null,
  };
}

List<_Field> _mergeFactoryParametersIntoFields(
  String source,
  List<_Field> fields,
  FormalParameterList factoryParams,
) {
  final defaults = <String, String>{};
  final jsonKeys = <String, String>{};
  for (final p in factoryParams.parameters) {
    final n = _formalParameterName(p);
    if (n == null) continue;
    final d = _defaultFromFormalParameter(source, p);
    if (d != null) defaults[n] = d;
    final jk = _jsonKeyFromFormalParameter(source, p);
    if (jk != null) jsonKeys[n] = jk;
  }
  if (defaults.isEmpty && jsonKeys.isEmpty) return fields;
  return [
    for (final f in fields)
      _Field(
        name: f.name,
        typeSource: f.typeSource,
        defaultValueSource:
            f.defaultValueSource == null && defaults.containsKey(f.name)
            ? defaults[f.name]
            : f.defaultValueSource,
        jsonKeyName: jsonKeys[f.name] ?? f.jsonKeyName,
      ),
  ];
}

List<_Field> _collectFieldsFromFormalParameters(
  String source,
  FormalParameterList parameters,
) {
  final fields = <_Field>[];
  for (final param in parameters.parameters) {
    final inner = param is DefaultFormalParameter ? param.parameter : param;
    if (inner is SimpleFormalParameter) {
      final name = inner.name?.lexeme;
      if (name == null) continue;
      final typeSlice = inner.type != null
          ? source.substring(inner.type!.offset, inner.type!.end).trim()
          : 'dynamic';
      fields.add(
        _Field(
          name: name,
          typeSource: typeSlice,
          defaultValueSource: _defaultFromFormalParameter(source, param),
          jsonKeyName: _jsonKeyFromFormalParameter(source, param),
        ),
      );
    } else if (inner is FieldFormalParameter) {
      final name = inner.name.lexeme;
      final typeSlice = inner.type != null
          ? source.substring(inner.type!.offset, inner.type!.end).trim()
          : 'dynamic';
      fields.add(
        _Field(
          name: name,
          typeSource: typeSlice,
          defaultValueSource: _defaultFromFormalParameter(source, param),
          jsonKeyName: _jsonKeyFromFormalParameter(source, param),
        ),
      );
    }
  }
  return fields;
}

List<_Field> _collectFields(
  String source,
  ClassDeclaration impl,
) {
  final fields = <_Field>[];
  for (final m in _classMembers(impl)) {
    if (m is! FieldDeclaration) continue;
    if (m.staticKeyword != null) continue;
    final typeSlice = m.fields.type != null
        ? source.substring(m.fields.type!.offset, m.fields.type!.end).trim()
        : 'dynamic';
    final defaultSrc = _defaultAnnotationArgumentSource(source, m);
    for (final v in m.fields.variables) {
      fields.add(
        _Field(
          name: v.name.lexeme,
          typeSource: typeSlice,
          defaultValueSource: defaultSrc,
          jsonKeyName: _jsonKeyNameFromMetadata(m),
        ),
      );
    }
  }
  if (fields.isNotEmpty) return fields;
  final ctor = _unnamedGenerativeConstructor(impl);
  if (ctor == null) return fields;
  return _collectFieldsFromFormalParameters(source, ctor.parameters);
}

ConstructorDeclaration? _unnamedGenerativeConstructor(
  ClassDeclaration c,
) {
  for (final m in _classMembers(c)) {
    if (m is! ConstructorDeclaration) continue;
    if (m.factoryKeyword != null) continue;
    if (m.externalKeyword != null) continue;
    if (m.name != null) continue;
    return m;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Constructor parameter formatting
// ---------------------------------------------------------------------------

String _constDefaultInitializerExpression(String source) {
  final s = source.trim();
  if (s.startsWith('const ')) return s;
  if (s == '[]') return 'const []';
  if (s == '{}') return 'const {}';
  if (s.startsWith('<') && (s.endsWith('[]') || s.endsWith('{}'))) {
    return 'const $s';
  }
  return source;
}

String _implConstructorParamsThisFormals(List<_Field> fields) {
  if (fields.isEmpty) return '()';
  final params = fields
      .map((f) {
        final d = f.defaultValueSource;
        if (d != null) {
          return 'this.${f.name} = '
              '${_constDefaultInitializerExpression(d)}';
        }
        final requiredKw = _fieldIsRequiredInitializingFormal(f)
            ? 'required '
            : '';
        return '${requiredKw}this.${f.name}';
      })
      .join(',\n    ');
  return '({\n    $params,\n  })';
}

bool _fieldIsRequiredInitializingFormal(_Field f) {
  if (f.defaultValueSource != null) return false;
  final t = f.typeSource.trim();
  if (t == 'dynamic') return false;
  return !t.endsWith('?');
}
