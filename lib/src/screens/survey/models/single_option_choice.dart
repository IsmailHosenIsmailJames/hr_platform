import 'dart:convert';

class SingleChoice {
  final int id;
  String type;
  String question;
  String? hint;
  List<Option> options;
  int? answer;

  SingleChoice({
    required this.id,
    required this.type,
    required this.question,
    this.hint,
    required this.options,
    this.answer,
  });

  SingleChoice copyWith({
    int? id,
    String? type,
    String? question,
    String? hint,
    List<Option>? options,
    int? answer,
  }) =>
      SingleChoice(
        id: id ?? this.id,
        type: type ?? this.type,
        question: question ?? this.question,
        hint: hint ?? this.hint,
        options: options ?? this.options,
        answer: answer ?? this.answer,
      );

  factory SingleChoice.fromJson(String str) =>
      SingleChoice.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SingleChoice.fromMap(Map<String, dynamic> json) => SingleChoice(
        id: json["id"],
        type: json["type"],
        question: json["question"],
        hint: json["hint"],
        options:
            List<Option>.from(json["options"].map((x) => Option.fromMap(x))),
        answer: json["answer"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type,
        "question": question,
        "hint": hint,
        "options": List<dynamic>.from(options.map((x) => x.toMap())),
        "answer": answer,
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
