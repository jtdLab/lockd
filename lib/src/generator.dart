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
  };
}

bool _hasLockdAnnotation(ClassDeclaration decl) {
  for (final meta in decl.metadata) {
    final name = _annotationSimpleName(meta);
    if (name == 'lockd' || name == 'Lockd') return true;
  }
  return false;
}

String _lockdUnionKey(ClassDeclaration decl) {
  for (final meta in decl.metadata) {
    final name = _annotationSimpleName(meta);
    if (name != 'lockd' && name != 'Lockd') continue;
    final args = meta.arguments;
    if (args == null) continue;
    for (final arg in args.arguments) {
      if (arg is NamedArgument && arg.name.lexeme == 'unionKey') {
        final expr = arg.argumentExpression;
        if (expr is SimpleStringLiteral) return expr.value;
        if (expr is StringLiteral) return expr.stringValue ?? 'type';
      }
    }
  }
  return 'type';
}

String? _jsonKeyNameFromAnnotation(Annotation meta) {
  final args = meta.arguments;
  if (args == null) return null;
  for (final arg in args.arguments) {
    if (arg is NamedArgument && arg.name.lexeme == 'name') {
      final expr = arg.argumentExpression;
      if (expr is SimpleStringLiteral) return expr.value;
      if (expr is StringLiteral) return expr.stringValue;
    }
  }
  for (final arg in args.arguments) {
    if (arg is NamedArgument) continue;
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
  final allSealed = <_SealedUnionEmitModel>[];
  for (final src in librarySources) {
    final parsed = parseString(content: src, throwIfDiagnostics: false);
    final unit = parsed.unit;
    allModels.addAll(
      _parseCopyableEmitModels(
        src,
        unit: unit,
        libraryEnums: mergedEnums,
        fieldRename: fieldRename,
      ),
    );
    allSealed.addAll(
      _parseSealedUnionModels(
        src,
        unit: unit,
        libraryEnums: mergedEnums,
        fieldRename: fieldRename,
      ),
    );
  }
  if (allModels.isEmpty && allSealed.isEmpty) return '';

  final enumPart = _libraryEnumJsonHelpers(
    mergedEnums,
    models: allModels,
    sealedUnions: allSealed,
  );

  final needsUnset = allModels.any((m) => m.fields.isNotEmpty) ||
      allSealed.any((s) => s.variants.any((v) => v.fields.isNotEmpty));

  if (!needsUnset && enumPart.isEmpty) return '';

  return _composeHelpersBody(
    includeUnset: needsUnset,
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
      ..write('\n');
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
  final sealedModels = _parseSealedUnionModels(
    librarySource,
    unit: unit,
    libraryEnums: libraryEnums,
    fieldRename: fieldRename,
  );
  if (models.isEmpty && sealedModels.isEmpty) return '';
  final enumHelpers = includeEnumHelpers
      ? _libraryEnumJsonHelpers(
          libraryEnums,
          models: models,
          sealedUnions: sealedModels,
        )
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
      for (final s in sealedModels) ...[
        '// ########################################################',
        '// ${s.publicName}',
        '// ########################################################',
        '',
        _sealedMixin(s),
        '',
        for (final v in s.variants) ...[
          if (v.fields.isNotEmpty) ...[
            _sealedVariantCopyWith(v),
            '',
          ],
          _sealedVariantImpl(s, v),
          '',
        ],
        if (s.hasFromJson) ...[
          _sealedDispatcher(s),
          '',
        ],
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
  String get copyWithInterfaceName => '\$${publicName}CopyWith';
  String get copyWithImplName => '_\$${publicName}CopyWithImpl';
}

// ---------------------------------------------------------------------------
// Sealed union model
// ---------------------------------------------------------------------------

class _SealedVariant {
  _SealedVariant({
    required this.constructorName,
    required this.implName,
    required this.fields,
    required this.ctorIsConst,
  });

  final String constructorName;
  final String implName;
  final List<_Field> fields;
  final bool ctorIsConst;

  String get copyWithInterfaceName => '\$${implName}CopyWith';
  String get copyWithImplName => '_\$${implName}CopyWithImpl';
}

class _SealedUnionEmitModel {
  _SealedUnionEmitModel({
    required this.publicName,
    required this.hasFromJson,
    required this.unionKey,
    required this.variants,
    required this.libraryEnums,
    required this.fieldRename,
  });

  final String publicName;
  final bool hasFromJson;
  final String unionKey;
  final List<_SealedVariant> variants;
  final Map<String, List<LockdEnumWire>> libraryEnums;
  final LockdFieldRename fieldRename;

  String get mixinName => '_\$$publicName';
  String get dispatcherName => '_$publicName';

  late final Map<String, String> sharedFields = _computeSharedMixinFields(variants);
}

/// Computes fields that are present in every variant with a compatible type.
/// If any variant has the field as nullable, the mixin type is nullable.
Map<String, String> _computeSharedMixinFields(List<_SealedVariant> variants) {
  if (variants.isEmpty) return {};

  final candidates = <String, String>{
    for (final f in variants.first.fields) f.name: f.typeSource,
  };
  for (var i = 1; i < variants.length; i++) {
    final vFields = {for (final f in variants[i].fields) f.name: f.typeSource};
    candidates.removeWhere((name, _) => !vFields.containsKey(name));
    for (final name in candidates.keys.toList()) {
      final merged = _mergeFieldTypes(candidates[name]!, vFields[name]!);
      if (merged == null) {
        candidates.remove(name);
      } else {
        candidates[name] = merged;
      }
    }
  }
  return candidates;
}

String? _mergeFieldTypes(String a, String b) {
  final aBase = _fieldTypeWithoutTrailingNullMarkers(a);
  final bBase = _fieldTypeWithoutTrailingNullMarkers(b);
  if (aBase != bBase) return null;
  if (_fieldTypeIsNullable(a) || _fieldTypeIsNullable(b)) return '$aBase?';
  return aBase;
}

// ---------------------------------------------------------------------------
// Mixin
// ---------------------------------------------------------------------------

String _mixinCopyable(_CopyableEmitModel m) {
  final getters = m.fields
      .map((f) => '  ${f.typeSource} get ${f.name};')
      .join('\n\n');

  final copyWithGetter = m.fields.isEmpty
      ? '  ${m.copyWithName} get copyWith => const ${m.copyWithName}();'
      : '  ${m.copyWithInterfaceName} get copyWith => '
            '${m.copyWithImplName}(this);';
  final parts = <String>[
    if (getters.isNotEmpty) getters,
    copyWithGetter,
    if (m.hasFromJson) '  Map<String, dynamic> toJson();',
  ];
  return 'mixin ${m.mixinName} {\n${parts.join('\n\n')}\n}';
}

// ---------------------------------------------------------------------------
// CopyWith class
// ---------------------------------------------------------------------------

String _classCopyWith(_CopyableEmitModel m) {
  if (m.fields.isEmpty) {
    return '''
class ${m.copyWithName} {
  const ${m.copyWithName}();

  ${m.publicName} call() {
    return ${m.publicName}();
  }
}'''
        .trim();
  }

  const unset = '_unset';
  final typedParams = _copyWithInterfaceParams(m.fields);
  final params = m.fields.map((f) => '    Object? ${f.name} = $unset,').join('\n');

  final body = 'return ${m.publicName}(\n'
      '      ${m.fields.map((f) => '${f.name}: _pick<${f.typeSource}>(${f.name}, _v.${f.name})').join(',\n      ')},\n'
      '    );';

  return '''
abstract class ${m.copyWithInterfaceName} {
  ${m.publicName} call({
$typedParams
  });
}

class ${m.copyWithImplName} implements ${m.copyWithInterfaceName} {
  ${m.copyWithImplName}(this._v);

  final ${m.mixinName} _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  @override
  ${m.publicName} call({
$params
  }) {
    $body
  }
}'''
      .trim();
}

/// Typed optional parameters for a `copyWith` interface: every field type
/// widened to nullable so callers may omit it. The implementation overrides
/// them as `Object? = _unset`, so an explicit `null` still reaches the field.
String _copyWithInterfaceParams(List<_Field> fields) => fields
    .map((f) => '    ${_nullableTypeSource(f.typeSource)} ${f.name},')
    .join('\n');

String _nullableTypeSource(String typeSource) {
  final t = typeSource.trim();
  if (t == 'dynamic' || _fieldTypeIsNullable(t)) return t;
  return '$t?';
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

/// Parses `Map<K, V>` into key/type argument strings (handles nested generics).
(String, String)? _mapKeyAndValueTypesIfMap(String baseNonNull) {
  final t = baseNonNull.trim();
  final head = RegExp(r'^Map\s*<').firstMatch(t);
  if (head == null) return null;
  final innerStart = head.end;
  var depth = 1;
  var i = innerStart;
  for (; i < t.length; i++) {
    final ch = t[i];
    if (ch == '<') {
      depth++;
    } else if (ch == '>') {
      depth--;
      if (depth == 0) {
        break;
      }
    }
  }
  if (depth != 0 || i >= t.length) return null;
  final inner = t.substring(innerStart, i).trim();
  var angleDepth = 0;
  int? commaIdx;
  for (var j = 0; j < inner.length; j++) {
    final c = inner[j];
    if (c == '<') {
      angleDepth++;
    } else if (c == '>') {
      angleDepth--;
    } else if (c == ',' && angleDepth == 0) {
      commaIdx = j;
      break;
    }
  }
  if (commaIdx == null) return null;
  final key = inner.substring(0, commaIdx).trim();
  final value = inner.substring(commaIdx + 1).trim();
  return (key, value);
}

bool _compactTypeEq(String a, String b) =>
    a.replaceAll(RegExp(r'\s+'), '') == b.replaceAll(RegExp(r'\s+'), '');

bool _isRecursiveJsonNestedMapValue(String valueNonNull) {
  final compact = valueNonNull.replaceAll(RegExp(r'\s+'), '');
  if (compact == 'Map<String,dynamic>') return true;
  final kv = _mapKeyAndValueTypesIfMap(valueNonNull.trim());
  if (kv == null) return false;
  if (!_compactTypeEq(kv.$1, 'String')) return false;
  return _isRecursiveJsonNestedMapValue(
    _fieldTypeWithoutTrailingNullMarkers(kv.$2),
  );
}

/// Decodes nested `Map<String, Map<String, dynamic>>` from raw JSON maps.
String _nestedStringKeyedMapFromJsonExpr(String mapTypeNonNull, String jsonExpr) {
  final compact = mapTypeNonNull.replaceAll(RegExp(r'\s+'), '');
  if (compact == 'Map<String,dynamic>') {
    return '$jsonExpr as Map<String, dynamic>';
  }
  final kv = _mapKeyAndValueTypesIfMap(mapTypeNonNull.trim());
  if (kv == null) {
    throw StateError('Invalid nested JSON map type: $mapTypeNonNull');
  }
  final valueType = _fieldTypeWithoutTrailingNullMarkers(kv.$2.trim());
  final inner = _nestedStringKeyedMapFromJsonExpr(valueType, 'v');
  return '($jsonExpr as Map<String, dynamic>).map((k, v) => MapEntry(k, $inner))';
}

/// Serializes nested JSON map values for `toJson` (inverse of [_nestedStringKeyedMapFromJsonExpr]).
///
/// [valueExpr] is the Dart receiver (e.g. `m` or `m?` when the outer map field is nullable).
String _toJsonNestedJsonMapValueExpr(String mapTypeNonNull, String valueExpr) {
  final compact = mapTypeNonNull.replaceAll(RegExp(r'\s+'), '');
  if (compact == 'Map<String,dynamic>') return valueExpr;
  final kv = _mapKeyAndValueTypesIfMap(mapTypeNonNull.trim());
  if (kv == null) return valueExpr;
  final innerVt = _fieldTypeWithoutTrailingNullMarkers(kv.$2.trim());
  final innerExpr = _toJsonNestedJsonMapValueExpr(innerVt, 'v');
  return '$valueExpr.map((k, v) => MapEntry(k, $innerExpr))';
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

String? _listElementTypeIfListOf(String baseNonNull) =>
    _bracketWrappedTypeArg(baseNonNull, 'List');

String? _setElementTypeIfSetOf(String baseNonNull) =>
    _bracketWrappedTypeArg(baseNonNull, 'Set');

/// Parses `Wrapper<...>` for balanced angle brackets (e.g. `List`, `Set`).
String? _bracketWrappedTypeArg(String baseNonNull, String wrapper) {
  final t = baseNonNull.trim();
  final head = RegExp('^${RegExp.escape(wrapper)}\\s*<').firstMatch(t);
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
  mapPrimitiveValues,
  mapJsonNestedValues,
  mapEnumValues,
  mapDateTimeValues,
  mapDurationValues,
  mapUint8ListValues,
  mapObjectValues,
  setPrimitive,
  setDateTime,
  setDuration,
  setObject,
  setEnum,
  setUint8List,
}

_JsonFieldShape _shapeForMapValueType(
  String valueNonNull,
  Map<String, List<LockdEnumWire>> libraryEnums,
) {
  if (_isRecursiveJsonNestedMapValue(valueNonNull)) {
    return _JsonFieldShape.mapJsonNestedValues;
  }
  if (libraryEnums.containsKey(_enumLookupKey(valueNonNull))) {
    return _JsonFieldShape.mapEnumValues;
  }
  if (_isUint8ListBase(valueNonNull)) return _JsonFieldShape.mapUint8ListValues;
  if (_isDateTimeBase(valueNonNull)) return _JsonFieldShape.mapDateTimeValues;
  if (_isDurationBase(valueNonNull)) return _JsonFieldShape.mapDurationValues;
  if (_isJsonPrimitiveBase(valueNonNull)) return _JsonFieldShape.mapPrimitiveValues;
  return _JsonFieldShape.mapObjectValues;
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
  Map<String, List<LockdEnumWire>> enumRegistry, {
  List<_CopyableEmitModel> models = const [],
  List<_SealedUnionEmitModel> sealedUnions = const [],
}) {
  final enums = <String>{};
  for (final m in models) {
    if (!m.hasFromJson) continue;
    enums.addAll(_sortedEnumTypesForWire(m.fields, enumRegistry));
  }
  for (final s in sealedUnions) {
    if (!s.hasFromJson) continue;
    for (final v in s.variants) {
      enums.addAll(_sortedEnumTypesForWire(v.fields, enumRegistry));
    }
  }
  if (enums.isEmpty) return '';

  final lib = enumRegistry;
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
    final mapKv = _mapKeyAndValueTypesIfMap(base);
    if (mapKv != null && _compactTypeEq(mapKv.$1, 'String')) {
      final vk = _enumLookupKey(_fieldTypeWithoutTrailingNullMarkers(mapKv.$2));
      if (libraryEnums.containsKey(vk)) ids.add(vk);
    }
    final inner =
        _listElementTypeIfListOf(base) ?? _setElementTypeIfSetOf(base);
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
  final listInner = _listElementTypeIfListOf(base);
  final setInner =
      listInner != null ? null : _setElementTypeIfSetOf(base);
  final inner = listInner ?? setInner;
  final asSet = setInner != null;
  if (inner != null) {
    final innerNonNull = _fieldTypeWithoutTrailingNullMarkers(inner);
    if (libraryEnums.containsKey(_enumLookupKey(inner))) {
      return asSet ? _JsonFieldShape.setEnum : _JsonFieldShape.listEnum;
    }
    if (_isUint8ListBase(innerNonNull)) {
      return asSet ? _JsonFieldShape.setUint8List : _JsonFieldShape.listUint8List;
    }
    if (_isDateTimeBase(innerNonNull)) {
      return asSet ? _JsonFieldShape.setDateTime : _JsonFieldShape.listDateTime;
    }
    if (_isDurationBase(innerNonNull)) {
      return asSet ? _JsonFieldShape.setDuration : _JsonFieldShape.listDuration;
    }
    if (_isJsonPrimitiveBase(innerNonNull)) {
      return asSet ? _JsonFieldShape.setPrimitive : _JsonFieldShape.listPrimitive;
    }
    return asSet ? _JsonFieldShape.setObject : _JsonFieldShape.listObject;
  }
  final mapKv = _mapKeyAndValueTypesIfMap(base);
  if (mapKv != null && _compactTypeEq(mapKv.$1, 'String')) {
    final fullCompact = base.replaceAll(RegExp(r'\s+'), '');
    if (fullCompact != 'Map<String,dynamic>') {
      final valueNonNull = _fieldTypeWithoutTrailingNullMarkers(mapKv.$2);
      return _shapeForMapValueType(valueNonNull, libraryEnums);
    }
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

/// Builds the `fromJson` assignment for [f].
///
/// When the field declares a `@Default(...)`, an absent or `null` JSON value
/// falls back to that default instead of being cast (which would throw for a
/// non-nullable field, e.g. `json['unreadByOwner'] as int`). This mirrors the
/// behaviour of json_serializable's `json['key'] ?? default`.
String _fromJsonAssignment(_Field f, _CopyableEmitModel m) {
  final expr = _fromJsonPresentValueExpr(f, m);
  final defaultSource = f.defaultValueSource;
  if (defaultSource == null) return expr;
  final jk = _jsonMapKeyForField(f, m.fieldRename);
  final jx = _jsonBracketExpr(jk);
  return '$jx == null ? $defaultSource : $expr';
}

/// Decodes the JSON value for [f] assuming the key is present and non-null.
String _fromJsonPresentValueExpr(_Field f, _CopyableEmitModel m) {
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
    case _JsonFieldShape.mapPrimitiveValues:
      final mapKv =
          _mapKeyAndValueTypesIfMap(_fieldTypeWithoutTrailingNullMarkers(f.typeSource))!;
      final vt = _fieldTypeWithoutTrailingNullMarkers(mapKv.$2.trim());
      return wrapNullable(
        '($jx as Map<String, dynamic>)'
        '.map((k, v) => MapEntry(k, v as $vt))',
      );
    case _JsonFieldShape.mapJsonNestedValues:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final expr = _nestedStringKeyedMapFromJsonExpr(baseNonNull, jx);
      return wrapNullable(expr);
    case _JsonFieldShape.mapEnumValues:
      final mapKv =
          _mapKeyAndValueTypesIfMap(_fieldTypeWithoutTrailingNullMarkers(f.typeSource))!;
      final vt = _fieldTypeWithoutTrailingNullMarkers(mapKv.$2.trim());
      final t = _enumLookupKey(vt);
      final dec = _enumJsonDecodeIdentifier(t);
      final cast = _enumTypeWireIsInt(libraryEnums, t) ? 'int' : 'String';
      return wrapNullable(
        '($jx as Map<String, dynamic>)'
        '.map((k, v) => MapEntry(k, $dec(v as $cast)))',
      );
    case _JsonFieldShape.mapDateTimeValues:
      return wrapNullable(
        '($jx as Map<String, dynamic>)'
        '.map((k, v) => MapEntry(k, DateTime.parse(v as String)))',
      );
    case _JsonFieldShape.mapDurationValues:
      return wrapNullable(
        '($jx as Map<String, dynamic>)'
        '.map((k, v) => MapEntry(k, Duration(microseconds: v as int)))',
      );
    case _JsonFieldShape.mapUint8ListValues:
      return wrapNullable(
        '($jx as Map<String, dynamic>).map((k, v) => MapEntry(k, '
        'Uint8List.fromList((v as List<dynamic>)'
        '.map((b) => (b as num).toInt()).toList())))',
      );
    case _JsonFieldShape.mapObjectValues:
      final mapKv =
          _mapKeyAndValueTypesIfMap(_fieldTypeWithoutTrailingNullMarkers(f.typeSource))!;
      final vt = _fieldTypeWithoutTrailingNullMarkers(mapKv.$2.trim());
      return wrapNullable(
        '($jx as Map<String, dynamic>)'
        '.map((k, v) => MapEntry(k, $vt.fromJson(v as Map<String, dynamic>)))',
      );
    case _JsonFieldShape.listPrimitive:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull)!;
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => e as $inner).toList()',
      );
    case _JsonFieldShape.setPrimitive:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _setElementTypeIfSetOf(baseNonNull)!;
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => e as $inner).toSet()',
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
    case _JsonFieldShape.setDateTime:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _setElementTypeIfSetOf(baseNonNull)!;
      final innerElNullable = _fieldTypeIsNullable(inner);
      final mapExpr = innerElNullable
          ? '(e) => e == null '
                '? null : DateTime.parse(e as String)'
          : '(e) => DateTime.parse(e as String)';
      return wrapNullable(
        '($jx as List<dynamic>).map($mapExpr).toSet()',
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
    case _JsonFieldShape.setDuration:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _setElementTypeIfSetOf(baseNonNull)!;
      final innerElNullable = _fieldTypeIsNullable(inner);
      final mapExpr = innerElNullable
          ? '(e) => e == null '
                '? null : Duration(microseconds: e as int)'
          : '(e) => Duration(microseconds: e as int)';
      return wrapNullable(
        '($jx as List<dynamic>).map($mapExpr).toSet()',
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
    case _JsonFieldShape.setEnum:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _setElementTypeIfSetOf(baseNonNull)!;
      final t = _enumLookupKey(inner);
      final dec = _enumJsonDecodeIdentifier(t);
      final cast = _enumTypeWireIsInt(libraryEnums, t) ? 'int' : 'String';
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => $dec(e as $cast)).toSet()',
      );
    case _JsonFieldShape.listUint8List:
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => Uint8List.fromList('
        '(e as List<dynamic>)'
        '.map((b) => (b as num).toInt()).toList())).toList()',
      );
    case _JsonFieldShape.setUint8List:
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => Uint8List.fromList('
        '(e as List<dynamic>)'
        '.map((b) => (b as num).toInt()).toList())).toSet()',
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
    case _JsonFieldShape.setObject:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _setElementTypeIfSetOf(baseNonNull)!;
      final innerClass = _fieldTypeWithoutTrailingNullMarkers(inner);
      return wrapNullable(
        '($jx as List<dynamic>)'
        '.map((e) => $innerClass.fromJson('
        'e as Map<String, dynamic>)).toSet()',
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
    case _JsonFieldShape.mapPrimitiveValues:
      return f.name;
    case _JsonFieldShape.setPrimitive:
      // A Set is not JSON: `jsonEncode` rejects it, and `fromJson` reads the
      // field back as a List anyway — so it is written as one.
      return nullable ? '${f.name}?.toList()' : '${f.name}.toList()';
    case _JsonFieldShape.mapJsonNestedValues:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final recv = nullable ? '${f.name}?' : f.name;
      return _toJsonNestedJsonMapValueExpr(baseNonNull, recv);
    case _JsonFieldShape.mapEnumValues:
      final mapKv =
          _mapKeyAndValueTypesIfMap(_fieldTypeWithoutTrailingNullMarkers(f.typeSource))!;
      final vt = _fieldTypeWithoutTrailingNullMarkers(mapKv.$2.trim());
      final t = _enumLookupKey(vt);
      final mapName = _enumJsonMapIdentifier(t);
      if (nullable) {
        return '${f.name}?.map((k, v) => MapEntry(k, $mapName[v]!))';
      }
      return '${f.name}.map((k, v) => MapEntry(k, $mapName[v]!))';
    case _JsonFieldShape.mapDateTimeValues:
      if (nullable) {
        return '${f.name}?.map((k, v) => MapEntry(k, v.toIso8601String()))';
      }
      return '${f.name}.map((k, v) => MapEntry(k, v.toIso8601String()))';
    case _JsonFieldShape.mapDurationValues:
      if (nullable) {
        return '${f.name}?.map((k, v) => MapEntry(k, v.inMicroseconds))';
      }
      return '${f.name}.map((k, v) => MapEntry(k, v.inMicroseconds))';
    case _JsonFieldShape.mapUint8ListValues:
      if (nullable) {
        return '${f.name}?.map((k, v) => MapEntry(k, v.toList()))';
      }
      return '${f.name}.map((k, v) => MapEntry(k, v.toList()))';
    case _JsonFieldShape.mapObjectValues:
      if (nullable) {
        return '${f.name}?.map((k, v) => MapEntry(k, v.toJson()))';
      }
      return '${f.name}.map((k, v) => MapEntry(k, v.toJson()))';
    case _JsonFieldShape.dateTime:
      return nullable
          ? '${f.name}?.toIso8601String()'
          : '${f.name}.toIso8601String()';
    case _JsonFieldShape.duration:
      return nullable
          ? '${f.name}?.inMicroseconds'
          : '${f.name}.inMicroseconds';
    case _JsonFieldShape.listDateTime:
    case _JsonFieldShape.setDateTime:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull) ??
          _setElementTypeIfSetOf(baseNonNull)!;
      final innerElNullable = _fieldTypeIsNullable(inner);
      final mapBody = innerElNullable
          ? '(e) => e?.toIso8601String()'
          : '(e) => e.toIso8601String()';
      if (nullable) return '${f.name}?.map($mapBody).toList()';
      return '${f.name}.map($mapBody).toList()';
    case _JsonFieldShape.listDuration:
    case _JsonFieldShape.setDuration:
      final baseNonNull = _fieldTypeWithoutTrailingNullMarkers(f.typeSource);
      final inner = _listElementTypeIfListOf(baseNonNull) ??
          _setElementTypeIfSetOf(baseNonNull)!;
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
    case _JsonFieldShape.setEnum:
      final inner = _listElementTypeIfListOf(
            _fieldTypeWithoutTrailingNullMarkers(f.typeSource),
          ) ??
          _setElementTypeIfSetOf(
            _fieldTypeWithoutTrailingNullMarkers(f.typeSource),
          )!;
      final t = _enumLookupKey(inner);
      final mapName = _enumJsonMapIdentifier(t);
      if (nullable) {
        return '${f.name}?.map((e) => $mapName[e]!).toList()';
      }
      return '${f.name}.map((e) => $mapName[e]!).toList()';
    case _JsonFieldShape.listUint8List:
    case _JsonFieldShape.setUint8List:
      if (nullable) {
        return '${f.name}?.map((e) => e.toList()).toList()';
      }
      return '${f.name}.map((e) => e.toList()).toList()';
    case _JsonFieldShape.listObject:
    case _JsonFieldShape.setObject:
      final innerObj = _listElementTypeIfListOf(
            _fieldTypeWithoutTrailingNullMarkers(f.typeSource),
          ) ??
          _setElementTypeIfSetOf(
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
// Equality
// ---------------------------------------------------------------------------

/// Whether [typeSource] is a collection compared structurally (deeply) rather
/// than by reference / scalar `==`.
///
/// Covers `List`, `Set`, `Iterable`, `Map`, and `Uint8List` (which is a
/// reference-equal `List<int>` and so needs deep comparison too).
bool _fieldTypeIsCollection(String typeSource) {
  final base = _fieldTypeWithoutTrailingNullMarkers(typeSource);
  return _listElementTypeIfListOf(base) != null ||
      _setElementTypeIfSetOf(base) != null ||
      _bracketWrappedTypeArg(base, 'Iterable') != null ||
      _mapKeyAndValueTypesIfMap(base) != null ||
      _isUint8ListBase(base);
}

/// One field's `==` comparison clause.
///
/// Collections are compared with `DeepCollectionEquality`; everything else
/// (primitives, enums, nested lockd objects, `DateTime`, …) is compared with
/// `==`, short-circuited by `identical` like freezed.
String _equalityFieldClause(_Field f) {
  if (_fieldTypeIsCollection(f.typeSource)) {
    return 'const DeepCollectionEquality().equals(other.${f.name}, ${f.name})';
  }
  return '(identical(other.${f.name}, ${f.name}) || other.${f.name} == ${f.name})';
}

/// One field's contribution to `hashCode`.
String _hashCodeComponent(_Field f) {
  if (_fieldTypeIsCollection(f.typeSource)) {
    return 'const DeepCollectionEquality().hash(${f.name})';
  }
  return f.name;
}

/// Emits `operator ==` and `hashCode` overrides for the impl class [implName].
String _equalityAndHashCode(String implName, List<_Field> fields) {
  final clauses = fields.map(_equalityFieldClause).toList();
  final equalsExpr = clauses.isEmpty
      ? 'other.runtimeType == runtimeType && other is $implName'
      : 'other.runtimeType == runtimeType &&\n'
            '            other is $implName &&\n'
            '            ${clauses.join(' &&\n            ')}';

  final components = ['runtimeType', ...fields.map(_hashCodeComponent)];
  final String hashExpr;
  if (fields.isEmpty) {
    hashExpr = 'runtimeType.hashCode';
  } else if (components.length <= 20) {
    hashExpr = 'Object.hash(${components.join(', ')})';
  } else {
    hashExpr = 'Object.hashAll([${components.join(', ')}])';
  }

  return '  @override\n'
      '  bool operator ==(Object other) {\n'
      '    return identical(this, other) ||\n'
      '        ($equalsExpr);\n'
      '  }\n\n'
      '  @override\n'
      '  int get hashCode => $hashExpr;';
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
      ? m.fields.isEmpty
            ? '\n\n'
                  '  factory ${m.implName}.fromJson('
                  'Map<String, dynamic> json) {\n'
                  '    return ${m.implName}();\n'
                  '  }'
            : '\n\n'
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
      ? m.fields.isEmpty
            ? '\n\n'
                  '  Map<String, dynamic> toJson() {\n'
                  '    return {};\n'
                  '  }'
            : '\n\n'
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

  final equality = '\n\n${_equalityAndHashCode(m.implName, m.fields)}';

  return '''
class ${m.implName} with ${m.mixinName} implements ${m.publicName} {
  $head;$fromJson

$fields$toJson$equality

  @override
  String toString() =>
      $toStringBody;
}'''
      .trim();
}

// ---------------------------------------------------------------------------
// Sealed union emission
// ---------------------------------------------------------------------------

String _sealedMixin(_SealedUnionEmitModel m) {
  final shared = m.sharedFields;
  final getters =
      shared.entries.map((e) => '  ${e.value} get ${e.key};').join('\n');
  final toJson =
      m.hasFromJson ? '  Map<String, dynamic> toJson();' : '';
  final bodyParts = <String>[
    if (getters.isNotEmpty) getters,
    if (toJson.isNotEmpty) toJson,
  ];
  final body = bodyParts.join('\n\n');
  if (body.isEmpty) return 'mixin ${m.mixinName} {\n}';
  return 'mixin ${m.mixinName} {\n$body\n}';
}

String _sealedVariantCopyWith(_SealedVariant v) {
  const unset = '_unset';
  final typedParams = _copyWithInterfaceParams(v.fields);
  final params =
      v.fields.map((f) => '    Object? ${f.name} = $unset,').join('\n');
  final body =
      'return ${v.implName}(\n'
      '      ${v.fields.map((f) => '${f.name}: _pick<${f.typeSource}>(${f.name}, _v.${f.name})').join(',\n      ')},\n'
      '    );';
  return '''
abstract class ${v.copyWithInterfaceName} {
  ${v.implName} call({
$typedParams
  });
}

class ${v.copyWithImplName} implements ${v.copyWithInterfaceName} {
  ${v.copyWithImplName}(this._v);

  final ${v.implName} _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  @override
  ${v.implName} call({
$params
  }) {
    $body
  }
}'''
      .trim();
}

String _sealedVariantImpl(_SealedUnionEmitModel m, _SealedVariant v) {
  final constKw = v.ctorIsConst ? 'const ' : '';
  final head =
      '$constKw${v.implName}'
      '${_implConstructorParamsThisFormals(v.fields)}';

  final fakeModel = _CopyableEmitModel(
    publicName: v.implName,
    implName: v.implName,
    fields: v.fields,
    hasFromJson: m.hasFromJson,
    ctorIsConst: v.ctorIsConst,
    libraryEnums: m.libraryEnums,
    fieldRename: m.fieldRename,
  );

  final fromJsonBlock = m.hasFromJson
      ? () {
          if (v.fields.isEmpty) {
            return '\n\n'
                '  factory ${v.implName}.fromJson('
                'Map<String, dynamic> json) {\n'
                '    return ${constKw.isEmpty ? '' : 'const '}${v.implName}();\n'
                '  }';
          }
          return '\n\n'
              '  factory ${v.implName}.fromJson('
              'Map<String, dynamic> json) {\n'
              '    return ${v.implName}(\n'
              '      ${v.fields.map((f) => '${f.name}: ${_fromJsonAssignment(f, fakeModel)}').join(',\n      ')},\n'
              '    );\n'
              '  }';
        }()
      : '';

  final sharedNames = m.sharedFields.keys.toSet();
  final fieldsBlock = v.fields
      .map((f) {
        final prefix = sharedNames.contains(f.name) ? '  @override\n' : '';
        return '$prefix  final ${f.typeSource} ${f.name};';
      })
      .join('\n\n');

  final unionKeyLit = _dartStringLiteralFromValue(m.unionKey);
  final variantTypeLit = _dartStringLiteralFromValue(v.constructorName);
  final fieldEntries = v.fields
      .map(
        (f) =>
            '${_dartStringLiteralFromValue(_jsonMapKeyForField(f, m.fieldRename))}: ${_toJsonValueExpr(f, fakeModel)}',
      )
      .join(',\n      ');
  final toJson = m.hasFromJson
      ? '\n\n'
            '  @override\n'
            '  Map<String, dynamic> toJson() {\n'
            '    return {\n'
            '      $unionKeyLit: $variantTypeLit,\n'
            '${fieldEntries.isEmpty ? '' : '      $fieldEntries,\n'}'
            '    };\n'
            '  }'
      : '';

  final copyWith = v.fields.isNotEmpty
      ? '\n\n  ${v.copyWithInterfaceName} get copyWith => '
            '${v.copyWithImplName}(this);'
      : '';

  final fieldList =
      v.fields.map((f) => '${f.name}: \$${f.name}').join(', ');
  final toStringBody = v.fields.isEmpty
      ? "'${m.publicName}.${v.constructorName}()'"
      : "'${m.publicName}.${v.constructorName}($fieldList)'";

  final body = StringBuffer()
    ..write(
      'class ${v.implName} with ${m.mixinName} '
      'implements ${m.publicName} {\n'
      '  $head;$fromJsonBlock',
    );
  if (fieldsBlock.isNotEmpty) {
    body.write('\n\n$fieldsBlock');
  }
  body.write(
    '$copyWith$toJson\n\n'
    '${_equalityAndHashCode(v.implName, v.fields)}\n\n'
    '  @override\n'
    '  String toString() =>\n'
    '      $toStringBody;\n'
    '}',
  );
  return body.toString().trim();
}

String _sealedDispatcher(_SealedUnionEmitModel m) {
  final unionKeyLit = _dartStringLiteralFromValue(m.unionKey);
  final cases = m.variants.map((v) {
    final lit = _dartStringLiteralFromValue(v.constructorName);
    return '      $lit => ${v.implName}.fromJson(json),';
  }).join('\n');

  return '''
class ${m.dispatcherName} {
  ${m.dispatcherName}._();

  static ${m.publicName} fromJson(Map<String, dynamic> json) {
    return switch (json[$unionKeyLit] as String) {
$cases
      final unknown => throw ArgumentError.value(
        unknown,
        ${_dartStringLiteralFromValue(m.unionKey)},
        'Unknown union type',
      ),
    };
  }
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

List<_SealedUnionEmitModel> _parseSealedUnionModels(
  String source, {
  CompilationUnit? unit,
  Map<String, List<LockdEnumWire>>? libraryEnums,
  LockdFieldRename fieldRename = LockdFieldRename.camel,
}) {
  final resolvedUnit =
      unit ?? parseString(content: source, throwIfDiagnostics: false).unit;
  final libEnums = libraryEnums ?? _collectLibraryEnums(source, resolvedUnit);
  final out = <_SealedUnionEmitModel>[];

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

    // Collect named factory constructors with redirects to public classes.
    final variants = <_SealedVariant>[];
    for (final m in _classMembers(decl)) {
      if (m is! ConstructorDeclaration) continue;
      if (m.factoryKeyword == null) continue;
      if (m.redirectedConstructor == null) continue;
      final ctorName = m.name?.lexeme;
      if (ctorName == null || ctorName == 'fromJson') continue;
      final implName = m.redirectedConstructor!.type.name.lexeme;
      if (implName == '_$publicName') continue;

      final fields = _collectFieldsFromFormalParameters(source, m.parameters);
      variants.add(
        _SealedVariant(
          constructorName: ctorName,
          implName: implName,
          fields: fields,
          ctorIsConst: m.constKeyword != null,
        ),
      );
    }

    if (variants.isEmpty) continue;

    out.add(
      _SealedUnionEmitModel(
        publicName: publicName,
        hasFromJson: hasFromJson,
        unionKey: _lockdUnionKey(decl),
        variants: variants,
        libraryEnums: libEnums,
        fieldRename: fieldRename,
      ),
    );
  }

  return out;
}

// ---------------------------------------------------------------------------
// Formal parameter helpers
// ---------------------------------------------------------------------------

// Analyzer 13 removed `DefaultFormalParameter` (defaults are now a
// `defaultClause` on every parameter) and merged `SimpleFormalParameter` +
// `FunctionTypedFormalParameter` into `RegularFormalParameter`. A
// `RegularFormalParameter` without a `functionTypedSuffix` is exactly what
// used to be a `SimpleFormalParameter`; matching on that keeps the old
// behaviour of ignoring old-style function-typed parameters.

String? _formalParameterName(FormalParameter param) {
  return switch (param) {
    RegularFormalParameter(:final name?, functionTypedSuffix: null) =>
      name.lexeme,
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
  return switch (param) {
    RegularFormalParameter(functionTypedSuffix: null) ||
    FieldFormalParameter() => _defaultAnnotationArgumentSource(source, param),
    _ => null,
  };
}

String? _jsonKeyFromFormalParameter(
  String source,
  FormalParameter param,
) {
  return switch (param) {
    RegularFormalParameter(functionTypedSuffix: null) ||
    FieldFormalParameter() => _jsonKeyNameFromMetadata(param),
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
    if (param is RegularFormalParameter && param.functionTypedSuffix == null) {
      final name = param.name?.lexeme;
      if (name == null) continue;
      final typeSlice = param.type != null
          ? source.substring(param.type!.offset, param.type!.end).trim()
          : 'dynamic';
      fields.add(
        _Field(
          name: name,
          typeSource: typeSlice,
          defaultValueSource: _defaultFromFormalParameter(source, param),
          jsonKeyName: _jsonKeyFromFormalParameter(source, param),
        ),
      );
    } else if (param is FieldFormalParameter) {
      final name = param.name.lexeme;
      final typeSlice = param.type != null
          ? source.substring(param.type!.offset, param.type!.end).trim()
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

/// True when [source] begins with a normal constructor invocation:
/// `Foo()`, `Foo.named()`, `prefix.Foo()`, etc.
///
/// Does not match generics before `(` (use `@Default(const Foo<T>())` then).
bool _looksLikeDartConstructorInvocation(String source) {
  final s = source.trim();
  return RegExp(
    r'^(([a-zA-Z_$]\w*)\.)*[a-zA-Z_$]\w*\s*\(',
  ).hasMatch(s);
}

/// True for list / map / set literals and typed collections:
/// `[]`, `[1, 2]`, `{}`, `{'a'}`, `{'k': v}`, `<T>[]`, `<T>{}`, `<T>{...}`.
bool _looksLikeDartCollectionOrTypedLiteral(String source) {
  final s = source.trim();
  if (s.startsWith('[')) return true;
  if (s.startsWith('{')) return true;
  if (s.startsWith('<') && (s.endsWith('[]') || s.endsWith('}'))) {
    return true;
  }
  return false;
}

/// Prefixes `const` for constructor calls and collection literals so `const`
/// private ctors compile; everything else is emitted unchanged (aside from trim).
String _constDefaultInitializerExpression(String source) {
  final s = source.trim();
  if (s.startsWith('const ')) return s;
  if (_looksLikeDartConstructorInvocation(s)) return 'const $s';
  if (_looksLikeDartCollectionOrTypedLiteral(s)) return 'const $s';
  return s;
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
