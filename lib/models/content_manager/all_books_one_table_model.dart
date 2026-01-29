import 'dart:convert';

class AllBooksOneTableModel {
  int rowNumber;
  int bookId;
  DateTime createdAt;
  String bookDescription;
  String title;
  String book;
  String size;
  String year;
  String? bookCover;
  int autorFk;
  int statusFk;
  String bookStatus;
  String autorFirstName;
  String autorLastName;
  String? autorFullName;
  List<String?> categories;

  AllBooksOneTableModel({
    required this.rowNumber,
    required this.bookId,
    required this.createdAt,
    required this.bookDescription,
    required this.title,
    required this.book,
    required this.size,
    required this.year,
    required this.bookCover,
    required this.autorFk,
    required this.statusFk,
    required this.bookStatus,
    required this.autorFirstName,
    required this.autorLastName,
    required this.autorFullName,
    required this.categories,
  });

  factory AllBooksOneTableModel.fromJson(String str) =>
      AllBooksOneTableModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AllBooksOneTableModel.fromMap(Map<String, dynamic> json) =>
      AllBooksOneTableModel(
        rowNumber: json["row_number"],
        bookId: json["book_id"],
        createdAt: DateTime.parse(json["created_at"]),
        bookDescription: json["book_description"],
        title: json["title"],
        book: json["book"],
        size: json["size"],
        year: json["year"],
        bookCover: json["book_cover"],
        autorFk: json["autor_fk"],
        statusFk: json["status_fk"],
        bookStatus: json["book_status"],
        autorFirstName: json["autor_first_name"],
        autorLastName: json["autor_last_name"],
        autorFullName: json["autor_name"],
        categories: List<String?>.from(json["categories"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "row_number": rowNumber,
        "book_id": bookId,
        "created_at": createdAt.toIso8601String(),
        "book_description": bookDescription,
        "title": title,
        "book": book,
        "size": size,
        "year": year,
        "book_cover": bookCover,
        "autor_fk": autorFk,
        "status_fk": statusFk,
        "book_status": bookStatus,
        "autor_first_name": autorFirstName,
        "autor_last_name": autorLastName,
        "autor_name": autorFullName,
        "categories": List<dynamic>.from(categories.map((x) => x)),
      };
}
