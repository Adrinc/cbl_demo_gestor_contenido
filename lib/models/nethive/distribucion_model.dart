import 'dart:convert';

class Distribucion {
  final String id;
  final String negocioId;
  final String tipo; // 'MDF' o 'IDF'
  final String nombre;
  final String? descripcion;

  Distribucion({
    required this.id,
    required this.negocioId,
    required this.tipo,
    required this.nombre,
    this.descripcion,
  });

  factory Distribucion.fromMap(Map<String, dynamic> map) {
    return Distribucion(
      id: map['id'],
      negocioId: map['negocio_id'],
      tipo: map['tipo'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'negocio_id': negocioId,
      'tipo': tipo,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  factory Distribucion.fromJson(String source) =>
      Distribucion.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
