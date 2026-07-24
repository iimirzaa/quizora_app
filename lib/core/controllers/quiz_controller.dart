import 'package:quiz_app/core/repositories/quiz_repository.dart';


class QuizController {
  final QuizRepository repository = QuizRepository();

  Future<Map<String, dynamic>> generate( data,bool isMultipart) async {
    try {
      final response = await repository.generateMcq(data,isMultipart);

      return {
        "success": response['success'],
        "message": response['message'],
        "total":response['total'],
        "mcq": response['mcqs'],
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
  Future<Map<String, dynamic>> publish( data,bool isMultipart) async {
    try {
      final response = await repository.publishMcq(data,isMultipart);

      return {
        "success": response['success'],
        "message": response['message'],
        "quizCode": response['quizCode'],
      };
    }
    catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
  Future<Map<String, dynamic>> joinQuiz( data,bool isMultipart) async {
    try {
      final response = await repository.join(data,isMultipart);


      return {
        "success": response['success'],
        "message": response['message'],
        "data":response['data']

      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
  Future<Map<String, dynamic>> fetchQuestion(String quizId, int index) async {
    try {
      final response = await repository.fetchQuestion({
        'quizId': quizId,
        'index': index,
      });
      return {
        'success': response['success'],
        'question': response['question'],
        'index': response['index'],
        'total': response['total'],
        'done': response['done'] ?? false,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> saveAnswer(
      String quizId, String attemptId, int questionIndex, int? selectedIndex,
      ) async {
    try {
      final response = await repository.saveAnswer({
        'quizId': quizId,
        'attemptId': attemptId,
        'questionIndex': questionIndex,
        'selectedIndex': selectedIndex,
      });
      return {'success': response['success']};
    } catch (e) {
      return {'success': false}; // silent — never block UI
    }
  }

  Future<Map<String, dynamic>> submitQuiz(
      String quizId, String attemptId, List<int?> answers,
      ) async {
    try {
      final response = await repository.submitQuiz({
        'quizId': quizId,
        'attemptId': attemptId,
        'answers': answers,
      });
      return {
        'success': response['success'],
        'message': response['message'],
        'score': response['score'],
        'percentage': response['percentage'],
        'total': response['total'],
        'breakdown': response['breakdown'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  Future<Map<String, dynamic>> createAttempt(data, bool isMultipart) async {
    try {
      final response = await repository.createAttempt(data);
      return {
        'success': response['success'],
        'message': response['message'],
        'attemptId': response['attemptId'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  Future<Map<String, dynamic>> userStats() async {
    try {
      final response = await repository.userStats();
      return {
        'success': response['success'],
        'message': response['message'],
        'data':response['data']
      };
    } catch (e) {
      return {'success': false, 'message': e};
    }
  }

  Future<Map<String, dynamic>> teacherStats() async {
    try {
      final response = await repository.teacherStats();
      return {
        'success': response['success'],
        'message': response['message'],
        'data': response['data']

      };
    } catch (e) {
      return {'success': false, 'message': e};
    }
  }
}
