part of 'authcubit.dart';

class AuthState {}

class AuthInitial extends AuthState {}

class ForgetPasswordLoading extends AuthState {}

class ForgetPasswordSuccess extends AuthState {}

class ForgetPasswordFailed extends AuthState {
  final String error;
  ForgetPasswordFailed(this.error);
}
