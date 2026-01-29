import 'dart:convert';

class Customer {
  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.status,
    required this.phoneNumber,
    required this.balance,
    this.image,
  });

  int id;
  String firstName;
  String lastName;
  String email;
  DateTime createdAt;
  String status;
  String phoneNumber;
  num balance;
  String? image;

  String get fullName => '$firstName $lastName';

  factory Customer.fromJson(String str) => Customer.fromMap(json.decode(str));

  factory Customer.fromMap(Map<String, dynamic> json) {
    Customer customer = Customer(
      id: json["customer_id"],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json["email"],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
      phoneNumber: json['mobile_phone'],
      balance: json['balance'] ?? 0.00,
      image: json['image'],
    );

    return customer;
  }
}
