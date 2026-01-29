import 'dart:convert';

class Payment {
  Payment({
    required this.paymentId,
    required this.transactionId,
    required this.date,
    required this.method,
    required this.description,
    required this.status,
    required this.amount,
    required this.error,
  });

  int transactionId;
  int paymentId;
  DateTime date;
  String method;
  String description;
  String status;
  num amount;
  String error;

  // String get displayValue => creditCard == '-' ? creditCard : '****$last4Digits';

  // String get last4Digits => creditCard.substring(creditCard.length - 4);

  factory Payment.fromJson(String str) => Payment.fromMap(json.decode(str));

  factory Payment.fromMap(Map<String, dynamic> json) {
    Payment payment = Payment(
      paymentId: json['payment_id'],
      transactionId: json['transaction_id'],
      date: DateTime.parse(json["date"]),
      method: json['method'],
      description: json['description'],
      status: json['status'],
      amount: json['amount'],
      error: json['error'] ?? '',
    );

    return payment;
  }
}
