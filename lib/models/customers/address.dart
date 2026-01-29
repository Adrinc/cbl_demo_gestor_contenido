import 'dart:convert';

import 'package:energy_media/models/state.dart';

class Address {
  Address({
    required this.id,
    required this.address1,
    required this.address2,
    required this.zipcode,
    required this.city,
    required this.stateFk,
    required this.state,
    required this.country,
  });

  int id;
  String address1;
  String? address2;
  String zipcode;
  String city;
  int stateFk;
  StateAPI state;
  String country;

  String get fullAddress => '$address1 $city, ${state.code} $zipcode $country';

  factory Address.fromJson(String str) => Address.fromMap(json.decode(str));

  factory Address.fromMap(Map<String, dynamic> json) {
    Address address = Address(
      id: json["address_id"],
      address1: json['address_1'],
      address2: json['address_2'],
      zipcode: json['zipcode'],
      city: json['city'],
      stateFk: json['state_fk'],
      state: StateAPI.fromMap(json['state']),
      country: json['country'],
    );

    return address;
  }
}
