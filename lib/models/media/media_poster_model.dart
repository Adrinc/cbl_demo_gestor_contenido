class MediaPosterModel {
  final int mediaPosterId;
  final int mediaFileId;
  final int posterFileId;
  final DateTime? createdAt;

  MediaPosterModel({
    required this.mediaPosterId,
    required this.mediaFileId,
    required this.posterFileId,
    this.createdAt,
  });

  factory MediaPosterModel.fromMap(Map<String, dynamic> map) {
    return MediaPosterModel(
      mediaPosterId: map['media_poster_id'] ?? 0,
      mediaFileId: map['media_file_id'] ?? 0,
      posterFileId: map['poster_file_id'] ?? 0,
      createdAt: map['created_at_timestamp'] != null
          ? DateTime.parse(map['created_at_timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'media_poster_id': mediaPosterId,
      'media_file_id': mediaFileId,
      'poster_file_id': posterFileId,
      'created_at_timestamp': createdAt?.toIso8601String(),
    };
  }

  MediaPosterModel copyWith({
    int? mediaPosterId,
    int? mediaFileId,
    int? posterFileId,
    DateTime? createdAt,
  }) {
    return MediaPosterModel(
      mediaPosterId: mediaPosterId ?? this.mediaPosterId,
      mediaFileId: mediaFileId ?? this.mediaFileId,
      posterFileId: posterFileId ?? this.posterFileId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
