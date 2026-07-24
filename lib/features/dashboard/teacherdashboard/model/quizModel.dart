class QuizModel {
  final String title;
  final int students;
  final String status;
  final double completionRate; // percentage
  final DateTime createdAt;

  QuizModel({
    required this.title,
    required this.students,
    required this.status,
    required this.completionRate,
    required this.createdAt,
  });
}