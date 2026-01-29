import 'dart:convert';

class StateAPI {
  StateAPI({
    required this.id,
    required this.code,
    required this.name,
  });

  int id;
  String code;
  String name;

  factory StateAPI.fromJson(String str) => StateAPI.fromMap(json.decode(str));

  factory StateAPI.fromMap(Map<String, dynamic> json) {
    return StateAPI(
      id: json["state_id"],
      code: json['code'],
      name: json['name'],
    );
  }
}
