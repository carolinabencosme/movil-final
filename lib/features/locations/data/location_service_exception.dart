class LocationServiceException implements Exception {
  LocationServiceException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'LocationServiceException: $message';
}
