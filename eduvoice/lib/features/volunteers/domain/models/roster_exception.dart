/// A roster change that cannot be applied, worded for the person who tried.
class RosterException implements Exception {
  const RosterException(this.message);

  final String message;

  @override
  String toString() => message;
}
