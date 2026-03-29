/// Exception thrown by lockd code generation.
class LockdException implements Exception {
  /// Creates a [LockdException] with the given [message].
  const LockdException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'LockdException: $message';
}
