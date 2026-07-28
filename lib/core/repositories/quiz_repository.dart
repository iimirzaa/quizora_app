import '../services/quiz_service.dart';

class QuizRepository {
  Future<Map<String, dynamic>> generateMcq(data, bool isMultipart) async {
    return await QuizApiService().post("generate-mcq", data, isMultipart: isMultipart);
  }

  Future<Map<String, dynamic>> publishMcq(data, bool isMultipart) async {
    return await QuizApiService().post("publish-quiz", data, isMultipart: isMultipart);
  }

  Future<Map<String, dynamic>> join(data, bool isMultipart) async {
    return await QuizApiService().post("search-quiz", data, isMultipart: isMultipart);
  }

  // ── new ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchQuestion(data) async {
    return await QuizApiService().post("get-question", data, isMultipart: false);
  }

  Future<Map<String, dynamic>> saveAnswer(data) async {
    return await QuizApiService().post("save-answer", data, isMultipart: false);
  }

  Future<Map<String, dynamic>> submitQuiz(data) async {
    return await QuizApiService().post("submit-quiz", data, isMultipart: false);
  }
  Future<Map<String, dynamic>> createAttempt(data) async {
    return await QuizApiService().post("create-attempt", data, isMultipart: false);
  }
  Future<Map<String, dynamic>>userStats() async {
    return await QuizApiService().get("user-stats");
  }

  Future<Map<String, dynamic>> teacherStats() async {
    return await QuizApiService().get("teacher-stats");
  }
  Future<Map<String, dynamic>> leaderboard(String id) async {
    return await QuizApiService().get("leaderboard",queryParameters: {"quizId":id});
  }
}
