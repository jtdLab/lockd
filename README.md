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

| Annotation                    | Target        | Description                                          |
| ----------------------------- | ------------- | ---------------------------------------------------- |
| `@lockd`                      | class         | Marks a class for code generation.                   |
| `@Lockd(unionKey: 'kind')`   | sealed class  | Marks a sealed class with a custom discriminator key. |
| `@Default(value)`             | field         | Sets a default value for a constructor parameter.    |
| `@JsonKey('name')`            | field         | Overrides the JSON key for a field.                  |
| `@JsonValue(value)`           | enum constant | Overrides the JSON wire value for an enum case.      |

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
# Glob patterns controlling which files are scanned (default: lib/**.dart)
include:
  - lib/models/**.dart
  - lib/state/**.dart

# JSON key style when @JsonKey is not specified
# Options: camel (default), snake, kebab, pascal
field_rename: snake
```

### `include`

A list of glob patterns. Only matching `.dart` files are considered. Defaults to `lib/**.dart` when omitted.

### `field_rename`

Controls how Dart field names are transformed into JSON map keys:

| Value    | Input       | Output       |
| -------- | ----------- | ------------ |
| `camel`  | `firstName` | `firstName`  |
| `snake`  | `firstName` | `first_name` |
| `kebab`  | `firstName` | `first-name` |
| `pascal` | `firstName` | `FirstName`  |

## Sealed classes (union types)

lockd generates variant impl classes for sealed class unions. Annotate the sealed class with `@lockd` and use named factory constructors that redirect to public variant classes:

```dart
@lockd
sealed class Event with _$Event {
  const factory Event.success({required String data}) = EventSuccess;
  const factory Event.error({required String message, required int code}) = EventError;
}
```

This generates:

- A shared **mixin** (`_$Event`)
- A **variant class** for each named constructor (`EventSuccess`, `EventError`)
- Per-variant **copyWith** (only for variants with fields)
- Per-variant **toString** using the constructor name (e.g. `Event.success(data: hello)`)

### Sealed JSON serialisation

Add a `fromJson` factory to enable JSON dispatch. Each variant's `toJson` includes a discriminator field (default `'type'`) set to the constructor name:

```dart
@lockd
sealed class Event with _$Event {
  const factory Event.success({required String data}) = EventSuccess;
  const factory Event.error({required String message}) = EventError;

  factory Event.fromJson(Map<String, dynamic> json) =>
      _Event.fromJson(json);
}
```

Generated `EventSuccess.toJson()` produces `{'type': 'success', 'data': '...'}`, and `_Event.fromJson` dispatches back to the correct variant based on the `type` field.

### Custom discriminator key

Use `@Lockd(unionKey: 'kind')` instead of `@lockd` to change the discriminator field name:

```dart
@Lockd(unionKey: 'kind')
sealed class Action with _$Action {
  const factory Action.tap() = ActionTap;
  const factory Action.swipe() = ActionSwipe;

  factory Action.fromJson(Map<String, dynamic> json) =>
      _Action.fromJson(json);
}
```

This uses `'kind'` instead of `'type'` as the JSON discriminator key.

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
