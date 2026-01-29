import 'dart:convert';

class Note {
  Note({
    required this.noteId,
    required this.createdAt,
    required this.customerFk,
    required this.text,
  });

  int noteId;
  DateTime createdAt;
  int customerFk;
  String text;

  factory Note.fromJson(String str) => Note.fromMap(json.decode(str));

  factory Note.fromMap(Map<String, dynamic> json) {
    Note note = Note(
      noteId: json["note_id"],
      createdAt: DateTime.parse(json["created_at"]),
      customerFk: json['customer_fk'],
      text: json['note'] ?? '',
    );

    return note;
  }
}
