class AppException implements Exception {
  final String message;
  final String? code;
  final String? requestId;
  final dynamic details;

  AppException(this.message, {this.code, this.requestId, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message, {String? requestId})
      : super(message, code: 'UNAUTHENTICATED', requestId: requestId);
}

class UnverifiedException extends AppException {
  UnverifiedException(String message, {String? requestId})
      : super(message, code: 'UNVERIFIED_STUDENT', requestId: requestId);
}

class CrossCollegeException extends AppException {
  CrossCollegeException(String message, {String? requestId})
      : super(message, code: 'CROSS_COLLEGE_DENIED', requestId: requestId);
}

class NotFoundException extends AppException {
  NotFoundException(String message, {String? requestId})
      : super(message, code: 'NOT_FOUND', requestId: requestId);
}

class ConflictException extends AppException {
  ConflictException(String message, {String? requestId})
      : super(message, code: 'CONFLICT', requestId: requestId);
}
