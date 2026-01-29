import 'dart:convert';

class CustomerMarcadores {
    int? id;
    DateTime? createdAt;
    double? customersTotals;
    double? activeTotals;
    double? leadTotals;
    List<NewCustomersId>? newCustomersId;

    CustomerMarcadores({
        this.id,
        this.createdAt,
        this.customersTotals,
        this.activeTotals,
        this.leadTotals,
        this.newCustomersId,
    });

    factory CustomerMarcadores.fromJson(String str) => CustomerMarcadores.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory CustomerMarcadores.fromMap(Map<String, dynamic> json) => CustomerMarcadores(
        id: json["id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        customersTotals: json["customers_totals"],
        activeTotals: json["active_totals"],
        leadTotals: json["lead_totals"],
        newCustomersId: json["new_customers_id"] == null ? [] : List<NewCustomersId>.from(json["new_customers_id"]!.map((x) => NewCustomersId.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "created_at": createdAt?.toIso8601String(),
        "customers_totals": customersTotals,
        "active_totals": activeTotals,
        "lead_totals": leadTotals,
        "new_customers_id": newCustomersId == null ? [] : List<dynamic>.from(newCustomersId!.map((x) => x.toMap())),
    };
}

class NewCustomersId {
    int? count;
    String? status;
    DateTime? createdAt;
    List<int>? customerIds;

    NewCustomersId({
        this.count,
        this.status,
        this.createdAt,
        this.customerIds,
    });

    factory NewCustomersId.fromJson(String str) => NewCustomersId.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NewCustomersId.fromMap(Map<String, dynamic> json) => NewCustomersId(
        count: json["count"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        customerIds: json["customer_ids"] == null ? [] : List<int>.from(json["customer_ids"]!.map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "count": count,
        "status": status,
        "created_at": "${createdAt!.year.toString().padLeft(4, '0')}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}",
        "customer_ids": customerIds == null ? [] : List<dynamic>.from(customerIds!.map((x) => x)),
    };
}
