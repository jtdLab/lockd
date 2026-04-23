import 'package:lockd/src/generator.dart';
import 'package:test/test.dart';

void main() {
  group('lockdModulePartDartContents', () {
    test('non-JSON: list + non-primitive defaults', () {
      const source = r'''
@lockd
abstract class AppointmentsState with _$AppointmentsState {
  const factory AppointmentsState({
    @Default([]) List<Appointment> appointments,
    @Default(AppointmentsTab.upcoming) AppointmentsTab selectedTab,
  }) = _AppointmentsState;
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'appointments',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointments.dart';

// ###### Helpers ####

const Object _unset = Object();

// ########################################################
// AppointmentsState
// ########################################################

mixin _$AppointmentsState {
  List<Appointment> get appointments;

  AppointmentsTab get selectedTab;

  _AppointmentsStateCopyWith get copyWith => _AppointmentsStateCopyWith(this);
}

class _AppointmentsStateCopyWith {
  _AppointmentsStateCopyWith(this._v);

  final _$AppointmentsState _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  AppointmentsState call({
    Object? appointments = _unset,
    Object? selectedTab = _unset,
  }) {
    return AppointmentsState(
      appointments: _pick<List<Appointment>>(appointments, _v.appointments),
      selectedTab: _pick<AppointmentsTab>(selectedTab, _v.selectedTab),
    );
  }
}

class _AppointmentsState with _$AppointmentsState implements AppointmentsState {
  const _AppointmentsState({
    this.appointments = const [],
    this.selectedTab = AppointmentsTab.upcoming,
  });

  @override
  final List<Appointment> appointments;

  @override
  final AppointmentsTab selectedTab;

  @override
  String toString() =>
      'AppointmentsState(appointments: $appointments, selectedTab: $selectedTab)';
}
""",
      );
    });

    test('JSON: no fields — empty fromJson and toJson bodies', () {
      const source = r'''
@lockd
abstract class Subscription with _$Subscription {
  const factory Subscription() = _Subscription;
  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _Subscription.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'payments',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments.dart';

// ###### Helpers ####

const Object _unset = Object();

// ########################################################
// Subscription
// ########################################################

mixin _$Subscription {
  _SubscriptionCopyWith get copyWith => const _SubscriptionCopyWith();

  Map<String, dynamic> toJson();
}

class _SubscriptionCopyWith {
  const _SubscriptionCopyWith();

  Subscription call() {
    return Subscription();
  }
}

class _Subscription with _$Subscription implements Subscription {
  const _Subscription();

  factory _Subscription.fromJson(Map<String, dynamic> json) {
    return _Subscription();
  }

  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  String toString() => 'Subscription()';
}
""",
      );
    });

    test('JSON: list + non-primitive with fromJson/toJson', () {
      const source = r'''
@lockd
abstract class AppointmentsState with _$AppointmentsState {
  const factory AppointmentsState({
    @Default([]) List<Appointment> appointments,
    @Default(AppointmentsTab.upcoming) AppointmentsTab selectedTab,
  }) = _AppointmentsState;
  factory AppointmentsState.fromJson(Map<String, dynamic> json) =>
      _AppointmentsState.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'appointments',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointments.dart';

// ###### Helpers ####

const Object _unset = Object();

// ########################################################
// AppointmentsState
// ########################################################

mixin _$AppointmentsState {
  List<Appointment> get appointments;

  AppointmentsTab get selectedTab;

  _AppointmentsStateCopyWith get copyWith => _AppointmentsStateCopyWith(this);

  Map<String, dynamic> toJson();
}

class _AppointmentsStateCopyWith {
  _AppointmentsStateCopyWith(this._v);

  final _$AppointmentsState _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  AppointmentsState call({
    Object? appointments = _unset,
    Object? selectedTab = _unset,
  }) {
    return AppointmentsState(
      appointments: _pick<List<Appointment>>(appointments, _v.appointments),
      selectedTab: _pick<AppointmentsTab>(selectedTab, _v.selectedTab),
    );
  }
}

class _AppointmentsState with _$AppointmentsState implements AppointmentsState {
  const _AppointmentsState({
    this.appointments = const [],
    this.selectedTab = AppointmentsTab.upcoming,
  });

  factory _AppointmentsState.fromJson(Map<String, dynamic> json) {
    return _AppointmentsState(
      appointments: (json['appointments'] as List<dynamic>)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedTab: AppointmentsTab.fromJson(
        json['selectedTab'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  final List<Appointment> appointments;

  @override
  final AppointmentsTab selectedTab;

  Map<String, dynamic> toJson() {
    return {
      'appointments': appointments.map((e) => e.toJson()).toList(),
      'selectedTab': selectedTab.toJson(),
    };
  }

  @override
  String toString() =>
      'AppointmentsState(appointments: $appointments, selectedTab: $selectedTab)';
}
""",
      );
    });

    test('JSON: all primitive types (String, int, double, bool, nullable)', () {
      const source = r'''
@lockd
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String name,
    required int age,
    required double height,
    required bool isActive,
    String? nickname,
  }) = _UserProfile;
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _UserProfile.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'user',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// ###### Helpers ####

const Object _unset = Object();

// ########################################################
// UserProfile
// ########################################################

mixin _$UserProfile {
  String get name;

  int get age;

  double get height;

  bool get isActive;

  String? get nickname;

  _UserProfileCopyWith get copyWith => _UserProfileCopyWith(this);

  Map<String, dynamic> toJson();
}

class _UserProfileCopyWith {
  _UserProfileCopyWith(this._v);

  final _$UserProfile _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  UserProfile call({
    Object? name = _unset,
    Object? age = _unset,
    Object? height = _unset,
    Object? isActive = _unset,
    Object? nickname = _unset,
  }) {
    return UserProfile(
      name: _pick<String>(name, _v.name),
      age: _pick<int>(age, _v.age),
      height: _pick<double>(height, _v.height),
      isActive: _pick<bool>(isActive, _v.isActive),
      nickname: _pick<String?>(nickname, _v.nickname),
    );
  }
}

class _UserProfile with _$UserProfile implements UserProfile {
  const _UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.isActive,
    this.nickname,
  });

  factory _UserProfile.fromJson(Map<String, dynamic> json) {
    return _UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      height: json['height'] as double,
      isActive: json['isActive'] as bool,
      nickname: json['nickname'] as String?,
    );
  }

  @override
  final String name;

  @override
  final int age;

  @override
  final double height;

  @override
  final bool isActive;

  @override
  final String? nickname;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'isActive': isActive,
      'nickname': nickname,
    };
  }

  @override
  String toString() =>
      'UserProfile(name: $name, age: $age, height: $height, isActive: $isActive, nickname: $nickname)';
}
""",
      );
    });

    test('JSON: non-primitives (DateTime, Duration, object, lists, nullable)',
        () {
      const source = r'''
@lockd
abstract class AppData with _$AppData {
  const factory AppData({
    required DateTime createdAt,
    required Duration timeout,
    required Address address,
    required List<String> tags,
    required List<Address> addresses,
    List<String>? optionalTags,
  }) = _AppData;
  factory AppData.fromJson(Map<String, dynamic> json) =>
      _AppData.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'app',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app.dart';

// ###### Helpers ####

const Object _unset = Object();

// ########################################################
// AppData
// ########################################################

mixin _$AppData {
  DateTime get createdAt;

  Duration get timeout;

  Address get address;

  List<String> get tags;

  List<Address> get addresses;

  List<String>? get optionalTags;

  _AppDataCopyWith get copyWith => _AppDataCopyWith(this);

  Map<String, dynamic> toJson();
}

class _AppDataCopyWith {
  _AppDataCopyWith(this._v);

  final _$AppData _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  AppData call({
    Object? createdAt = _unset,
    Object? timeout = _unset,
    Object? address = _unset,
    Object? tags = _unset,
    Object? addresses = _unset,
    Object? optionalTags = _unset,
  }) {
    return AppData(
      createdAt: _pick<DateTime>(createdAt, _v.createdAt),
      timeout: _pick<Duration>(timeout, _v.timeout),
      address: _pick<Address>(address, _v.address),
      tags: _pick<List<String>>(tags, _v.tags),
      addresses: _pick<List<Address>>(addresses, _v.addresses),
      optionalTags: _pick<List<String>?>(optionalTags, _v.optionalTags),
    );
  }
}

class _AppData with _$AppData implements AppData {
  const _AppData({
    required this.createdAt,
    required this.timeout,
    required this.address,
    required this.tags,
    required this.addresses,
    this.optionalTags,
  });

  factory _AppData.fromJson(Map<String, dynamic> json) {
    return _AppData(
      createdAt: DateTime.parse(json['createdAt'] as String),
      timeout: Duration(microseconds: json['timeout'] as int),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      addresses: (json['addresses'] as List<dynamic>)
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
      optionalTags: json['optionalTags'] == null
          ? null
          : (json['optionalTags'] as List<dynamic>)
                .map((e) => e as String)
                .toList(),
    );
  }

  @override
  final DateTime createdAt;

  @override
  final Duration timeout;

  @override
  final Address address;

  @override
  final List<String> tags;

  @override
  final List<Address> addresses;

  @override
  final List<String>? optionalTags;

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'timeout': timeout.inMicroseconds,
      'address': address.toJson(),
      'tags': tags,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'optionalTags': optionalTags,
    };
  }

  @override
  String toString() =>
      'AppData(createdAt: $createdAt, timeout: $timeout, address: $address, tags: $tags, addresses: $addresses, optionalTags: $optionalTags)';
}
""",
      );
    });

    test('JSON: enums with enum map + list of enums', () {
      const source = r'''
enum Theme {
  light,
  dark,
  @JsonValue('system_default')
  system,
}

@lockd
abstract class Settings with _$Settings {
  const factory Settings({
    required Theme theme,
    @Default([]) List<Theme> recentThemes,
  }) = _Settings;
  factory Settings.fromJson(Map<String, dynamic> json) =>
      _Settings.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'settings',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// ###### Helpers ####

const Object _unset = Object();

const Map<Theme, String> _themeJsonMap = {
  Theme.light: 'light',
  Theme.dark: 'dark',
  Theme.system: 'system_default',
};

Theme _decodeThemeJsonMap(String v) =>
    _themeJsonMap.entries.singleWhere((e) => e.value == v).key;

// ########################################################
// Settings
// ########################################################

mixin _$Settings {
  Theme get theme;

  List<Theme> get recentThemes;

  _SettingsCopyWith get copyWith => _SettingsCopyWith(this);

  Map<String, dynamic> toJson();
}

class _SettingsCopyWith {
  _SettingsCopyWith(this._v);

  final _$Settings _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  Settings call({Object? theme = _unset, Object? recentThemes = _unset}) {
    return Settings(
      theme: _pick<Theme>(theme, _v.theme),
      recentThemes: _pick<List<Theme>>(recentThemes, _v.recentThemes),
    );
  }
}

class _Settings with _$Settings implements Settings {
  const _Settings({required this.theme, this.recentThemes = const []});

  factory _Settings.fromJson(Map<String, dynamic> json) {
    return _Settings(
      theme: _decodeThemeJsonMap(json['theme'] as String),
      recentThemes: (json['recentThemes'] as List<dynamic>)
          .map((e) => _decodeThemeJsonMap(e as String))
          .toList(),
    );
  }

  @override
  final Theme theme;

  @override
  final List<Theme> recentThemes;

  Map<String, dynamic> toJson() {
    return {
      'theme': _themeJsonMap[theme]!,
      'recentThemes': recentThemes.map((e) => _themeJsonMap[e]!).toList(),
    };
  }

  @override
  String toString() => 'Settings(theme: $theme, recentThemes: $recentThemes)';
}
""",
      );
    });
  });

  group('sealed union', () {
    test('no JSON, no fields (pure event union)', () {
      const source = r'''
@lockd
sealed class AccountCreatePresentationEvent
    with _$AccountCreatePresentationEvent {
  const factory AccountCreatePresentationEvent.createAccountFailed() =
      AccountCreatePresentationEventCreateAccountFailed;
  const factory AccountCreatePresentationEvent.createAccountSuccess() =
      AccountCreatePresentationEventCreateAccountSuccess;
  const factory AccountCreatePresentationEvent.foo() =
      AccountCreatePresentationEventFoo;
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'account_create',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_create.dart';

// ########################################################
// AccountCreatePresentationEvent
// ########################################################

mixin _$AccountCreatePresentationEvent {}

class AccountCreatePresentationEventCreateAccountFailed
    with _$AccountCreatePresentationEvent
    implements AccountCreatePresentationEvent {
  const AccountCreatePresentationEventCreateAccountFailed();

  @override
  String toString() => 'AccountCreatePresentationEvent.createAccountFailed()';
}

class AccountCreatePresentationEventCreateAccountSuccess
    with _$AccountCreatePresentationEvent
    implements AccountCreatePresentationEvent {
  const AccountCreatePresentationEventCreateAccountSuccess();

  @override
  String toString() => 'AccountCreatePresentationEvent.createAccountSuccess()';
}

class AccountCreatePresentationEventFoo
    with _$AccountCreatePresentationEvent
    implements AccountCreatePresentationEvent {
  const AccountCreatePresentationEventFoo();

  @override
  String toString() => 'AccountCreatePresentationEvent.foo()';
}
""",
      );
    });

    test('with JSON, no fields (discriminator dispatch)', () {
      const source = r'''
@lockd
sealed class Event with _$Event {
  const factory Event.a() = EventA;
  const factory Event.b() = EventB;
  factory Event.fromJson(Map<String, dynamic> json) => _Event.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'event',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// ########################################################
// Event
// ########################################################

mixin _$Event {
  Map<String, dynamic> toJson();
}

class EventA with _$Event implements Event {
  const EventA();

  factory EventA.fromJson(Map<String, dynamic> json) {
    return const EventA();
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'a'};
  }

  @override
  String toString() => 'Event.a()';
}

class EventB with _$Event implements Event {
  const EventB();

  factory EventB.fromJson(Map<String, dynamic> json) {
    return const EventB();
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'b'};
  }

  @override
  String toString() => 'Event.b()';
}

class _Event {
  _Event._();

  static Event fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'a' => EventA.fromJson(json),
      'b' => EventB.fromJson(json),
      final unknown => throw ArgumentError.value(
        unknown,
        'type',
        'Unknown union type',
      ),
    };
  }
}
""",
      );
    });

    test('with JSON, with fields on variants (full generation)', () {
      const source = r'''
@lockd
sealed class Result with _$Result {
  const factory Result.success({required String data}) = ResultSuccess;
  const factory Result.error({required String message, required int code}) = ResultError;
  factory Result.fromJson(Map<String, dynamic> json) => _Result.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'result',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// ########################################################
// Result
// ########################################################

mixin _$Result {
  Map<String, dynamic> toJson();
}

class ResultSuccessCopyWith {
  ResultSuccessCopyWith(this._v);

  final ResultSuccess _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  ResultSuccess call({Object? data = _unset}) {
    return ResultSuccess(data: _pick<String>(data, _v.data));
  }
}

class ResultSuccess with _$Result implements Result {
  const ResultSuccess({required this.data});

  factory ResultSuccess.fromJson(Map<String, dynamic> json) {
    return ResultSuccess(data: json['data'] as String);
  }

  final String data;

  ResultSuccessCopyWith get copyWith => ResultSuccessCopyWith(this);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'success', 'data': data};
  }

  @override
  String toString() => 'Result.success(data: $data)';
}

class ResultErrorCopyWith {
  ResultErrorCopyWith(this._v);

  final ResultError _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  ResultError call({Object? message = _unset, Object? code = _unset}) {
    return ResultError(
      message: _pick<String>(message, _v.message),
      code: _pick<int>(code, _v.code),
    );
  }
}

class ResultError with _$Result implements Result {
  const ResultError({required this.message, required this.code});

  factory ResultError.fromJson(Map<String, dynamic> json) {
    return ResultError(
      message: json['message'] as String,
      code: json['code'] as int,
    );
  }

  final String message;

  final int code;

  ResultErrorCopyWith get copyWith => ResultErrorCopyWith(this);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'error', 'message': message, 'code': code};
  }

  @override
  String toString() => 'Result.error(message: $message, code: $code)';
}

class _Result {
  _Result._();

  static Result fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'success' => ResultSuccess.fromJson(json),
      'error' => ResultError.fromJson(json),
      final unknown => throw ArgumentError.value(
        unknown,
        'type',
        'Unknown union type',
      ),
    };
  }
}
""",
      );
    });

    test('custom unionKey', () {
      const source = r'''
@Lockd(unionKey: 'kind')
sealed class Action with _$Action {
  const factory Action.tap() = ActionTap;
  const factory Action.swipe() = ActionSwipe;
  factory Action.fromJson(Map<String, dynamic> json) => _Action.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'action',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action.dart';

// ########################################################
// Action
// ########################################################

mixin _$Action {
  Map<String, dynamic> toJson();
}

class ActionTap with _$Action implements Action {
  const ActionTap();

  factory ActionTap.fromJson(Map<String, dynamic> json) {
    return const ActionTap();
  }

  @override
  Map<String, dynamic> toJson() {
    return {'kind': 'tap'};
  }

  @override
  String toString() => 'Action.tap()';
}

class ActionSwipe with _$Action implements Action {
  const ActionSwipe();

  factory ActionSwipe.fromJson(Map<String, dynamic> json) {
    return const ActionSwipe();
  }

  @override
  Map<String, dynamic> toJson() {
    return {'kind': 'swipe'};
  }

  @override
  String toString() => 'Action.swipe()';
}

class _Action {
  _Action._();

  static Action fromJson(Map<String, dynamic> json) {
    return switch (json['kind'] as String) {
      'tap' => ActionTap.fromJson(json),
      'swipe' => ActionSwipe.fromJson(json),
      final unknown => throw ArgumentError.value(
        unknown,
        'kind',
        'Unknown union type',
      ),
    };
  }
}
""",
      );
    });

    test('shared fields promoted to mixin with nullable widening', () {
      const source = r'''
@lockd
sealed class Msg with _$Msg {
  const factory Msg.info({required String text, required String? meta}) = MsgInfo;
  const factory Msg.warn({required String text, required String meta}) = MsgWarn;
  factory Msg.fromJson(Map<String, dynamic> json) => _Msg.fromJson(json);
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'msg',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'msg.dart';

// ########################################################
// Msg
// ########################################################

mixin _$Msg {
  String get text;
  String? get meta;

  Map<String, dynamic> toJson();
}

class MsgInfoCopyWith {
  MsgInfoCopyWith(this._v);

  final MsgInfo _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  MsgInfo call({Object? text = _unset, Object? meta = _unset}) {
    return MsgInfo(
      text: _pick<String>(text, _v.text),
      meta: _pick<String?>(meta, _v.meta),
    );
  }
}

class MsgInfo with _$Msg implements Msg {
  const MsgInfo({required this.text, this.meta});

  factory MsgInfo.fromJson(Map<String, dynamic> json) {
    return MsgInfo(text: json['text'] as String, meta: json['meta'] as String?);
  }

  @override
  final String text;

  @override
  final String? meta;

  MsgInfoCopyWith get copyWith => MsgInfoCopyWith(this);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'info', 'text': text, 'meta': meta};
  }

  @override
  String toString() => 'Msg.info(text: $text, meta: $meta)';
}

class MsgWarnCopyWith {
  MsgWarnCopyWith(this._v);

  final MsgWarn _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  MsgWarn call({Object? text = _unset, Object? meta = _unset}) {
    return MsgWarn(
      text: _pick<String>(text, _v.text),
      meta: _pick<String>(meta, _v.meta),
    );
  }
}

class MsgWarn with _$Msg implements Msg {
  const MsgWarn({required this.text, required this.meta});

  factory MsgWarn.fromJson(Map<String, dynamic> json) {
    return MsgWarn(text: json['text'] as String, meta: json['meta'] as String);
  }

  @override
  final String text;

  @override
  final String meta;

  MsgWarnCopyWith get copyWith => MsgWarnCopyWith(this);

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'warn', 'text': text, 'meta': meta};
  }

  @override
  String toString() => 'Msg.warn(text: $text, meta: $meta)';
}

