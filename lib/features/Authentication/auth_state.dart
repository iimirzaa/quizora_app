part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}
//Common State
class LoadingState extends AuthState{}
class ErrorState extends AuthState{
  final String message;
  ErrorState({
    required this.message
});
}
//Login States
class LoginSuccessState extends AuthState{
  final String? role;
  LoginSuccessState({required this.role});
}
class CreateAccountState extends AuthState{}
//SignUp State
class NextClickedState extends AuthState{}
class AlreadyAccountState extends AuthState{}
class SignUpSuccessState extends AuthState{
}
//Otp state
class OtpSuccessState extends AuthState{}