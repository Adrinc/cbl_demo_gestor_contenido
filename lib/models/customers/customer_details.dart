import 'dart:convert';

import 'package:energy_media/models/models.dart';

class CustomerDetails {
  CustomerDetails({
    required this.id,
    required this.createdDate,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.billingAddress,
    required this.status,
    required this.phoneNumber,
    required this.balance,
    this.image,
    required this.billCycle,
    required this.services,
    required this.notes,
    required this.messages,
  });

  int id;
  DateTime createdDate;
  String firstName;
  String lastName;
  String email;
  Address billingAddress;
  String status;
  String phoneNumber;
  num balance;
  String? image;
  BillCycle billCycle;
  List<Service> services;
  List<Note> notes;
  List<Message> messages;

  String get fullName => '$firstName $lastName';

  DateTime get billingDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, billCycle.day);
  }

  factory CustomerDetails.fromJson(String str) =>
      CustomerDetails.fromMap(json.decode(str));

  factory CustomerDetails.fromMap(Map<String, dynamic> json) {
    CustomerDetails customer = CustomerDetails(
      id: json["customer_id"],
      createdDate: DateTime.parse(json['created_date']),
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json["email"],
      billingAddress: Address.fromMap(json['billing_address']),
      status: json['status'],
      phoneNumber: json['mobile_phone'],
      balance: json['balance'] ?? 0.00,
      image: json['image'],
      billCycle: BillCycle.fromMap(json['billing_cycle']),
      services: (json['services'] as List)
          .map((service) => Service.fromMap(service))
          .toList(),
      notes: (json['notes'] as List).map((note) => Note.fromMap(note)).toList(),
      messages: (json['messages'] as List)
          .map((note) => Message.fromMap(note))
          .toList(),
    );

    return customer;
  }
}
