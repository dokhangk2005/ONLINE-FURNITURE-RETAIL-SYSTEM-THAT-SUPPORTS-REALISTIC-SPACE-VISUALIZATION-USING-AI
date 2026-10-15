class SupportQuestionModel {
  final int questionId;
  final int userId;
  final String? fullName;
  final String? email;
  final String topic;
  final String questionText;
  final DateTime createdAt;
  final String? answerText;
  final DateTime? answeredAt;
  final String status;

  SupportQuestionModel({
    required this.questionId,
    required this.userId,
    this.fullName,
    this.email,
    required this.topic,
    required this.questionText,
    required this.createdAt,
    this.answerText,
    this.answeredAt,
    required this.status,
  });

  factory SupportQuestionModel.fromJson(Map<String, dynamic> json) {
    return SupportQuestionModel(
      questionId: (json['questionId'] ?? json['QuestionId'] ?? 0) as int,
      userId: (json['userId'] ?? json['UserId'] ?? 0) as int,
      fullName: (json['fullName'] ?? json['FullName'])?.toString(),
      email: (json['email'] ?? json['Email'])?.toString(),
      topic: (json['topic'] ?? json['Topic'] ?? '').toString(),
      questionText: (json['questionText'] ?? json['QuestionText'] ?? '')
          .toString(),
      createdAt:
          DateTime.tryParse(
            (json['createdAt'] ?? json['CreatedAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      answerText: (json['answerText'] ?? json['AnswerText'])?.toString(),
      answeredAt: json['answeredAt'] != null || json['AnsweredAt'] != null
          ? DateTime.tryParse(
              (json['answeredAt'] ?? json['AnsweredAt'] ?? '').toString(),
            )
          : null,
      status: (json['status'] ?? json['Status'] ?? 'Unanswered').toString(),
    );
  }
}
