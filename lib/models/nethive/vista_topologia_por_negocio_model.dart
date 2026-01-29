import 'dart:convert';

class VistaTopologiaPorNegocio {
  final String negocioId;
  final String nombreNegocio;
  final String? distribucionId;
  final String? tipoDistribucion;
  final String? distribucionNombre;
  final String componenteId;
  final String componenteNombre;
  final String? descripcion;
  final String categoriaComponente;
  final int? rolLogicoId;
  final String? rolLogico;
  final bool enUso;
  final bool activo;
  final String? ubicacion;
  final String? imagenUrl;
  final DateTime fechaRegistro;

  VistaTopologiaPorNegocio({
    required this.negocioId,
    required this.nombreNegocio,
    this.distribucionId,
    this.tipoDistribucion,
    this.distribucionNombre,
    required this.componenteId,
    required this.componenteNombre,
    this.descripcion,
    required this.categoriaComponente,
    this.rolLogicoId,
    this.rolLogico,
    required this.enUso,
    required this.activo,
    this.ubicacion,
    this.imagenUrl,
    required this.fechaRegistro,
  });

  factory VistaTopologiaPorNegocio.fromMap(Map<String, dynamic> map) {
    return VistaTopologiaPorNegocio(
      negocioId: map['negocio_id'] ?? '',
      nombreNegocio: map['negocio_nombre'] ?? '',
      distribucionId: map['distribucion_id'],
      tipoDistribucion: map['tipo_distribucion'],
      distribucionNombre: map['distribucion_nombre'],
      componenteId: map['componente_id'] ?? '',
      componenteNombre: map['componente_nombre'] ?? '',
      descripcion: map['descripcion'],
      categoriaComponente: map['categoria_componente'] ?? '',
      rolLogicoId: map['rol_logico_id'],
      rolLogico: map['rol_logico'],
      enUso: map['en_uso'] == true,
      activo: map['activo'] == true,
      ubicacion: map['ubicacion'],
      imagenUrl: map['imagen_url'],
      fechaRegistro:
          DateTime.tryParse(map['fecha_registro'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'negocio_id': negocioId,
      'negocio_nombre': nombreNegocio,
      'distribucion_id': distribucionId,
      'tipo_distribucion': tipoDistribucion,
      'distribucion_nombre': distribucionNombre,
      'componente_id': componenteId,
      'componente_nombre': componenteNombre,
      'descripcion': descripcion,
      'categoria_componente': categoriaComponente,
      'rol_logico_id': rolLogicoId,
      'rol_logico': rolLogico,
      'en_uso': enUso,
      'activo': activo,
      'ubicacion': ubicacion,
      'imagen_url': imagenUrl,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  factory VistaTopologiaPorNegocio.fromJson(String source) =>
      VistaTopologiaPorNegocio.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  bool get esMDF => tipoDistribucion?.toUpperCase() == 'MDF';
  bool get esIDF => tipoDistribucion?.toUpperCase() == 'IDF';

  String get tipoComponentePrincipal {
    final categoria = categoriaComponente.toLowerCase();
    final nombre = componenteNombre.toLowerCase();
    final desc = descripcion?.toLowerCase() ?? '';

    if (nombre.contains('switch') || desc.contains('switch')) return 'switch';
    if (nombre.contains('router') ||
        desc.contains('router') ||
        nombre.contains('firewall') ||
        desc.contains('firewall') ||
        nombre.contains('fortigate') ||
        (nombre.contains('cisco') &&
            (nombre.contains('asa') || nombre.contains('pix')))) {
      return 'router';
    }
    if (nombre.contains('servidor') ||
        nombre.contains('server') ||
        desc.contains('servidor') ||
        desc.contains('server')) {
      return 'servidor';
    }
    if (categoria == 'cable') return 'cable';
    if (categoria == 'patch panel') return 'patch_panel';
    if (categoria == 'rack') return 'rack';
    if (categoria == 'ups') return 'ups';
    if (categoria.contains('organizador')) return 'organizador';

    if (categoria.contains('switch')) return 'switch';
    if (categoria.contains('router') || categoria.contains('firewall'))
      return 'router';
    if (categoria.contains('servidor') || categoria.contains('server'))
      return 'servidor';
    if (categoria.contains('cable')) return 'cable';
    if (categoria.contains('patch') || categoria.contains('panel'))
      return 'patch_panel';
    if (categoria.contains('rack')) return 'rack';
    if (categoria.contains('ups')) return 'ups';

    return 'otro';
  }

  int get prioridadTopologia {
    if (esMDF) return 1;
    if (esIDF) return 2;
    switch (tipoComponentePrincipal) {
      case 'router':
        return 3;
      case 'switch':
        return 4;
      case 'servidor':
        return 5;
      case 'patch_panel':
        return 6;
      case 'rack':
        return 7;
      case 'ups':
        return 8;
      case 'cable':
        return 9;
      case 'organizador':
        return 10;
      default:
        return 11;
    }
  }

  String getColorForDiagram() {
    if (esMDF) return '#2196F3';
    if (esIDF) return enUso ? '#4CAF50' : '#FF9800';
    switch (tipoComponentePrincipal) {
      case 'router':
        return '#FF5722';
      case 'switch':
        return '#9C27B0';
      case 'servidor':
        return '#E91E63';
      case 'patch_panel':
        return '#607D8B';
      case 'rack':
        return '#795548';
      case 'ups':
        return '#FFC107';
      case 'cable':
        return '#4CAF50';
      case 'organizador':
        return '#9E9E9E';
      default:
        return activo ? '#2196F3' : '#757575';
    }
  }
}
