import 'dart:convert';

class SureveyModel {
  int id;
  String title;
  String description;
  int? timer;
  int date;
  int? expired;
  List<Question> questions;
  int? lastUpdated;

  SureveyModel({
    required this.id,
    required this.title,
    required this.description,
    this.timer,
    required this.date,
    this.expired,
    required this.questions,
    this.lastUpdated,
  });

  SureveyModel copyWith({
    int? id,
    String? title,
    String? description,
    int? timer,
    int? date,
    int? expired,
    List<Question>? questions,
    int? lastUpdated,
  }) =>
      SureveyModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        timer: timer ?? this.timer,
        date: date ?? this.date,
        expired: expired ?? this.expired,
        questions: questions ?? this.questions,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  factory SureveyModel.fromJson(String str) =>
      SureveyModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SureveyModel.fromMap(Map<String, dynamic> json) => SureveyModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        timer: json["timer"],
        date: json["date"],
        expired: json["expired"],
        questions: List<Question>.from(
          json["questions"].map(
            (x) => Question.fromMap(x),
          ),
        ),
        lastUpdated: json["lastUpdated"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "description": description,
        "timer": timer,
        "date": date,
        "expired": expired,
        "questions": List<dynamic>.from(questions.map((x) => x.toMap())),
        "lastUpdated": lastUpdated,
      };
}

class Question {
  int id;
  String type;
  String question;
  String? hint;
  List<Option>? options;
  dynamic answer;
  int? maxLen;

  Question({
    required this.id,
    required this.type,
    required this.question,
    this.hint,
    this.options,
    this.answer,
    this.maxLen,
  });

  Question copyWith({
    int? id,
    String? type,
    String? question,
    String? hint,
    List<Option>? options,
    dynamic answer,
    int? maxLen,
  }) =>
      Question(
        id: id ?? this.id,
        type: type ?? this.type,
        question: question ?? this.question,
        hint: hint ?? this.hint,
        options: options ?? this.options,
        answer: answer ?? this.answer,
        maxLen: maxLen ?? this.maxLen,
      );

  factory Question.fromJson(String str) => Question.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Question.fromMap(Map<String, dynamic> json) => Question(
        id: json["id"],
        type: json["type"],
        question: json["question"],
        hint: json["hint"],
        options: json["options"] == null
            ? []
            : List<Option>.from(json["options"].map((x) => Option.fromMap(x))),
        answer: json["answer"],
        maxLen: json["max_len"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type,
        "question": question,
        "hint": hint,
        "options": answer == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toMap())),
        "answer": answer,
        "max_len": maxLen,
      };
}

class Option {
  int id;
  String text;

  Option({
    required this.id,
    required this.text,
  });

  Option copyWith({
    int? id,
    String? text,
  }) =>
      Option(
        id: id ?? this.id,
        text: text ?? this.text,
      );

  factory Option.fromJson(String str) => Option.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Option.fromMap(Map<String, dynamic> json) => Option(
        id: json["id"],
        text: json["text"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "text": text,
      };
}
