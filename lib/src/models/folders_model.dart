import 'dart:convert';

class FolderModel {
  final String parent;
  final String name;
  final String coverImageRef;
  final String? image;
  final bool isFile;
  final String? url;

  FolderModel({
    required this.parent,
    required this.name,
    this.image,
    required this.coverImageRef,
    required this.isFile,
    this.url,
  });

  FolderModel copyWith({
    String? parent,
    String? name,
    String? coverImageRef,
    String? image,
    bool? isFile,
    String? url,
  }) =>
      FolderModel(
        parent: parent ?? this.parent,
        name: name ?? this.name,
        image: image ?? this.image,
        isFile: isFile ?? this.isFile,
        coverImageRef: coverImageRef ?? this.coverImageRef,
        url: url ?? this.url,
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
        url: json['url'],
      );

  Map<String, dynamic> toMap() => {
        "parent": parent,
        "name": name,
        "image": image,
        "is-file": isFile,
        "coverImageRef": coverImageRef,
        "url": url,
      };
}
