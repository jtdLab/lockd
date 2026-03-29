import 'dart:collection';

import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';

final _formatter = DartFormatter(
  languageVersion: DartFormatter.latestLanguageVersion,
);

final _emitter = DartEmitter(
  allocator: _StandardAllocator(),
  orderDirectives: true,
);

class _StandardAllocator implements Allocator {
  static const _doNotPrefix = ['dart:core'];

  final _imports = <String>{};

  @override
  String allocate(Reference reference) {
    final symbol = reference.symbol;
    final url = reference.url;
    if (!(url == null || _doNotPrefix.contains(url))) {
      _imports.add(url);
    }
    return symbol!;
  }

  @override
  Iterable<Directive> get imports => _imports.map(Directive.import);
}

String multiline(List<String> lines) => lines.join('\n');

String dartFile({
  List<String> headers = const [],
  Set<Directive> directives = const {},
  List<String> content = const [],
}) {
  final source = multiline([
    ...headers,
    sortedDirectiveLines(directives),
    ...content,
  ]);
  try {
    return _formatter.format(source);
  } on FormatException {
    return source;
  } on FormatterException {
    return source;
  } catch (_) {
    print(source);
    rethrow;
  }
}

String sortedDirectiveLines(Iterable<Directive> directives) {
  final uniqueDirectives = LinkedHashSet<Directive>(
    equals: (a, b) =>
        a.type == b.type &&
        a.as == b.as &&
        a.url == b.url &&
        a.deferred == b.deferred &&
        const DeepCollectionEquality().equals(a.show, b.show) &&
        const DeepCollectionEquality().equals(a.hide, b.hide),
    hashCode: (a) =>
        a.type.hashCode ^
        a.as.hashCode ^
        a.url.hashCode ^
        a.deferred.hashCode ^
        const DeepCollectionEquality().hash(a.show) ^
        const DeepCollectionEquality().hash(a.hide),
  )..addAll(directives);
  return uniqueDirectives.sorted();
}

extension on Set<Directive> {
  String sorted() {
    final library = Library((b) => b.directives.addAll(this));
    return library.accept(_emitter).toString();
  }
}
