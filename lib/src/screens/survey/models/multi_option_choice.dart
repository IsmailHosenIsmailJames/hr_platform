import 'dart:convert';

class MultiChoice {
  final int id;
  final String type;
  final String question;
  String? hint;
  final List<Option> options;
  List<int>? answer;

  MultiChoice({
    required this.id,
    required this.type,
    required this.question,
    this.hint,
    required this.options,
    this.answer,
  });

  MultiChoice copyWith({
    int? id,
    String? type,
    String? question,
    String? hint,
    List<Option>? options,
    List<int>? answer,
  }) =>
      MultiChoice(
        id: id ?? this.id,
        type: type ?? this.type,
        question: question ?? this.question,
        hint: hint ?? this.hint,
        options: options ?? this.options,
        answer: answer ?? this.answer,
      );

  factory MultiChoice.fromJson(String str) =>
      MultiChoice.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MultiChoice.fromMap(Map<String, dynamic> json) => MultiChoice(
        id: json["id"],
        type: json["type"],
        question: json["question"],
        hint: json["hint"],
        options:
            List<Option>.from(json["options"].map((x) => Option.fromMap(x))),
        answer: List<int>.from(json["answer"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type,
        "question": question,
        "hint": hint,
        "options": List<dynamic>.from(options.map((x) => x.toMap())),
        "answer":
            answer == null ? null : List<dynamic>.from(answer!.map((x) => x)),
      };
}

class Option {
  final int id;
  final String text;

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
