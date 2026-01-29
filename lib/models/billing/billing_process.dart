import 'dart:convert';

class BillingProcess {
  BillingProcess({
    required this.billingProcessId,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    required this.customersBilled,
    required this.totalBilled,
  });

  int billingProcessId;
  DateTime createdAt;
  String createdBy;
  String status;
  int customersBilled;
  num totalBilled;

  factory BillingProcess.fromJson(String str) => BillingProcess.fromMap(json.decode(str));

  factory BillingProcess.fromMap(Map<String, dynamic> json) {
    BillingProcess billingProcess = BillingProcess(
      billingProcessId: json["billing_process_id"],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      status: json['status'],
      customersBilled: json['customers_billed'],
      totalBilled: json['total_billed'],
    );

    return billingProcess;
  }
}
