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
