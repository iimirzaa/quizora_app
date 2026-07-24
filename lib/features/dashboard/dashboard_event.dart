part of 'dashboard_bloc.dart';

@immutable

sealed class DashboardEvent {}
//Teacher Dashboard events
class StartNowClicked extends DashboardEvent{

}
//Student Dashboard event
class SearchQuizClicked extends DashboardEvent{
  final String code;
  SearchQuizClicked({required this.code});
}

class UserStatsEvent extends DashboardEvent{}

class TeacherStatsEvent extends DashboardEvent {}