import 'dart:convert';

class FolderModel {
  final String parent;
  final String name;
  final String coverImageRef;
  final String? image;
  final bool isFile;

  FolderModel({
    required this.parent,
    required this.name,
    this.image,
    required this.coverImageRef,
    required this.isFile,
  });

  FolderModel copyWith({
    String? parent,
    String? name,
    String? coverImageRef,
    String? image,
    bool? isFile,
  }) =>
      FolderModel(
        parent: parent ?? this.parent,
        name: name ?? this.name,
        image: image ?? this.image,
        isFile: isFile ?? this.isFile,
        coverImageRef: coverImageRef ?? this.coverImageRef,
      );

  factory FolderModel.fromJson(String str) =>
      FolderModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FolderModel.fromMap(Map<String, dynamic> json) => FolderModel(
        parent: json["parent"],
        name: json["name"],
        image: json["image"],
        isFile: json["is-file"],
        coverImageRef: json['coverImageRef'],
      );

  Map<String, dynamic> toMap() => {
        "parent": parent,
        "name": name,
        "image": image,
        "is-file": isFile,
        "coverImageRef": coverImageRef,
      };
}
