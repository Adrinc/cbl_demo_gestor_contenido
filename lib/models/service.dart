import 'dart:convert';

class Service {
  Service({
    required this.serviceId,
    required this.code,
    required this.name,
    this.description,
    required this.transactionTypeFk,
    required this.type,
    required this.value,
  });

  int serviceId;
  String code;
  String name;
  String? description;
  int transactionTypeFk;
  String? type;
  num value;

  factory Service.fromJson(String str) => Service.fromMap(json.decode(str));

  factory Service.fromMap(Map<String, dynamic> json) {
    Service service = Service(
      serviceId: json["service_id"],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      transactionTypeFk: json['transaction_type_fk'],
      type: json['type'],
      value: json['value'],
    );

    return service;
  }
}

class CustomerService {
  CustomerService({
    required this.quantity,
    required this.createdAt,
    required this.details,
  });

  int quantity;
  DateTime createdAt;
  Service details;

  factory CustomerService.fromJson(String str) => CustomerService.fromMap(json.decode(str));

  factory CustomerService.fromMap(Map<String, dynamic> json) {
    CustomerService customerService = CustomerService(
      quantity: json["quantity"],
      createdAt: DateTime.parse(json['created_at']),
      details: Service.fromMap(json),
    );

    return customerService;
  }
}
