import 'dart:convert';

class BooksByGenreModel {
  String genreName;
  int bookCount;
  int rowNumber;
  List<Book> books;
  int genreId;
  dynamic genrePoster;
  dynamic posterImageFile;
  bool isExpanded = false;

  BooksByGenreModel({
    required this.genreName,
    required this.bookCount,
    required this.rowNumber,
    required this.books,
    required this.genreId,
    required this.genrePoster,
    required this.posterImageFile,
  });

  factory BooksByGenreModel.fromJson(String str) =>
      BooksByGenreModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BooksByGenreModel.fromMap(Map<String, dynamic> json) =>
      BooksByGenreModel(
        genreName: json["genre_name"],
        bookCount: json["book_count"],
        rowNumber: json["row_number"],
        books: List<Book>.from(json["books"].map((x) => Book.fromMap(x))),
        genreId: json["genre_id"],
        genrePoster: json["genre_poster"],
        posterImageFile: json["poster_image_file"],
      );

  Map<String, dynamic> toMap() => {
        "genre_name": genreName,
        "book_count": bookCount,
        "row_number": rowNumber,
        "books": List<dynamic>.from(books.map((x) => x.toMap())),
        "genre_id": genreId,
        "genre_poster": genrePoster,
        "poster_image_file": posterImageFile,
      };
}

class Book {
  String size;
  String year;
  String title;
  String status;
  int bookId;
  int autorId;
  String bookUrl;
  String overview;
  int statusId;
  String? bookCover;
  List<String> categories;
  DateTime createdAt;
  String autorLastName;
  String autorFirstName;
  String? autorFullName = '';

  Book({
    required this.size,
    required this.year,
    required this.title,
    required this.status,
    required this.bookId,
    required this.autorId,
    required this.bookUrl,
    required this.overview,
    required this.statusId,
    required this.bookCover,
    required this.categories,
    required this.createdAt,
    required this.autorLastName,
    required this.autorFirstName,
    required this.autorFullName,
  });

  factory Book.fromJson(String str) => Book.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Book.fromMap(Map<String, dynamic> json) => Book(
        size: json["size"],
        year: json["year"],
        title: json["title"],
        status: json["status"],
        bookId: json["book_id"],
        autorId: json["autor_id"],
        bookUrl: json["book_url"],
        overview: json["overview"],
        statusId: json["status_id"],
        bookCover: json["book_cover"],
        categories: List<String>.from(json["categories"].map((x) => x)),
        createdAt: DateTime.parse(json["created_at"]),
        autorLastName: json["autor_last_name"],
        autorFirstName: json["autor_first_name"],
        autorFullName: json["autor_name"],
      );

  Map<String, dynamic> toMap() => {
        "size": size,
        "year": year,
        "title": title,
        "status": status,
        "book_id": bookId,
        "autor_id": autorId,
        "book_url": bookUrl,
        "overview": overview,
        "status_id": statusId,
        "book_cover": bookCover,
        "categories": List<dynamic>.from(categories.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
        "autor_last_name": autorLastName,
        "autor_first_name": autorFirstName,
        "autor_name": autorFullName,
      };
}
