import 'dart:convert';

class AllAdsOneTableModel {
  final int id;
  final int? rowNumber; // Opcional, para el campo row_number
  final DateTime createdAt;
  final DateTime updatedAt;
  final String overview;
  final String posterPath;
  final String title;
  final String video; // Corresponde a video_url
  final int durationVideo;
  final dynamic urlAd; // Añadido para url_ad
  final int priority;
  final bool videoStatus; // Cambiado de status text a videoStatus boolean
  final dynamic expirationDate;
  final int points;
  final String? videoFileName;
  final dynamic partner;
  final String posterFileName;
  final List<dynamic> categories;
  final List<Map<String, dynamic>>
      qrCodes; // Puede ser List<dynamic> o Map<String, dynamic>
  final int warningCount;

  AllAdsOneTableModel({
    required this.id,
    this.rowNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.overview,
    required this.posterPath,
    required this.title,
    required this.video,
    required this.durationVideo,
    this.urlAd, // Añadido
    required this.priority,
    required this.videoStatus, // Requerido y de tipo bool
    this.expirationDate,
    required this.points,
    this.videoFileName,
    this.partner,
    required this.posterFileName,
    required this.categories,
    required this.qrCodes,
    required this.warningCount,
  });

  factory AllAdsOneTableModel.fromJson(String str) =>
      AllAdsOneTableModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AllAdsOneTableModel.fromMap(Map<String, dynamic> json) {
    // Procesamiento de qrCodes similar al de CouponsModel
    final rawQrCodes = json["qr_codes"];

    final parsedQrCodes = rawQrCodes is List
        ? rawQrCodes
            .map((e) {
              if (e is String) {
                try {
                  return Map<String, dynamic>.from(jsonDecode(e));
                } catch (e) {
                  return {};
                }
              } else if (e is Map) {
                return Map<String, dynamic>.from(e);
              } else {
                return {};
              }
            })
            .toList()
            .cast<Map<String, dynamic>>() // 🔥 necesario sí o sí
        : [];

    return AllAdsOneTableModel(
      id: json["video_id"] ?? json["id"],
      rowNumber: json["row_number"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      overview: json["overview"],
      posterPath: json["poster_path"],
      title: json["title"],
      video: json["video_url"],
      durationVideo: json["duration_video"],
      urlAd: json["url_ad"], // Mapeo para url_ad
      priority: json["priority"],
      videoStatus: json["video_status"], // Mapeo para video_status
      expirationDate: json["expiration_date"],
      points: json["points"],
      videoFileName: json["video_file_name"],
      partner: json["partner"],
      posterFileName: json["poster_file_name"],
      categories: json["categories"] == null
          ? []
          : List<dynamic>.from(json["categories"].map((x) => x)),
      qrCodes: parsedQrCodes.cast<Map<String, dynamic>>(),
      warningCount: json["warning_count"],
    );
  }

  Map<String, dynamic> toMap() => {
        "video_id": id,
        "row_number": rowNumber,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "overview": overview,
        "poster_path": posterPath,
        "title": title,
        "video_url": video,
        "duration_video": durationVideo,
        "url_ad": urlAd, // Añadido
        "priority": priority,
        "video_status": videoStatus,
        "expiration_date": expirationDate,
        "points": points,
        "video_file_name": videoFileName,
        "partner": partner,
        "poster_file_name": posterFileName,
        "categories": List<dynamic>.from(categories.map((x) => x)),
        "qr_codes": qrCodes,
        "warning_count": warningCount,
      };
}
