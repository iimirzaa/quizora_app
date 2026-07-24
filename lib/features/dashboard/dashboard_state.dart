part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}
class LoadingState extends DashboardState{
}
class ErrorState extends DashboardState{
  final String message;
  ErrorState({required this.message});
}
//Teacher Dashboard States
class StartNowState extends DashboardState{}
//Student Dashboard States
class SearchQuizSuccess extends DashboardState{
  final Map<String,dynamic> data;
  SearchQuizSuccess({required this.data});
}
class UserStatsState extends DashboardState{
  final Map<String ,dynamic> userStats;
  UserStatsState({required this.userStats});
}

class TeacherStatsState extends DashboardState {
  final Map<String, dynamic> teacherStats;

  TeacherStatsState({required this.teacherStats});
}