import 'dart:convert';

class CategoryModel {
  int categoryId;
  DateTime createdAt;
  String name;

  CategoryModel({
    required this.categoryId,
    required this.createdAt,
    required this.name,
  });

  factory CategoryModel.fromJson(String str) =>
      CategoryModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromMap(Map<String, dynamic> json) => CategoryModel(
        categoryId: json["category_id"],
        createdAt: DateTime.parse(json["created_at"]),
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "category_id": categoryId,
        "created_at": createdAt.toIso8601String(),
        "name": name,
      };
}
