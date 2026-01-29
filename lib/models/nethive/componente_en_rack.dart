import 'dart:convert';

class ComponenteEnRack {
  final String id;
  final String rackId;
  final String componenteId;
  final int? posicionU;
  final DateTime fechaRegistro;

  ComponenteEnRack({
    required this.id,
    required this.rackId,
    required this.componenteId,
    this.posicionU,
    required this.fechaRegistro,
  });

  factory ComponenteEnRack.fromMap(Map<String, dynamic> map) {
    return ComponenteEnRack(
      id: map['id'] ?? '',
      rackId: map['rack_id'] ?? '',
      componenteId: map['componente_id'] ?? '',
      posicionU: map['posicion_u'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rack_id': rackId,
      'componente_id': componenteId,
      'posicion_u': posicionU,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  factory ComponenteEnRack.fromJson(String source) =>
      ComponenteEnRack.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
