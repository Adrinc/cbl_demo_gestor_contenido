import 'dart:convert';

class Empresa {
  final String id;
  final String nombre;
  final String rfc;
  final String direccion;
  final String telefono;
  final String email;
  final DateTime fechaCreacion;
  final String? logoUrl;
  final String? imagenUrl;

  Empresa({
    required this.id,
    required this.nombre,
    required this.rfc,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.fechaCreacion,
    this.logoUrl,
    this.imagenUrl,
  });

  factory Empresa.fromMap(Map<String, dynamic> map) {
    return Empresa(
      id: map['id'],
      nombre: map['nombre'],
      rfc: map['rfc'],
      direccion: map['direccion'],
      telefono: map['telefono'],
      email: map['email'],
      fechaCreacion: DateTime.parse(map['fecha_creacion']),
      logoUrl: map['logo_url'],
      imagenUrl: map['imagen_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'rfc': rfc,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'logo_url': logoUrl,
      'imagen_url': imagenUrl,
    };
  }

  factory Empresa.fromJson(String source) =>
      Empresa.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
