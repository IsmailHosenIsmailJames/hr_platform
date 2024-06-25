import 'dart:convert';

class FilesModel {
  final String? image;
  final bool isFile;
  final String name;
  final String path;
  final String type;

  FilesModel({
    this.image,
    required this.isFile,
    required this.name,
    required this.path,
    required this.type,
  });

  FilesModel copyWith({
    String? image,
    bool? isFile,
    String? name,
    String? path,
    String? type,
  }) =>
      FilesModel(
        image: image ?? this.image,
        isFile: isFile ?? this.isFile,
        name: name ?? this.name,
        path: path ?? this.path,
        type: type ?? this.type,
      );

  factory FilesModel.fromJson(String str) =>
      FilesModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FilesModel.fromMap(Map<String, dynamic> json) => FilesModel(
        image: json["image"],
        isFile: json["is-file"],
        name: json["name"],
        path: json["path"],
        type: json["type"],
      );

  Map<String, dynamic> toMap() => {
        "image": image,
        "is-file": isFile,
        "name": name,
        "path": path,
        "type": type,
      };
}
