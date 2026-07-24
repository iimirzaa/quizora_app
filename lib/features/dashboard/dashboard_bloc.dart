import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quiz_app/core/controllers/auth_controller.dart';
import 'package:quiz_app/core/controllers/quiz_controller.dart';
import 'package:quiz_app/core/validators/validator.dart';
import 'package:quiz_app/features/Quiz/quiz_bloc.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<StartNowClicked>((event, emit) {
      emit(StartNowState());
    });

    on<SearchQuizClicked>((event, emit) async {
      emit(LoadingState());

      // 1. validate code format
      final result = AppValidator.quizCode(event.code);
      if (result != null) {
        emit(ErrorState(message: result));
        return;
      }

      // 2. search quiz
      final searchResponse = await QuizController().joinQuiz({
        "code": event.code,
      }, false);

      if (searchResponse['success'] != true) {
        emit(ErrorState(message: searchResponse['message'] as String));
        return;
      }

      final quizData = searchResponse['data'] as Map<String, dynamic>;

      // 3. create attempt — get attemptId back
      final attemptResponse = await QuizController().createAttempt({
        "quizId": quizData['quizId'],
      }, false);

      if (attemptResponse['success'] != true) {
        emit(ErrorState(message: attemptResponse['message'] as String));
        return;
      }

      // 4. merge attemptId into quizData and emit
      emit(SearchQuizSuccess(data: {
        ...quizData,
        'attemptId': attemptResponse['attemptId'],
      }));
    });
    on<UserStatsEvent>((event,emit)async{
        final result=await QuizController().userStats();
        if (result['success'] != true) {
          emit(ErrorState(message: result['message'].toString()));
          return;
        }
        emit(UserStatsState(userStats: result['data']));
  });
    on<TeacherStatsEvent>((event, emit) async {
      final result = await QuizController().teacherStats();
      if (result['success'] != true) {
        emit(ErrorState(message: result['message'].toString()));
        return;
      }
      print(result['data']);
      emit(TeacherStatsState(teacherStats: result['data']));
    });

  }
}
