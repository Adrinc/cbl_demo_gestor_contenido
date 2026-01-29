import 'dart:convert';

class ConexionComponente {
  final String id;
  final String componenteOrigenId;
  final String componenteDestinoId;
  final String? descripcion;
  final bool activo;

  ConexionComponente({
    required this.id,
    required this.componenteOrigenId,
    required this.componenteDestinoId,
    this.descripcion,
    required this.activo,
  });

  factory ConexionComponente.fromMap(Map<String, dynamic> map) {
    return ConexionComponente(
      id: map['id'],
      componenteOrigenId: map['componente_origen_id'],
      componenteDestinoId: map['componente_destino_id'],
      descripcion: map['descripcion'],
      activo: map['activo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'componente_origen_id': componenteOrigenId,
      'componente_destino_id': componenteDestinoId,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  factory ConexionComponente.fromJson(String source) =>
      ConexionComponente.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
