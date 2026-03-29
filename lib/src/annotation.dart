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
class Lockd {
  const Lockd();
}

/// Annotation that marks a field for a default value.
///
/// ```dart
/// @Default('John Doe')
/// String name;
/// ```
class Default {
  const Default(this.defaultValue);

  final Object? defaultValue;
}

/// Annotation that marks a field to have specific name in JSON.
///
/// ```dart
/// @JsonKey('name')
/// String name;
/// ```
class JsonKey {
  const JsonKey(this.name);

  final String name;
}

/// Annotation that marks a field for a JSON value.
///
/// ```dart
/// @JsonValue('John Doe')
/// String name;
/// ```
class JsonValue {
  const JsonValue(this.value);

  final Object? value;
}
