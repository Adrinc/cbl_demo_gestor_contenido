class MediaCategoryModel {
  final int mediaCategoriesId;
  final DateTime? createdAt;
  final String? createdBy;
  final String categoryName;
  final String? categoryDescription;
  final int? mediaFileFk;

  MediaCategoryModel({
    required this.mediaCategoriesId,
    this.createdAt,
    this.createdBy,
    required this.categoryName,
    this.categoryDescription,
    this.mediaFileFk,
  });

  factory MediaCategoryModel.fromMap(Map<String, dynamic> map) {
    return MediaCategoryModel(
      mediaCategoriesId: map['media_categories_id'] ?? 0,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      createdBy: map['created_by'],
      categoryName: map['category_name'] ?? '',
      categoryDescription: map['category_description'],
      mediaFileFk: map['media_file_fk'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'media_categories_id': mediaCategoriesId,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'category_name': categoryName,
      'category_description': categoryDescription,
      'media_file_fk': mediaFileFk,
    };
  }

  MediaCategoryModel copyWith({
    int? mediaCategoriesId,
    DateTime? createdAt,
    String? createdBy,
    String? categoryName,
    String? categoryDescription,
    int? mediaFileFk,
  }) {
    return MediaCategoryModel(
      mediaCategoriesId: mediaCategoriesId ?? this.mediaCategoriesId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      categoryName: categoryName ?? this.categoryName,
      categoryDescription: categoryDescription ?? this.categoryDescription,
      mediaFileFk: mediaFileFk ?? this.mediaFileFk,
    );
  }
}
