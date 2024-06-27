import 'dart:convert';

class FolderModel {
  final String parent;
  final String name;
  final String? image;
  final bool isFile;
  final String type;

  FolderModel({
    required this.parent,
    required this.name,
    this.image,
    required this.isFile,
    required this.type,
  });

  FolderModel copyWith({
    String? parent,
    String? name,
    String? image,
    bool? isFile,
    String? type,
  }) =>
      FolderModel(
        parent: parent ?? this.parent,
        name: name ?? this.name,
        image: image ?? this.image,
        isFile: isFile ?? this.isFile,
        type: type ?? this.type,
      );

  factory FolderModel.fromJson(String str) =>
      FolderModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FolderModel.fromMap(Map<String, dynamic> json) => FolderModel(
        parent: json["parent"],
        name: json["name"],
        image: json["image"],
        isFile: json["is-file"],
        type: json["type"],
      );

  Map<String, dynamic> toMap() => {
        "parent": parent,
        "name": name,
        "image": image,
        "is-file": isFile,
        "type": type,
      };
}
