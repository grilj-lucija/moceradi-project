import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  String get kind;

  @override
  List<Object?> get props => [message, cause, kind];

  @override
  String toString() => '$kind($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error', super.cause]);
  @override
  String get kind => 'NetworkFailure';
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed', super.cause]);
  @override
  String get kind => 'AuthFailure';
}

class EmailConfirmationPendingFailure extends Failure {
  const EmailConfirmationPendingFailure(this.email)
      : super('Email confirmation required for $email');

  final String email;

  @override
  String get kind => 'EmailConfirmationPendingFailure';

  @override
  List<Object?> get props => [message, cause, kind, email];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found', super.cause]);
  @override
  String get kind => 'NotFoundFailure';
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.cause]);
  @override
  String get kind => 'ValidationFailure';
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error', super.cause]);
  @override
  String get kind => 'UnknownFailure';
}
