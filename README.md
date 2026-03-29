# lockd

A lightweight Dart code generator that produces `copyWith`, `toString`, and optional JSON serialisation for immutable data classes — no `build_runner` required.

## Quick start

### 1. Add the dependency

```yaml
dependencies:
  lockd:
    git:
      url: https://github.com/jtdLab/lockd
```

### 2. Define a data class

```dart
import 'package:lockd/lockd.dart';

part 'user.lockd.dart';

@lockd
abstract class User with _$User {
  const factory User({
    required String name,
    required int age,
    String? nickname,
  }) = _User;
}
```

### 3. Run the generator

```sh
dart run lockd
```

This produces `user.lockd.dart` containing:

- A **mixin** (`_$User`) with typed getters and a `copyWith` accessor.
- A **copyWith class** for convenient immutable updates.
- A **private implementation** (`_User`) with `toString`.

## Opt-in model

Generation is fully opt-in. A class is processed only when **both** conditions are met:

1. The class is annotated with `@lockd`.
2. The host library declares the generated part file (e.g. `part 'user.lockd.dart';`).

Files without either are silently skipped.

## JSON serialisation

Add a `fromJson` factory redirect to enable `fromJson` / `toJson` generation:

```dart
@lockd
abstract class User with _$User {
  const factory User({
    required String name,
    required int age,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) = _User.fromJson(json);
}
```

The generated code handles primitives, `DateTime`, `Duration`, `List<T>`, nested objects, nullable fields, and enums out of the box.

## Annotations

| Annotation          | Target        | Description                                       |
| ------------------- | ------------- | ------------------------------------------------- |
| `@lockd`            | class         | Marks a class for code generation.                |
| `@Default(value)`   | field         | Sets a default value for a constructor parameter. |
| `@JsonKey('name')`  | field         | Overrides the JSON key for a field.               |
| `@JsonValue(value)` | enum constant | Overrides the JSON wire value for an enum case.   |

## Part files

lockd correctly handles Dart `part` / `part of` relationships. When a data class lives in a part file:

```
lib/
  login_password.dart                          # host library
  login_password/
    login_password_state.dart                  # part of '../login_password.dart'
```

The generated `.lockd.dart` file is placed next to the **host library**, not the part file, and the `part of` directive references the host:

```dart
// login_password.lockd.dart
part of 'login_password.dart';
```

All part files belonging to the same library are aggregated into a single generated output.

## Configuration

Create a `lockd.yaml` file next to your `pubspec.yaml`:

```yaml
gen:
  # Glob patterns controlling which files are scanned (default: lib/**.dart)
  include:
    - lib/models/**.dart
    - lib/state/**.dart

  # JSON key style when @JsonKey is not specified
  # Options: camel (default), snake, kebab, pascal
  field_rename: snake
```

### `gen.include`

A list of glob patterns. Only matching `.dart` files are considered. Defaults to `lib/**.dart` when omitted.

### `gen.field_rename`

Controls how Dart field names are transformed into JSON map keys:

| Value    | Input       | Output       |
| -------- | ----------- | ------------ |
| `camel`  | `firstName` | `firstName`  |
| `snake`  | `firstName` | `first_name` |
| `kebab`  | `firstName` | `first-name` |
| `pascal` | `firstName` | `FirstName`  |

## Enum support

Enums used in data class fields are automatically wired for JSON with a string map. Use `@JsonValue` to customise wire values:

```dart
enum Status {
  @JsonValue(0)
  active,
  @JsonValue(1)
  inactive,
}
```
