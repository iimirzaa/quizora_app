part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

//Login Events
class LoginButtonClicked extends AuthEvent {
  final bool formkey;
  final String email;
  final String password;
  LoginButtonClicked({
    required this.formkey,
    required this.email,
    required this.password,
  });
}

class CreateAccountClicked extends AuthEvent {}

//SignUp Events
class NextButtonClickedEvent extends AuthEvent {}

class AlreadyAccountEvent extends AuthEvent {}

class SignUpEvent extends AuthEvent {
  final bool formkey;
  final String name;
  final String email;
  final String password;
  final String role;
  SignUpEvent({
    required this.formkey,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}
//Otp Events
class VerifyButtonClicked extends AuthEvent{
  final String otp;
  final bool key;
  final String email;
  final String role;
  VerifyButtonClicked({required this.email,required this.otp,required this.key,required this.role});
}
