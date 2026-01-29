import 'dart:convert';

class CustomerSubscription {
  int subscriptionId;
  String description;
  double amount;
  String status;
  String createdAt;
  String periodStart;
  String? periodEnd;

  CustomerSubscription({
    required this.subscriptionId,
    required this.description,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.periodStart,
    required this.periodEnd,
  });

  factory CustomerSubscription.fromJson(String str) =>
      CustomerSubscription.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerSubscription.fromMap(Map<String, dynamic> json) =>
      CustomerSubscription(
        subscriptionId: json["subscription_id"],
        description: json["description"],
        amount: json["amount"],
        status: json["status"],
        createdAt: json["created_at"],
        periodStart: json["period_start"],
        periodEnd: json["period_end"],
      );

  Map<String, dynamic> toMap() => {
        "subscription_id": subscriptionId,
        "description": description,
        "amount": amount,
        "status": status,
        "created_at": createdAt,
        "period_start": periodStart,
        "period_end": periodEnd,
      };
}
