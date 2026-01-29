import 'dart:convert';

class Invoice {
  Invoice({
    required this.invoiceId,
    required this.date,
    required this.code,
  });

  int invoiceId;
  DateTime date;
  String code;

  factory Invoice.fromJson(String str) => Invoice.fromMap(json.decode(str));

  factory Invoice.fromMap(Map<String, dynamic> json) {
    Invoice invoice = Invoice(
      invoiceId: json['invoice_id'],
      date: DateTime.parse(json["created_at"]),
      code: json['invoice'],
    );

    return invoice;
  }
}
