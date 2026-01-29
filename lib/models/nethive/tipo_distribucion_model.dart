class TipoDistribucion {
  final int id;
  final String nombre;

  TipoDistribucion({
    required this.id,
    required this.nombre,
  });

  factory TipoDistribucion.fromMap(Map<String, dynamic> map) {
    return TipoDistribucion(
      id: map['id'] ?? 0,
      nombre: map['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  TipoDistribucion copyWith({
    int? id,
    String? nombre,
  }) {
    return TipoDistribucion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }

  @override
  String toString() {
    return 'TipoDistribucion(id: $id, nombre: $nombre)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TipoDistribucion &&
        other.id == id &&
        other.nombre == nombre;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode;
  }
}
