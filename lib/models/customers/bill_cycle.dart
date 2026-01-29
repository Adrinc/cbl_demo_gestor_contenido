import 'dart:convert';

class BillCycle {
  BillCycle({
    required this.customerId,
    required this.day,
    required this.billDueDay,
    required this.graceDays,
    required this.frequency,
  });

  int customerId;
  int day;
  int billDueDay;
  int graceDays;
  int frequency;

  factory BillCycle.fromJson(String str) => BillCycle.fromMap(json.decode(str));

  factory BillCycle.fromMap(Map<String, dynamic> json) {
    BillCycle billCycle = BillCycle(
      customerId: json["customer_id"],
      day: json['day'],
      billDueDay: json['bill_due_day'],
      graceDays: json['grace_days'],
      frequency: json['frequency'],
    );

    return billCycle;
  }
}
