/// Annotation that marks a class for lockd code generation.
///
/// ```dart
/// @lockd
/// abstract class User with _$User {
///   const factory User({required String name}) = _User;
/// }
/// ```
const lockd = Lockd();

/// Annotation class for [lockd].
///
/// Use the default [lockd] constant for standard behaviour, or construct
/// directly to configure sealed-class options:
///
/// ```dart
/// @Lockd(unionKey: 'kind')
/// sealed class Event with _$Event { ... }
/// ```
class Lockd {
  /// Creates a [Lockd] annotation.
  ///
  /// [unionKey] is the JSON discriminator field name used for sealed class
  /// union serialisation (default `'type'`).
  const Lockd({this.unionKey = 'type'});

  /// JSON discriminator field name for sealed union types.
  final String unionKey;
}

/// Annotation that marks a field for a default value.
///
/// ```dart
/// @Default('John Doe')
/// String name;
/// ```
class Default {
  /// Creates a [Default] annotation with the given [defaultValue].
  const Default(this.defaultValue);

  /// The default value for the field.
  final Object? defaultValue;
}

/// Annotation that marks a field to have a specific name in JSON.
///
/// ```dart
/// @JsonKey('name')
/// String name;
/// ```
class JsonKey {
  /// Creates a [JsonKey] annotation with the given [name].
  const JsonKey(this.name);

  /// The JSON key name.
  final String name;
}

/// Annotation that marks an enum constant with a custom JSON wire value.
///
/// ```dart
/// @JsonValue(0)
/// active,
/// ```
class JsonValue {
  /// Creates a [JsonValue] annotation with the given [value].
  const JsonValue(this.value);

  /// The JSON wire value.
  final Object? value;
}
