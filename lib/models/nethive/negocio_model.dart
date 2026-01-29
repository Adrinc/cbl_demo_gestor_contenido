import 'dart:convert';

class Negocio {
  final String id;
  final String empresaId;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String tipoLocal;
  final DateTime fechaCreacion;
  final String? logoUrl;
  final String? imagenUrl;

  Negocio({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.tipoLocal,
    required this.fechaCreacion,
    this.logoUrl,
    this.imagenUrl,
  });

  factory Negocio.fromMap(Map<String, dynamic> map) {
    return Negocio(
      id: map['id'],
      empresaId: map['empresa_id'],
      nombre: map['nombre'],
      direccion: map['direccion'],
      latitud: map['latitud'].toDouble(),
      longitud: map['longitud'].toDouble(),
      tipoLocal: map['tipo_local'],
      fechaCreacion: DateTime.parse(map['fecha_creacion']),
      logoUrl: map['logo_url'],
      imagenUrl: map['imagen_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'nombre': nombre,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'tipo_local': tipoLocal,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'logo_url': logoUrl,
      'imagen_url': imagenUrl,
    };
  }

  factory Negocio.fromJson(String source) =>
      Negocio.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
