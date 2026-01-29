import 'dart:convert';

class CustomerDashboards {
    int? customerId;
    DateTime? createdAt;
    String? firstName;
    String? lastName;
    String? status;

    CustomerDashboards({
        this.customerId,
        this.createdAt,
        this.firstName,
        this.lastName,
        this.status,
    });

    factory CustomerDashboards.fromJson(String str) => CustomerDashboards.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory CustomerDashboards.fromMap(Map<String, dynamic> json) => CustomerDashboards(
        customerId: json["customer_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        firstName: json["first_name"],
        lastName: json["last_name"],
        status: json["status"],
    );

    Map<String, dynamic> toMap() => {
        "customer_id": customerId,
        "created_at": createdAt?.toIso8601String(),
        "first_name": firstName,
        "last_name": lastName,
        "status": status,
    };
}
