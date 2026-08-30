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
  NetworkException(super.message) : super(code: 'NETWORK_ERROR');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.requestId})
      : super(code: 'UNAUTHENTICATED');
}

class UnverifiedException extends AppException {
  UnverifiedException(super.message, {super.requestId})
      : super(code: 'UNVERIFIED_STUDENT');
}

class CrossCollegeException extends AppException {
  CrossCollegeException(super.message, {super.requestId})
      : super(code: 'CROSS_COLLEGE_DENIED');
}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.requestId})
      : super(code: 'NOT_FOUND');
}

class ConflictException extends AppException {
  ConflictException(super.message, {super.requestId})
      : super(code: 'CONFLICT');
}
