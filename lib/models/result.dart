/// TZ 5-bo'lim. Har bir amal shu turni qaytaradi.
class Result<T> {
  final T? data;
  final String? error;

  const Result.ok([this.data]) : error = null;
  const Result.fail(this.error) : data = null;

  bool get ok => error == null;

  @override
  String toString() => ok ? 'OK($data)' : 'XATO($error)';
}