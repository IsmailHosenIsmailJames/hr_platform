import 'dart:convert';

class SurveyModel {
  String title;
  List<Question> questions;

  SurveyModel({
    required this.title,
    required this.questions,
  });

  SurveyModel copyWith({
    String? title,
    List<Question>? questions,
  }) =>
      SurveyModel(
        title: title ?? this.title,
        questions: questions ?? this.questions,
      );

  factory SurveyModel.fromJson(String str) =>
      SurveyModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SurveyModel.fromMap(Map<String, dynamic> json) => SurveyModel(
        title: json["title"],
        questions: List<Question>.from(
            json["questions"].map((x) => Question.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "title": title,
        "questions": List<dynamic>.from(questions.map((x) => x.toMap())),
      };
}

class Question {
  String question;
  bool isRequires;
  String answerType;
  List<String>? options;

  Question({
    required this.question,
    required this.isRequires,
    required this.answerType,
    this.options,
  });

  Question copyWith({
    String? question,
    bool? isRequires,
    String? answerType,
    List<String>? options,
  }) =>
      Question(
        question: question ?? this.question,
        isRequires: isRequires ?? this.isRequires,
        answerType: answerType ?? this.answerType,
        options: options ?? this.options,
      );

  factory Question.fromJson(String str) => Question.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Question.fromMap(Map<String, dynamic> json) => Question(
        question: json["question"],
        isRequires: json["isRequires"],
        answerType: json["answerType"],
        options: List<String>.from(json["options"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "question": question,
        "isRequires": isRequires,
        "answerType": answerType,
        "options":
            options == null ? null : List<dynamic>.from(options!.map((x) => x)),
      };
}
