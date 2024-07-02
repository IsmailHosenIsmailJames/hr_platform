import 'dart:convert';

class FilesModel {
  final String parent;
  final String? image;
  final bool isFile;
  final String name;
  final String path;
  final String type;
  final String fileRef;
  final String coverImageRef;

  FilesModel({
    required this.parent,
    this.image,
    required this.isFile,
    required this.name,
    required this.path,
    required this.type,
    required this.fileRef,
    required this.coverImageRef,
  });

  FilesModel copyWith({
    String? parent,
    String? image,
    bool? isFile,
    String? name,
    String? path,
    String? type,
    String? fileRef,
    String? coverImageRef,
  }) =>
      FilesModel(
        parent: parent ?? this.parent,
        image: image ?? this.image,
        isFile: isFile ?? this.isFile,
        name: name ?? this.name,
        path: path ?? this.path,
        type: type ?? this.type,
        fileRef: fileRef ?? this.fileRef,
        coverImageRef: coverImageRef ?? this.coverImageRef,
      );

  factory FilesModel.fromJson(String str) =>
      FilesModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FilesModel.fromMap(Map<String, dynamic> json) => FilesModel(
        parent: json["parent"],
        image: json["image"],
        isFile: json["is-file"],
        name: json["name"],
        path: json["path"],
        type: json["type"],
        fileRef: json["fileRef"],
        coverImageRef: json['coverImageRef'],
      );

  Map<String, dynamic> toMap() => {
        "parent": parent,
        "image": image,
        "is-file": isFile,
        "name": name,
        "path": path,
        "type": type,
        "fileRef": fileRef,
        "coverImageRef": coverImageRef,
      };
}
