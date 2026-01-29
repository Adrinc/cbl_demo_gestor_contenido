import 'dart:convert';

class MediaFileModel {
  final int mediaFileId;
  final String fileName;
  final String? title;
  final String? fileDescription;
  final String? fileType;
  final String? mimeType;
  final String? fileExtension;
  final int? fileSizeBytes;
  final String? fileUrl;
  final String? storagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? uploadedByUserId;
  final bool? isPublicFile;
  final Map<String, dynamic>? metadataJson;
  final int? seconds;
  final int? mediaCategoryFk;
  final int organizationFk;

  MediaFileModel({
    required this.mediaFileId,
    required this.fileName,
    this.title,
    this.fileDescription,
    this.fileType,
    this.mimeType,
    this.fileExtension,
    this.fileSizeBytes,
    this.fileUrl,
    this.storagePath,
    this.createdAt,
    this.updatedAt,
    this.uploadedByUserId,
    this.isPublicFile,
    this.metadataJson,
    this.seconds,
    this.mediaCategoryFk,
    required this.organizationFk,
  });

  factory MediaFileModel.fromMap(Map<String, dynamic> map) {
    return MediaFileModel(
      mediaFileId: map['media_file_id'] ?? 0,
      fileName: map['file_name'] ?? '',
      title: map['title'],
      fileDescription: map['file_description'],
      fileType: map['file_type'],
      mimeType: map['mime_type'],
      fileExtension: map['file_extension'],
      fileSizeBytes: map['file_size_bytes'],
      fileUrl: map['file_url'],
      storagePath: map['storage_path'],
      createdAt: map['created_at_timestamp'] != null
          ? DateTime.parse(map['created_at_timestamp'])
          : null,
      updatedAt: map['updated_at_timestamp'] != null
          ? DateTime.parse(map['updated_at_timestamp'])
          : null,
      uploadedByUserId: map['uploaded_by_user_id'],
      isPublicFile: map['is_public_file'],
      metadataJson: map['metadata_json'] != null
          ? (map['metadata_json'] is String
              ? jsonDecode(map['metadata_json'])
              : map['metadata_json'])
          : null,
      seconds: map['seconds'],
      mediaCategoryFk: map['media_category_fk'],
      organizationFk: map['organization_fk'] ?? 17,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'media_file_id': mediaFileId,
      'file_name': fileName,
      'title': title,
      'file_description': fileDescription,
      'file_type': fileType,
      'mime_type': mimeType,
      'file_extension': fileExtension,
      'file_size_bytes': fileSizeBytes,
      'file_url': fileUrl,
      'storage_path': storagePath,
      'created_at_timestamp': createdAt?.toIso8601String(),
      'updated_at_timestamp': updatedAt?.toIso8601String(),
      'uploaded_by_user_id': uploadedByUserId,
      'is_public_file': isPublicFile,
      'metadata_json': metadataJson,
      'seconds': seconds,
      'media_category_fk': mediaCategoryFk,
      'organization_fk': organizationFk,
    };
  }

  MediaFileModel copyWith({
    int? mediaFileId,
    String? fileName,
    String? title,
    String? fileDescription,
    String? fileType,
    String? mimeType,
    String? fileExtension,
    int? fileSizeBytes,
    String? fileUrl,
    String? storagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? uploadedByUserId,
    bool? isPublicFile,
    Map<String, dynamic>? metadataJson,
    int? seconds,
    int? mediaCategoryFk,
    int? organizationFk,
  }) {
    return MediaFileModel(
      mediaFileId: mediaFileId ?? this.mediaFileId,
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      fileDescription: fileDescription ?? this.fileDescription,
      fileType: fileType ?? this.fileType,
      mimeType: mimeType ?? this.mimeType,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileUrl: fileUrl ?? this.fileUrl,
      storagePath: storagePath ?? this.storagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uploadedByUserId: uploadedByUserId ?? this.uploadedByUserId,
      isPublicFile: isPublicFile ?? this.isPublicFile,
      metadataJson: metadataJson ?? this.metadataJson,
      seconds: seconds ?? this.seconds,
      mediaCategoryFk: mediaCategoryFk ?? this.mediaCategoryFk,
      organizationFk: organizationFk ?? this.organizationFk,
    );
  }

  // Helper getters for metadata_json
  int get reproducciones => metadataJson?['reproducciones'] ?? 0;
  DateTime? get uploadedAt => metadataJson?['uploaded_at'] != null
      ? DateTime.tryParse(metadataJson!['uploaded_at'])
      : null;
  List<String> get categorias =>
      (metadataJson?['categorias'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];
  String? get originalFileName => metadataJson?['original_file_name'];
  int? get durationSeconds => metadataJson?['duration_seconds'];
  String? get resolution => metadataJson?['resolution'];
  DateTime? get lastViewedAt => metadataJson?['last_viewed_at'] != null
      ? DateTime.tryParse(metadataJson!['last_viewed_at'])
      : null;

  // Poster information from metadata_json
  String? get posterUrl => metadataJson?['poster_url'];
  String? get posterFileName => metadataJson?['poster_file_name'];
  int? get fileSizeBytesFromMetadata => metadataJson?['file_size_bytes'];

  // Tags from metadata_json
  List<String> get tags =>
      (metadataJson?['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];
}
