import 'dart:convert';

import 'package:energy_media/models/users/role.dart';

class User {
  User({
    required this.id,
    required this.sequentialId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.mobilePhone,
    required this.status,
    this.image,
  });

  String id;
  int sequentialId;
  String firstName;
  String lastName;
  Role role;
  String email;
  String? mobilePhone;
  String status;
  String? image;

  String get fullName => '$firstName $lastName';

  int get statusColor {
    late final int color;
    switch (status) {
      case 'Active':
        color = 0XFF2EA437;
        break;
      default:
        color = 0XFF2EA437;
    }
    return color;
  }

  bool get isAdmin => role.name == 'Administrator';
  bool get isInventory => role.name == 'Inventory Warehouse';
  bool get isSales => role.name == 'Sales Rep';
  bool get isSupport => role.name == 'Support';
  bool get isOperation => role.name == 'Operation';

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  factory User.fromMap(Map<String, dynamic> json) {
    User user = User(
      id: json["user_profile_id"],
      sequentialId: json["sequential_id"],
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: Role.fromMap(json['role']),
      email: json["email"],
      mobilePhone: json['mobile_phone'],
      status: json['status'],
      image: json['image'],
    );

    return user;
  }

  User copyWith({
    String? id,
    int? sequentialId,
    String? firstName,
    String? lastName,
    Role? role,
    String? email,
    String? mobilePhone,
    String? status,
    String? image,
  }) {
    return User(
      id: id ?? this.id,
      sequentialId: sequentialId ?? this.sequentialId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      email: email ?? this.email,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      status: status ?? this.status,
      image: image ?? this.image,
    );
  }
}
