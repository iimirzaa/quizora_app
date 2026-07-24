import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';


import 'package:open_filex/open_filex.dart';
import 'package:quiz_app/core/controllers/quiz_controller.dart';
import 'package:quiz_app/features/Authentication/auth_bloc.dart';
import 'package:quiz_app/features/Leaderboard/leaderboard.dart';

import '../../core/controllers/quiz_controller.dart';
part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(QuizInitial()) {
    on<UploadFileClicked>((event, emit) async {
      // if mcqs already generated, show confirmation first
      if (state is McqSuccessState) {
        // emit a special state to trigger dialog in UI
        emit(ConfirmNewUploadState());
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        emit(FileSelectedState(fileName: file.name, file: file));
      }
    });

// add a new event for when user confirms
    on<ConfirmNewUploadConfirmed>((event, emit) async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        emit(FileSelectedState(fileName: file.name, file: file));
      }
    });
    on<PreviewFileClicked>((event, emit) async {

      await OpenFilex.open(event.file.path!);
        });
    on<RemoveFileClicked>((event, emit)  {
      emit(QuizInitial());
    });
    on<GenerateMcqClicked>((event, emit) async {
      emit(LoadingState());
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(event.file.path!, filename: event.fileName),
        'numQuestions': '5',
      });

      final result = await QuizController().generate( formData, true);
      if(result['success']!=true){
        emit(ErrorState(message: result['message']));
        return;
      }
      final List<Map<String, dynamic>> mcqs = List<Map<String, dynamic>>.from(result['mcq']);
      emit(McqSuccessState(mcq: mcqs));
    });
    on<PublishButtonClicked>((event,emit)async{
      emit(LoadingState());

        if(event.mcq.isEmpty){
          emit(ErrorState(message: "At least 5 Mcq's are required"));
          return;
        }

        final response=await QuizController().publish({
          "title":event.title,
          "mcqs":event.mcq,
          "duration":event.mcq.length
        }, false);
        if(response['success']!=true){
          emit(ErrorState(message: response['message']));
          return;
        }
      emit(PublishedState(quizCode: response['quizCode']));

    });
    on<FetchQuestionEvent>((event, emit) async {
      // only show loading on first question
      if (event.index == 0) emit(LoadingState());

      final result = await QuizController().fetchQuestion(event.quizId, event.index);
      if (result['success'] != true) {
        emit(QuizErrorState(message: result['message'] ?? 'Failed to load question', isFatal: true));
        return;
      }

      emit(QuestionLoadedState(
        question: Map<String, dynamic>.from(result['question']),
        index: result['index'],
        total: result['total'],
      ));
    });

    on<SaveAnswerEvent>((event, emit) async {
      // fire and forget — never block UI for this
      await QuizController().saveAnswer(
        event.quizId,
        event.attemptId,
        event.questionIndex,
        event.selectedIndex,
      );
      // no state emit — UI already updated locally
    });

    on<SubmitQuizEvent>((event, emit) async {
      emit(LoadingState());

      final result = await QuizController().submitQuiz(
        event.quizId,
        event.attemptId,
        event.answers,
      );

      if (result['success'] != true) {
        emit(QuizErrorState(message: result['message'] ?? 'Submission failed', isFatal: true));
        return;
      }

      emit(QuizSubmittedState(
        score: result['score'],
        percentage: result['percentage'],
        total: result['total'],
        breakdown: result['breakdown'],
      ));
    });
    on<LeaderBoardEvent> ((event,emit)async{
      final result=await QuizController().leaderboard(event.id);

    });
  }
}
