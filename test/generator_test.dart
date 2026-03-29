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

    test('JSON: list + non-primitive with fromJson/toJson', () {
      const source = r'''
@lockd
abstract class AppointmentsState with _$AppointmentsState {
  const factory AppointmentsState({
    @Default([]) List<Appointment> appointments,
    @Default(AppointmentsTab.upcoming) AppointmentsTab selectedTab,
  }) = _AppointmentsState;

  factory AppointmentsState.fromJson(Map<String, dynamic> json) =
      _AppointmentsState.fromJson;
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
      appointments: (json['appointments'] as List<dynamic>).map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList(),
      selectedTab: AppointmentsTab.fromJson(json['selectedTab'] as Map<String, dynamic>),
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

    test(
      'JSON: all primitive types (String, int, double, bool, nullable)',
      () {
        const source = r'''
@lockd
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String name,
    required int age,
    @Default(0.0) double score,
    @Default(false) bool isActive,
    String? nickname,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =
      _UserProfile.fromJson;
}
''';

        final result = lockdModulePartDartContents(
          moduleStem: 'user_profile',
          sourceTexts: [source],
        );

        expect(
          result,
          r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// ###### Helpers ####

const Object _unset = Object();

// ########################################################
// UserProfile
// ########################################################

mixin _$UserProfile {
  String get name;

  int get age;

  double get score;

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
    Object? score = _unset,
    Object? isActive = _unset,
    Object? nickname = _unset,
  }) {
    return UserProfile(
      name: _pick<String>(name, _v.name),
      age: _pick<int>(age, _v.age),
      score: _pick<double>(score, _v.score),
      isActive: _pick<bool>(isActive, _v.isActive),
      nickname: _pick<String?>(nickname, _v.nickname),
    );
  }
}

class _UserProfile with _$UserProfile implements UserProfile {
  const _UserProfile({
    required this.name,
    required this.age,
    this.score = 0.0,
    this.isActive = false,
    this.nickname,
  });

  factory _UserProfile.fromJson(Map<String, dynamic> json) {
    return _UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      score: json['score'] as double,
      isActive: json['isActive'] as bool,
      nickname: json['nickname'] as String?,
    );
  }

  @override
  final String name;

  @override
  final int age;

  @override
  final double score;

  @override
  final bool isActive;

  @override
  final String? nickname;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'score': score,
      'isActive': isActive,
      'nickname': nickname,
    };
  }

  @override
  String toString() =>
      'UserProfile(name: $name, age: $age, score: $score, isActive: $isActive, nickname: $nickname)';
}
""",
        );
      },
    );

    test(
      'JSON: non-primitives '
      '(DateTime, Duration, object, lists, nullable)',
      () {
        const source = r'''
@lockd
abstract class ComplexModel with _$ComplexModel {
  const factory ComplexModel({
    required String name,
    required int count,
    required DateTime createdAt,
    required Duration timeout,
    required Address address,
    @Default([]) List<String> tags,
    @Default([]) List<Address> addresses,
    String? nickname,
    Address? secondaryAddress,
    DateTime? deletedAt,
  }) = _ComplexModel;

  factory ComplexModel.fromJson(Map<String, dynamic> json) =
      _ComplexModel.fromJson;
}
''';

        final result = lockdModulePartDartContents(
          moduleStem: 'complex_model',
          sourceTexts: [source],
        );

        expect(
          result,
          r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complex_model.dart';

// ###### Helpers ####

const Object _unset = Object();

// ########################################################
// ComplexModel
// ########################################################

mixin _$ComplexModel {
  String get name;

  int get count;

  DateTime get createdAt;

  Duration get timeout;

  Address get address;

  List<String> get tags;

  List<Address> get addresses;

  String? get nickname;

  Address? get secondaryAddress;

  DateTime? get deletedAt;

  _ComplexModelCopyWith get copyWith => _ComplexModelCopyWith(this);

  Map<String, dynamic> toJson();
}

class _ComplexModelCopyWith {
  _ComplexModelCopyWith(this._v);

  final _$ComplexModel _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  ComplexModel call({
    Object? name = _unset,
    Object? count = _unset,
    Object? createdAt = _unset,
    Object? timeout = _unset,
    Object? address = _unset,
    Object? tags = _unset,
    Object? addresses = _unset,
    Object? nickname = _unset,
    Object? secondaryAddress = _unset,
    Object? deletedAt = _unset,
  }) {
    return ComplexModel(
      name: _pick<String>(name, _v.name),
      count: _pick<int>(count, _v.count),
      createdAt: _pick<DateTime>(createdAt, _v.createdAt),
      timeout: _pick<Duration>(timeout, _v.timeout),
      address: _pick<Address>(address, _v.address),
      tags: _pick<List<String>>(tags, _v.tags),
      addresses: _pick<List<Address>>(addresses, _v.addresses),
      nickname: _pick<String?>(nickname, _v.nickname),
      secondaryAddress: _pick<Address?>(secondaryAddress, _v.secondaryAddress),
      deletedAt: _pick<DateTime?>(deletedAt, _v.deletedAt),
    );
  }
}

class _ComplexModel with _$ComplexModel implements ComplexModel {
  const _ComplexModel({
    required this.name,
    required this.count,
    required this.createdAt,
    required this.timeout,
    required this.address,
    this.tags = const [],
    this.addresses = const [],
    this.nickname,
    this.secondaryAddress,
    this.deletedAt,
  });

  factory _ComplexModel.fromJson(Map<String, dynamic> json) {
    return _ComplexModel(
      name: json['name'] as String,
      count: json['count'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      timeout: Duration(microseconds: json['timeout'] as int),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      addresses: (json['addresses'] as List<dynamic>).map((e) => Address.fromJson(e as Map<String, dynamic>)).toList(),
      nickname: json['nickname'] as String?,
      secondaryAddress: json['secondaryAddress'] == null ? null : Address.fromJson(json['secondaryAddress'] as Map<String, dynamic>),
      deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
    );
  }

  @override
  final String name;

  @override
  final int count;

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
  final String? nickname;

  @override
  final Address? secondaryAddress;

  @override
  final DateTime? deletedAt;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'createdAt': createdAt.toIso8601String(),
      'timeout': timeout.inMicroseconds,
      'address': address.toJson(),
      'tags': tags,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'nickname': nickname,
      'secondaryAddress': secondaryAddress?.toJson(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'ComplexModel(name: $name, count: $count, createdAt: $createdAt, timeout: $timeout, address: $address, tags: $tags, addresses: $addresses, nickname: $nickname, secondaryAddress: $secondaryAddress, deletedAt: $deletedAt)';
}
""",
        );
      },
    );

    test('JSON: enums with enum map + list of enums', () {
      const source = r'''
enum Status {
  active,
  inactive,
}

@lockd
abstract class Item with _$Item {
  const factory Item({
    @Default(Status.active) Status status,
    @Default([]) List<Status> statuses,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) =
      _Item.fromJson;
}
''';

      final result = lockdModulePartDartContents(
        moduleStem: 'item',
        sourceTexts: [source],
      );

      expect(
        result,
        r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// ###### Helpers ####

const Object _unset = Object();

const Map<Status, String> _statusJsonMap = {
  Status.active: 'active',
  Status.inactive: 'inactive',
};

Status _decodeStatusJsonMap(String v) => _statusJsonMap.entries.singleWhere((e) => e.value == v).key;

// ########################################################
// Item
// ########################################################

mixin _$Item {
  Status get status;

  List<Status> get statuses;

  _ItemCopyWith get copyWith => _ItemCopyWith(this);

  Map<String, dynamic> toJson();
}

class _ItemCopyWith {
  _ItemCopyWith(this._v);

  final _$Item _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  Item call({
    Object? status = _unset,
    Object? statuses = _unset,
  }) {
    return Item(
      status: _pick<Status>(status, _v.status),
      statuses: _pick<List<Status>>(statuses, _v.statuses),
    );
  }
}

class _Item with _$Item implements Item {
  const _Item({
    this.status = Status.active,
    this.statuses = const [],
  });

  factory _Item.fromJson(Map<String, dynamic> json) {
    return _Item(
      status: _decodeStatusJsonMap(json['status'] as String),
      statuses: (json['statuses'] as List<dynamic>).map((e) => _decodeStatusJsonMap(e as String)).toList(),
    );
  }

  @override
  final Status status;

  @override
  final List<Status> statuses;

  Map<String, dynamic> toJson() {
    return {
      'status': _statusJsonMap[status]!,
      'statuses': statuses.map((e) => _statusJsonMap[e]!).toList(),
    };
  }

  @override
  String toString() =>
      'Item(status: $status, statuses: $statuses)';
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

mixin _$AccountCreatePresentationEvent {
}

class AccountCreatePresentationEventCreateAccountFailed with _$AccountCreatePresentationEvent implements AccountCreatePresentationEvent {
  const AccountCreatePresentationEventCreateAccountFailed();

  @override
  String toString() =>
      'AccountCreatePresentationEvent.createAccountFailed()';
}

class AccountCreatePresentationEventCreateAccountSuccess with _$AccountCreatePresentationEvent implements AccountCreatePresentationEvent {
  const AccountCreatePresentationEventCreateAccountSuccess();

  @override
  String toString() =>
      'AccountCreatePresentationEvent.createAccountSuccess()';
}

class AccountCreatePresentationEventFoo with _$AccountCreatePresentationEvent implements AccountCreatePresentationEvent {
  const AccountCreatePresentationEventFoo();

  @override
  String toString() =>
      'AccountCreatePresentationEvent.foo()';
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
    return {
      'type': 'a',
    };
  }

  @override
  String toString() =>
      'Event.a()';
}

class EventB with _$Event implements Event {
  const EventB();

  factory EventB.fromJson(Map<String, dynamic> json) {
    return const EventB();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'b',
    };
  }

  @override
  String toString() =>
      'Event.b()';
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

  ResultSuccess call({
    Object? data = _unset,
  }) {
    return ResultSuccess(
      data: _pick<String>(data, _v.data),
    );
  }
}

class ResultSuccess with _$Result implements Result {
  const ResultSuccess({
    required this.data,
  });

  factory ResultSuccess.fromJson(Map<String, dynamic> json) {
    return ResultSuccess(
      data: json['data'] as String,
    );
  }

  final String data;

  ResultSuccessCopyWith get copyWith => ResultSuccessCopyWith(this);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'success',
      'data': data,
    };
  }

  @override
  String toString() =>
      'Result.success(data: $data)';
}

class ResultErrorCopyWith {
  ResultErrorCopyWith(this._v);

  final ResultError _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  ResultError call({
    Object? message = _unset,
    Object? code = _unset,
  }) {
    return ResultError(
      message: _pick<String>(message, _v.message),
      code: _pick<int>(code, _v.code),
    );
  }
}

class ResultError with _$Result implements Result {
  const ResultError({
    required this.message,
    required this.code,
  });

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
    return {
      'type': 'error',
      'message': message,
      'code': code,
    };
  }

  @override
  String toString() =>
      'Result.error(message: $message, code: $code)';
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
    return {
      'kind': 'tap',
    };
  }

  @override
  String toString() =>
      'Action.tap()';
}

class ActionSwipe with _$Action implements Action {
  const ActionSwipe();

  factory ActionSwipe.fromJson(Map<String, dynamic> json) {
    return const ActionSwipe();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'kind': 'swipe',
    };
  }

  @override
  String toString() =>
      'Action.swipe()';
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

  MsgInfo call({
    Object? text = _unset,
    Object? meta = _unset,
  }) {
    return MsgInfo(
      text: _pick<String>(text, _v.text),
      meta: _pick<String?>(meta, _v.meta),
    );
  }
}

class MsgInfo with _$Msg implements Msg {
  const MsgInfo({
    required this.text,
    this.meta,
  });

  factory MsgInfo.fromJson(Map<String, dynamic> json) {
    return MsgInfo(
      text: json['text'] as String,
      meta: json['meta'] as String?,
    );
  }

  @override
  final String text;

  @override
  final String? meta;

  MsgInfoCopyWith get copyWith => MsgInfoCopyWith(this);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'info',
      'text': text,
      'meta': meta,
    };
  }

  @override
  String toString() =>
      'Msg.info(text: $text, meta: $meta)';
}

class MsgWarnCopyWith {
  MsgWarnCopyWith(this._v);

  final MsgWarn _v;

  T _pick<T>(Object? value, T current) {
    return identical(value, _unset) ? current : value as T;
  }

  MsgWarn call({
    Object? text = _unset,
    Object? meta = _unset,
  }) {
    return MsgWarn(
      text: _pick<String>(text, _v.text),
      meta: _pick<String>(meta, _v.meta),
    );
  }
}

class MsgWarn with _$Msg implements Msg {
  const MsgWarn({
    required this.text,
    required this.meta,
  });

  factory MsgWarn.fromJson(Map<String, dynamic> json) {
    return MsgWarn(
      text: json['text'] as String,
      meta: json['meta'] as String,
    );
  }

  @override
  final String text;

  @override
  final String meta;

  MsgWarnCopyWith get copyWith => MsgWarnCopyWith(this);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'warn',
      'text': text,
      'meta': meta,
    };
  }

  @override
  String toString() =>
      'Msg.warn(text: $text, meta: $meta)';
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
