class ConexionAlimentacion {
  final String id;
  final String origenId;
  final String destinoId;
  final String? cableId;
  final String? descripcion;
  final bool activo;

  ConexionAlimentacion({
    required this.id,
    required this.origenId,
    required this.destinoId,
    this.cableId,
    this.descripcion,
    required this.activo,
  });

  factory ConexionAlimentacion.fromMap(Map<String, dynamic> map) {
    return ConexionAlimentacion(
      id: map['id'] ?? '',
      origenId: map['origen_id'] ?? '',
      destinoId: map['destino_id'] ?? '',
      cableId: map['cable_id'],
      descripcion: map['descripcion'],
      activo: map['activo'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'origen_id': origenId,
      'destino_id': destinoId,
      'cable_id': cableId,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
