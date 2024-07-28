import 'dart:convert';

class TextAnswerQuestion {
  final int id;
  final String type;
  final int maxLen;
  final String question;
  final String hint;
  final String answer;

  TextAnswerQuestion({
    required this.id,
    required this.type,
    required this.maxLen,
    required this.question,
    required this.hint,
    required this.answer,
  });

  TextAnswerQuestion copyWith({
    int? id,
    String? type,
    int? maxLen,
    String? question,
    String? hint,
    String? answer,
  }) =>
      TextAnswerQuestion(
        id: id ?? this.id,
        type: type ?? this.type,
        maxLen: maxLen ?? this.maxLen,
        question: question ?? this.question,
        hint: hint ?? this.hint,
        answer: answer ?? this.answer,
      );

  factory TextAnswerQuestion.fromJson(String str) =>
      TextAnswerQuestion.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TextAnswerQuestion.fromMap(Map<String, dynamic> json) =>
      TextAnswerQuestion(
        id: json["id"],
        type: json["type"],
        maxLen: json["max_len"],
        question: json["question"],
        hint: json["hint"],
        answer: json["answer"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type,
        "max_len": maxLen,
        "question": question,
        "hint": hint,
        "answer": answer,
      };
}
