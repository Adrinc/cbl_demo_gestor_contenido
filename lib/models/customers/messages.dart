import 'dart:convert';

class Message {
  Message({
    required this.messageId,
    required this.createdAt,
    required this.customerFk,
    required this.text,
  });

  int messageId;
  DateTime createdAt;
  int customerFk;
  String text;

  factory Message.fromJson(String str) => Message.fromMap(json.decode(str));

  factory Message.fromMap(Map<String, dynamic> json) {
    return Message(
      messageId: json["notification_id"],
      createdAt: DateTime.parse(json["created_at"]),
      customerFk: json['from'],
      text: json['message'] ?? '',
    );
  }
}
