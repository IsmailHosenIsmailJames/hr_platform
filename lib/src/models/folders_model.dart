import 'dart:convert';

class FoldersModel {
  final String? image;
  final bool isFile;
  final String type;
  final List<dynamic> sub;

  FoldersModel({
    required this.image,
    required this.isFile,
    required this.type,
    required this.sub,
  });

  FoldersModel copyWith({
    String? image,
    bool? isFile,
    String? type,
    List<dynamic>? sub,
  }) =>
      FoldersModel(
        image: image ?? this.image,
        isFile: isFile ?? this.isFile,
        type: type ?? this.type,
        sub: sub ?? this.sub,
      );

  factory FoldersModel.fromJson(String str) =>
      FoldersModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FoldersModel.fromMap(Map<String, dynamic> json) => FoldersModel(
        image: json["image"],
        isFile: json["is-file"],
        type: json["type"],
        sub: List<dynamic>.from(json["sub"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "image": image,
        "is-file": isFile,
        "type": type,
        "sub": List<dynamic>.from(sub.map((x) => x)),
      };
}
