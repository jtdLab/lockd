/// Joins [headers] and [content] lines into a single Dart source string.
String dartFile({
  required List<String> headers,
  required List<String> content,
}) {
  return [...headers, ...content].join('\n');
}
