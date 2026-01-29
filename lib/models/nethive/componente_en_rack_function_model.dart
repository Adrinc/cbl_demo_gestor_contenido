class ComponenteEnRack {
  final String componenteId;
  final String nombre;
  final int categoriaId;
  final String? descripcion;
  final String? ubicacion;
  final String? imagenUrl;
  final bool enUso;
  final bool activo;

  ComponenteEnRack({
    required this.componenteId,
    required this.nombre,
    required this.categoriaId,
    this.descripcion,
    this.ubicacion,
    this.imagenUrl,
    required this.enUso,
    required this.activo,
  });

  factory ComponenteEnRack.fromMap(Map<String, dynamic> map) {
    return ComponenteEnRack(
      componenteId: map['componente_id'] ?? '',
      nombre: map['nombre'] ?? '',
      categoriaId: map['categoria_id'] ?? 0,
      descripcion: map['descripcion'],
      ubicacion: map['ubicacion'],
      imagenUrl: map['imagen_url'],
      enUso: map['en_uso'] ?? false,
      activo: map['activo'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'componente_id': componenteId,
        'nombre': nombre,
        'categoria_id': categoriaId,
        'descripcion': descripcion,
        'ubicacion': ubicacion,
        'imagen_url': imagenUrl,
        'en_uso': enUso,
        'activo': activo,
      };
}
