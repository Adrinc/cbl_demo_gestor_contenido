import 'dart:convert';

class Transaction {
  Transaction(
      {required this.date,
      required this.description,
      required this.type,
      required this.amount,
      required this.status});

  DateTime date;
  String description;
  String type;
  num amount;
  String status;

  factory Transaction.fromJson(String str) =>
      Transaction.fromMap(json.decode(str));

  factory Transaction.fromMap(Map<String, dynamic> json) {
    Transaction transaction = Transaction(
        date: DateTime.parse(json["created_at"]),
        description: json['description'],
        type: json['type_transaction'],
        amount: json['total_amout'],
        status: json['status']);

    return transaction;
  }
}
