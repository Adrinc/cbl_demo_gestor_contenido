import 'dart:convert';

class AdsByGenre {
  String genreName;
  int videoCount;
  int rowNumber;
  List<Video> videos;
  int genreId;
  dynamic genrePoster;
  String? storageCategoryImageFileName;
  bool isExpanded = false;
  AdsByGenre({
    required this.genreName,
    required this.videoCount,
    required this.rowNumber,
    required this.videos,
    required this.genreId,
    required this.genrePoster,
    required this.storageCategoryImageFileName,
  });

  factory AdsByGenre.fromJson(String str) =>
      AdsByGenre.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AdsByGenre.fromMap(Map<String, dynamic> json) => AdsByGenre(
        genreName: json["genre_name"],
        videoCount: json["video_count"],
        rowNumber: json["row_number"],
        videos: List<Video>.from(json["videos"].map((x) => Video.fromMap(x))),
        genreId: json["genre_id"],
        genrePoster: json["genre_poster"],
        storageCategoryImageFileName: json["poster_image_file"],
      );

  Map<String, dynamic> toMap() => {
        "genre_name": genreName,
        "video_count": videoCount,
        "row_number": rowNumber,
        "videos": List<dynamic>.from(videos.map((x) => x.toMap())),
        "genre_id": genreId,
        "genre_poster": genrePoster,
        "poster_image_file": storageCategoryImageFileName,
      };
}

class Video {
  String title;
  int points;
  dynamic status;
  dynamic urlAd;
  dynamic partner;
  int duration;
  String overview;
  int priority;
  int videoId;
  String videoUrl;
  List<String> categories;
  DateTime createdAt;
  String posterPath;
  bool videoStatus;
  dynamic expirationDate;
  String videoFileName;
  String posterFileName;

  Video({
    required this.title,
    required this.points,
    required this.status,
    required this.urlAd,
    required this.partner,
    required this.duration,
    required this.overview,
    required this.priority,
    required this.videoId,
    required this.videoUrl,
    required this.categories,
    required this.createdAt,
    required this.posterPath,
    required this.videoStatus,
    required this.expirationDate,
    required this.videoFileName,
    required this.posterFileName,
  });

  factory Video.fromJson(String str) => Video.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Video.fromMap(Map<String, dynamic> json) => Video(
        title: json["title"],
        points: json["points"],
        status: json["status"],
        urlAd: json["url_ad"],
        partner: json["partner"],
        duration: json["duration"],
        overview: json["overview"],
        priority: json["priority"],
        videoId: json["video_id"],
        videoUrl: json["video_url"],
        categories: List<String>.from(json["categories"].map((x) => x)),
        createdAt: DateTime.parse(json["created_at"]),
        posterPath: json["poster_path"],
        videoStatus: json["video_status"],
        expirationDate: json["expiration_date"],
        videoFileName: json["video_file_name"],
        posterFileName: json["poster_file_name"],
      );

  Map<String, dynamic> toMap() => {
        "title": title,
        "points": points,
        "status": status,
        "url_ad": urlAd,
        "partner": partner,
        "duration": duration,
        "overview": overview,
        "priority": priority,
        "video_id": videoId,
        "video_url": videoUrl,
        "categories": List<dynamic>.from(categories.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
        "poster_path": posterPath,
        "video_status": videoStatus,
        "expiration_date": expirationDate,
        "video_file_name": videoFileName,
        "poster_file_name": posterFileName,
      };
}
