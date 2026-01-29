import 'dart:convert';

class RecentActivity {
  RecentActivity({
    required this.recentActivityId,
    required this.createdAt,
    required this.customerFk,
    required this.activity,
  });

  int recentActivityId;
  DateTime createdAt;
  int customerFk;
  String activity;

  factory RecentActivity.fromJson(String str) => RecentActivity.fromMap(json.decode(str));

  factory RecentActivity.fromMap(Map<String, dynamic> json) {
    return RecentActivity(
      recentActivityId: json["recent_activity_id"],
      createdAt: DateTime.parse(json["created_at"]),
      customerFk: json['customer_fk'],
      activity: json['activity'],
    );
  }
}