class _Msg {
  _Msg._();

  static Msg fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'info' => MsgInfo.fromJson(json),
      'warn' => MsgWarn.fromJson(json),
      final unknown => throw ArgumentError.value(
        unknown,
        'type',
        'Unknown union type',
      ),
    };
  }
}
""",
      );
    });
  });

  group('generatedDataClassPart', () {
    test('returns empty string for source without data classes', () {
      const source = '''
class RegularClass {
  final String name;
  RegularClass(this.name);
}
''';
      final result = generatedDataClassPart(source);
      expect(result, isEmpty);
    });

    test('returns null from lockdModulePartDartContents for empty', () {
      final result = lockdModulePartDartContents(
        moduleStem: 'empty',
        sourceTexts: ['class Foo {}'],
      );
      expect(result, isNull);
    });
  });

  group('lockdEnumRegistryForModuleSources', () {
    test('collects enum wire values from source', () {
      const source = '''
enum Color {
  red,
  green,
  blue,
}
''';
      final registry = lockdEnumRegistryForModuleSources([source]);
      expect(registry, contains('Color'));
      expect(registry['Color'], hasLength(3));
      expect(registry['Color']![0].caseName, 'red');
      expect(registry['Color']![0].wireLiteral, "'red'");
      expect(registry['Color']![0].isInt, isFalse);
    });
  });
}
