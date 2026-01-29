/// Model for vw_media_files_with_posters view
class MediaWithPosterModel {
  final int mediaFileId;
  final String? mediaFileName;
  final String? mediaTitle;
  final String? fileDescription;
  final String? mediaType;
  final String? mediaMimeType;
  final String? mediaUrl;
  final String? mediaStoragePath;
  final DateTime? mediaCreatedAt;
  final int? categoryId;
  final String? categoryName;
  final String? categoryDescription;
  final DateTime? categoryCreatedAt;
  final String? categoryImageUrl;
  final String? categoryImageStoragePath;
  final int? mediaPosterId;
  final int? posterFileId;
  final String? posterFileName;
  final String? posterTitle;
  final String? posterUrl;
  final String? posterStoragePath;
  final DateTime? posterCreatedAt;

  MediaWithPosterModel({
    required this.mediaFileId,
    this.mediaFileName,
    this.mediaTitle,
    this.fileDescription,
    this.mediaType,
    this.mediaMimeType,
    this.mediaUrl,
    this.mediaStoragePath,
    this.mediaCreatedAt,
    this.categoryId,
    this.categoryName,
    this.categoryDescription,
    this.categoryCreatedAt,
    this.categoryImageUrl,
    this.categoryImageStoragePath,
    this.mediaPosterId,
    this.posterFileId,
    this.posterFileName,
    this.posterTitle,
    this.posterUrl,
    this.posterStoragePath,
    this.posterCreatedAt,
  });

  factory MediaWithPosterModel.fromMap(Map<String, dynamic> map) {
    return MediaWithPosterModel(
      mediaFileId: map['media_file_id'] ?? 0,
      mediaFileName: map['media_file_name'],
      mediaTitle: map['media_title'],
      fileDescription: map['file_description'],
      mediaType: map['media_type'],
      mediaMimeType: map['media_mime_type'],
      mediaUrl: map['media_url'],
      mediaStoragePath: map['media_storage_path'],
      mediaCreatedAt: map['media_created_at'] != null
          ? DateTime.parse(map['media_created_at'])
          : null,
      categoryId: map['category_id'],
      categoryName: map['category_name'],
      categoryDescription: map['category_description'],
      categoryCreatedAt: map['category_created_at'] != null
          ? DateTime.parse(map['category_created_at'])
          : null,
      categoryImageUrl: map['category_image_url'],
      categoryImageStoragePath: map['category_image_storage_path'],
      mediaPosterId: map['media_poster_id'],
      posterFileId: map['poster_file_id'],
      posterFileName: map['poster_file_name'],
      posterTitle: map['poster_title'],
      posterUrl: map['poster_url'],
      posterStoragePath: map['poster_storage_path'],
      posterCreatedAt: map['poster_created_at'] != null
          ? DateTime.parse(map['poster_created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'media_file_id': mediaFileId,
      'media_file_name': mediaFileName,
      'media_title': mediaTitle,
      'file_description': fileDescription,
      'media_type': mediaType,
      'media_mime_type': mediaMimeType,
      'media_url': mediaUrl,
      'media_storage_path': mediaStoragePath,
      'media_created_at': mediaCreatedAt?.toIso8601String(),
      'category_id': categoryId,
      'category_name': categoryName,
      'category_description': categoryDescription,
      'category_created_at': categoryCreatedAt?.toIso8601String(),
      'category_image_url': categoryImageUrl,
      'category_image_storage_path': categoryImageStoragePath,
      'media_poster_id': mediaPosterId,
      'poster_file_id': posterFileId,
      'poster_file_name': posterFileName,
      'poster_title': posterTitle,
      'poster_url': posterUrl,
      'poster_storage_path': posterStoragePath,
      'poster_created_at': posterCreatedAt?.toIso8601String(),
    };
  }

  /// Helper getter to get poster or fallback to category image
  String? get displayImageUrl => posterUrl ?? categoryImageUrl;
}
