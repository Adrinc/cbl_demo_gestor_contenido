import 'dart:convert';

class CustomerSupport {
  int? customerId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobilePhone;
  String? address;

  CustomerSupport({
    this.customerId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobilePhone,
    this.address,
  });
  String get completeName => '$firstName $lastName';

  factory CustomerSupport.fromJson(String str) =>
      CustomerSupport.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerSupport.fromMap(Map<String, dynamic> json) => CustomerSupport(
        customerId: json["customer_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        mobilePhone: json["mobile_phone"],
        address: json["address"],
      );

  Map<String, dynamic> toMap() => {
        "customer_id": customerId,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile_phone": mobilePhone,
        "address": address,
      };
}
