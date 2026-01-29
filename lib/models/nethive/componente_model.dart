import 'dart:convert';

class Componente {
  final String id;
  final String negocioId;
  final int categoriaId;
  final String nombre;
  final String? descripcion;
  final bool enUso;
  final bool activo;
  final String? ubicacion;
  final String? imagenUrl;
  final DateTime fechaRegistro;
  final String? distribucionId; // ← Nuevo (si lo usas)
  final String? rolLogicoId; // ← NUEVO

  Componente({
    required this.id,
    required this.negocioId,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.enUso,
    required this.activo,
    this.ubicacion,
    this.imagenUrl,
    required this.fechaRegistro,
    this.distribucionId,
    this.rolLogicoId,
  });

  factory Componente.fromMap(Map<String, dynamic> map) {
    return Componente(
      id: map['id'],
      negocioId: map['negocio_id'],
      categoriaId: map['categoria_id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      enUso: map['en_uso'],
      activo: map['activo'],
      ubicacion: map['ubicacion'],
      imagenUrl: map['imagen_url'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
      distribucionId: map['distribucion_id'],
      rolLogicoId: map['rol_logico_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'negocio_id': negocioId,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'en_uso': enUso,
      'activo': activo,
      'ubicacion': ubicacion,
      'imagen_url': imagenUrl,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'distribucion_id': distribucionId,
      'rol_logico_id': rolLogicoId,
    };
  }

  factory Componente.fromJson(String source) =>
      Componente.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
