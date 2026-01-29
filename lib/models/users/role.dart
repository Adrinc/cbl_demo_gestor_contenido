import 'dart:convert';

class Role {
  Role({
    required this.name,
    required this.roleId,
    required this.permissions,
  });

  String name;
  int roleId;
  Permissions permissions;

  factory Role.fromJson(String str) => Role.fromMap(json.decode(str));

  factory Role.fromMap(Map<String, dynamic> json) => Role(
        name: json["name"],
        roleId: json["role_id"],
        permissions: Permissions.fromMap(json["permissions"]),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role && other.name == name && other.roleId == roleId;
  }

  @override
  int get hashCode => Object.hash(name, roleId, permissions);
}

class Permissions {
  Permissions({
    required this.home,
    required this.crm,
    required this.qr,
    required this.orders,
    required this.inventory,
    required this.serviceOrder,
    required this.support,
    required this.sales,
    required this.billing,
    required this.technical,
    required this.users,
    required this.limited,
  });

  String? home;
  String? crm;
  String? qr;
  String? orders;
  String? inventory;
  String? serviceOrder;
  String? sales;
  String? support;
  String? billing;
  String? users;
  String? technical;
  bool? limited;

  factory Permissions.fromJson(String str) =>
      Permissions.fromMap(json.decode(str));

  factory Permissions.fromMap(Map<String, dynamic> json) => Permissions(
        home: json['Home'],
        crm: json['CRM'],
        qr: json['QR'],
        orders: json['Orders'],
        inventory: json['Inventory'],
        serviceOrder: json['Service Order'],
        sales: json['Sales'],
        support: json['Support'],
        billing: json['Billing'],
        users: json['Users'],
        technical: json["Technical"],
        limited: json["Limited"],
      );
}
