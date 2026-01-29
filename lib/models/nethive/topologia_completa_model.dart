class TopologiaCompleta {
  final List<ComponenteTopologia> componentes;
  final List<ConexionDatos> conexionesDatos;
  final List<ConexionEnergia> conexionesEnergia;

  TopologiaCompleta({
    required this.componentes,
    required this.conexionesDatos,
    required this.conexionesEnergia,
  });

  factory TopologiaCompleta.fromJson(Map<String, dynamic> json) {
    return TopologiaCompleta(
      componentes: (json['componentes'] as List<dynamic>? ?? [])
          .map((c) => ComponenteTopologia.fromMap(c))
          .toList(),
      conexionesDatos: (json['conexiones_datos'] as List<dynamic>? ?? [])
          .map((cd) => ConexionDatos.fromMap(cd))
          .toList(),
      conexionesEnergia: (json['conexiones_energia'] as List<dynamic>? ?? [])
          .map((ce) => ConexionEnergia.fromMap(ce))
          .toList(),
    );
  }
}

class ComponenteTopologia {
  final String id;
  final String nombre;
  final int categoriaId;
  final String categoria;
  final String? descripcion;
  final String? ubicacion;
  final String? imagenUrl;
  final bool enUso;
  final bool activo;
  final DateTime fechaRegistro;
  final String? distribucionId;
  final String? tipoDistribucion;
  final String? nombreDistribucion;

  ComponenteTopologia({
    required this.id,
    required this.nombre,
    required this.categoriaId,
    required this.categoria,
    this.descripcion,
    this.ubicacion,
    this.imagenUrl,
    required this.enUso,
    required this.activo,
    required this.fechaRegistro,
    this.distribucionId,
    this.tipoDistribucion,
    this.nombreDistribucion,
  });

  factory ComponenteTopologia.fromMap(Map<String, dynamic> map) {
    return ComponenteTopologia(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      categoriaId: map['categoria_id'] ?? 0,
      categoria: map['categoria'] ?? '',
      descripcion: map['descripcion'],
      ubicacion: map['ubicacion'],
      imagenUrl: map['imagen_url'],
      enUso: map['en_uso'] ?? false,
      activo: map['activo'] ?? false,
      fechaRegistro:
          DateTime.tryParse(map['fecha_registro']?.toString() ?? '') ??
              DateTime.now(),
      distribucionId: map['distribucion_id'],
      tipoDistribucion: map['tipo_distribucion'],
      nombreDistribucion: map['nombre_distribucion'],
    );
  }

  // Métodos de utilidad para topología
  bool get esMDF =>
      tipoDistribucion?.toLowerCase() == 'mdf' ||
      ubicacion?.toLowerCase().contains('mdf') == true ||
      categoria.toLowerCase().contains('mdf');

  bool get esIDF =>
      tipoDistribucion?.toLowerCase() == 'idf' ||
      ubicacion?.toLowerCase().contains('idf') == true ||
      categoria.toLowerCase().contains('idf');

  bool get esSwitch => categoria.toLowerCase().contains('switch');

  bool get esRouter =>
      categoria.toLowerCase().contains('router') ||
      categoria.toLowerCase().contains('firewall');

  bool get esServidor =>
      categoria.toLowerCase().contains('servidor') ||
      categoria.toLowerCase().contains('server');

  bool get esUPS => categoria.toLowerCase().contains('ups');

  bool get esRack => categoria.toLowerCase().contains('rack');

  bool get esPatchPanel =>
      categoria.toLowerCase().contains('patch') ||
      categoria.toLowerCase().contains('panel');

  // Prioridad para ordenamiento en topología
  int get prioridadTopologia {
    if (esMDF) return 1;
    if (esIDF) return 2;
    if (esSwitch) return 3;
    if (esRouter) return 4;
    if (esServidor) return 5;
    if (esUPS) return 6;
    if (esRack) return 7;
    if (esPatchPanel) return 8;
    return 9;
  }
}

class ConexionDatos {
  final String id;
  final String componenteOrigenId;
  final String nombreOrigen;
  final String componenteDestinoId;
  final String nombreDestino;
  final String? cableId;
  final String? nombreCable;
  final String? descripcion;
  final bool activo;

  ConexionDatos({
    required this.id,
    required this.componenteOrigenId,
    required this.nombreOrigen,
    required this.componenteDestinoId,
    required this.nombreDestino,
    this.cableId,
    this.nombreCable,
    this.descripcion,
    required this.activo,
  });

  factory ConexionDatos.fromMap(Map<String, dynamic> map) {
    return ConexionDatos(
      id: map['id'] ?? '',
      componenteOrigenId: map['componente_origen_id'] ?? '',
      nombreOrigen: map['nombre_origen'] ?? '',
      componenteDestinoId: map['componente_destino_id'] ?? '',
      nombreDestino: map['nombre_destino'] ?? '',
      cableId: map['cable_id'],
      nombreCable: map['nombre_cable'],
      descripcion: map['descripcion'],
      activo: map['activo'] ?? false,
    );
  }
}

class ConexionEnergia {
  final String id;
  final String origenId;
  final String nombreOrigen;
  final String destinoId;
  final String nombreDestino;
  final String? cableId;
  final String? nombreCable;
  final String? descripcion;
  final bool activo;

  ConexionEnergia({
    required this.id,
    required this.origenId,
    required this.nombreOrigen,
    required this.destinoId,
    required this.nombreDestino,
    this.cableId,
    this.nombreCable,
    this.descripcion,
    required this.activo,
  });

  factory ConexionEnergia.fromMap(Map<String, dynamic> map) {
    return ConexionEnergia(
      id: map['id'] ?? '',
      origenId: map['origen_id'] ?? '',
      nombreOrigen: map['nombre_origen'] ?? '',
      destinoId: map['destino_id'] ?? '',
      nombreDestino: map['nombre_destino'] ?? '',
      cableId: map['cable_id'],
      nombreCable: map['nombre_cable'],
      descripcion: map['descripcion'],
      activo: map['activo'] ?? false,
    );
  }
}
