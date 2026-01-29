import 'dart:convert';

class Book {
  int bookId;
  String title;
  String bookDescription;
  DateTime createdAt;
  String book;
  String bookCover;
  String size;
  String year;
  String bookStatus;
  int autorId;
  String autorFirstName;
  String? autorLastName;
  String category;

  Book({
    required this.bookId,
    required this.title,
    required this.bookDescription,
    required this.createdAt,
    required this.book,
    required this.bookCover,
    required this.size,
    required this.year,
    required this.bookStatus,
    required this.autorId,
    required this.autorFirstName,
    required this.autorLastName,
    required this.category,
  });

  factory Book.fromJson(String str) => Book.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Book.fromMap(Map<String, dynamic> json) => Book(
        bookId: json["book_id"],
        title: json["title"],
        bookDescription: json["book_description"],
        createdAt: DateTime.parse(json["created_at"]),
        book: json["book"],
        bookCover: json["book_cover"],
        size: json["size"],
        year: json["year"],
        bookStatus: json["book_status"],
        autorId: json["autor_id"],
        autorFirstName: json["autor_first_name"],
        autorLastName: json["autor_last_name"],
        category: json["category"],
      );

  Map<String, dynamic> toMap() => {
        "book_id": bookId,
        "title": title,
        "book_description": bookDescription,
        "created_at": createdAt.toIso8601String(),
        "book": book,
        "book_cover": bookCover,
        "size": size,
        "year": year,
        "book_status": bookStatus,
        "autor_id": autorId,
        "autor_first_name": autorFirstName,
        "autor_last_name": autorLastName,
        "category": category,
      };
}
