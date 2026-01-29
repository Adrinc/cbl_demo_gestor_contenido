class RolLogicoComponente {
  final int id;
  final String nombre;
  final String? descripcion;

  RolLogicoComponente({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory RolLogicoComponente.fromMap(Map<String, dynamic> map) {
    return RolLogicoComponente(
      id: map['id'] ?? 0,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  RolLogicoComponente copyWith({
    int? id,
    String? nombre,
    String? descripcion,
  }) {
    return RolLogicoComponente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  @override
  String toString() {
    return 'RolLogicoComponente(id: $id, nombre: $nombre, descripcion: $descripcion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RolLogicoComponente &&
        other.id == id &&
        other.nombre == nombre &&
        other.descripcion == descripcion;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nombre.hashCode ^ descripcion.hashCode;
  }
}
