part of 'quiz_bloc.dart';


sealed class QuizState {}

final class QuizInitial extends QuizState {}

class LoadingState extends QuizState {}

class ErrorState extends QuizState {
  final String message;
  ErrorState({required this.message});
}

//Create Quiz State
class FileSelectedState extends QuizState {
  final String fileName;
  final PlatformFile file;
  FileSelectedState({required this.fileName, required this.file});
}

class McqSuccessState extends QuizState {
  final List<Map<String, dynamic>> mcq;
  McqSuccessState({required this.mcq});
}

// in quiz_state.dart
class ConfirmNewUploadState extends QuizState {}

class PublishedState extends QuizState {
  final String quizCode;

  PublishedState({required this.quizCode});
}

class QuestionLoadedState extends QuizState {
  final Map<String, dynamic> question;
  final int index;
  final int total;
   QuestionLoadedState({
    required this.question,
    required this.index,
    required this.total,
  });
}

class AnswerSavedState extends QuizState {
  final int questionIndex;
   AnswerSavedState({required this.questionIndex});
}

class QuizSubmittedState extends QuizState {
  final int score;
  final int percentage;
  final int total;
  final List<dynamic> breakdown;
   QuizSubmittedState({
    required this.score,
    required this.percentage,
    required this.total,
    required this.breakdown,
  });
}
class QuizErrorState extends QuizState {
  final String message;
  final bool isFatal; // fatal = block UI, non-fatal = silent retry
   QuizErrorState({required this.message, this.isFatal = false});
}