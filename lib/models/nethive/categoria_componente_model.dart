import 'dart:convert';

class CategoriaComponente {
  final int id;
  final String nombre;

  CategoriaComponente({
    required this.id,
    required this.nombre,
  });

  factory CategoriaComponente.fromMap(Map<String, dynamic> map) {
    return CategoriaComponente(
      id: map['id'],
      nombre: map['nombre'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory CategoriaComponente.fromJson(String source) =>
      CategoriaComponente.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
