part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}
class ErrorState extends ProfileState{
  final String msg;
  ErrorState({required this.msg});
}
class LoadingState extends ProfileState{}
class LogoutSuccessState extends ProfileState{}
