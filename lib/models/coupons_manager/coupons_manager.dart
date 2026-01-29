import 'dart:convert';

class CouponsModel {
  int rowNumber;
  int couponId;
  DateTime createdAt;
  DateTime updateAt;
  String title;
  String description;
  String termConditions;
  num discountValue;
  String discountTypeName;
  String discountTypeDescription;
  DateTime startDate;
  DateTime endDate;
  bool isActive;
  int usageLimit;
  String categoryName;
  bool categoryVisible;
  String categoryImageFile;
  bool videoRequired;
  dynamic couponImageFile;
  dynamic outLink;
  List<Map<String, dynamic>> qrCodes;

  CouponsModel({
    required this.rowNumber,
    required this.couponId,
    required this.createdAt,
    required this.updateAt,
    required this.title,
    required this.description,
    required this.termConditions,
    required this.discountValue,
    required this.discountTypeName,
    required this.discountTypeDescription,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.usageLimit,
    required this.categoryName,
    required this.categoryVisible,
    required this.categoryImageFile,
    required this.videoRequired,
    required this.couponImageFile,
    required this.outLink,
    required this.qrCodes,
  });

  factory CouponsModel.fromMap(Map<String, dynamic> json) {
    // Aseguramos que qrCodes sea una lista de Map<String, dynamic>
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
    return CouponsModel(
      rowNumber: json["row_number"],
      couponId: json["coupon_id"],
      createdAt: DateTime.parse(json["created_at"]),
      updateAt: DateTime.parse(json["update_at"]),
      title: json["title"],
      description: json["description"],
      termConditions: json["term_conditions"],
      discountValue: json["discount_value"],
      discountTypeName: json["discount_type_name"],
      discountTypeDescription: json["discount_type_description"],
      startDate: DateTime.parse(json["start_date"]),
      endDate: DateTime.parse(json["end_date"]),
      isActive: json["is_active"],
      usageLimit: json["usage_limit"],
      categoryName: json["category_name"],
      categoryVisible: json["category_visible"],
      categoryImageFile: json["category_image_file"],
      videoRequired: json["video_required"],
      couponImageFile: json["coupon_image_file"],
      outLink: json["out_link"],
      qrCodes: parsedQrCodes.cast<Map<String, dynamic>>(),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "row_number": rowNumber,
        "coupon_id": couponId,
        "created_at": createdAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
        "title": title,
        "description": description,
        "term_conditions": termConditions,
        "discount_value": discountValue,
        "discount_type_name": discountTypeName,
        "discount_type_description": discountTypeDescription,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "is_active": isActive,
        "usage_limit": usageLimit,
        "category_name": categoryName,
        "category_visible": categoryVisible,
        "category_image_file": categoryImageFile,
        "video_required": videoRequired,
        "coupon_image_file": couponImageFile,
        "out_link": outLink,
        "qr_codes": qrCodes,
      };
}
