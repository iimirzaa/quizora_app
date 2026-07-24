part of 'quiz_bloc.dart';


sealed class QuizEvent {}
//Create Quiz Events
class UploadFileClicked extends QuizEvent{}
class RemoveFileClicked extends QuizEvent{}
class PreviewFileClicked extends QuizEvent{
  final String fileName;
  final PlatformFile file;

  PreviewFileClicked({required this.fileName,required this.file});
}
class GenerateMcqClicked extends QuizEvent{
  final String fileName;
  final PlatformFile file;

  GenerateMcqClicked({required this.fileName,required this.file});
}
class PublishButtonClicked extends QuizEvent{
  final String title;


  final List<dynamic> mcq;
  PublishButtonClicked({required this.mcq,required this.title,});
}

//Student quiz event

class ConfirmNewUploadConfirmed extends QuizEvent {}

// ... your existing events stay the same ...

class FetchQuestionEvent extends QuizEvent {
  final String quizId;
  final int index;
   FetchQuestionEvent({required this.quizId, required this.index});
}

class SaveAnswerEvent extends QuizEvent {
  final String quizId;
  final String attemptId;
  final int questionIndex;
  final int? selectedIndex;
   SaveAnswerEvent({
    required this.quizId,
    required this.attemptId,
    required this.questionIndex,
    required this.selectedIndex,
  });
}

class SubmitQuizEvent extends QuizEvent {
  final String quizId;
  final String attemptId;
  final List<int?> answers;
  final bool autoSubmit;
   SubmitQuizEvent({
    required this.quizId,
    required this.attemptId,
    required this.answers,
    required this.autoSubmit,
  });
}