/// The outcome of an operation that can fail, so callers handle failures
/// explicitly instead of catching exceptions.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.error(Exception error) = Err<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  const Err(this.error);

  final Exception error;

  @override
  String toString() => 'Err($error)';
}
