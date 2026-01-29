import 'dart:convert';

import 'package:flutter/material.dart';

class RackConComponentes {
  final String rackId;
  final String nombreRack;
  final String? ubicacionRack;
  final List<ComponenteEnRackDetalle> componentes;

  RackConComponentes({
    required this.rackId,
    required this.nombreRack,
    this.ubicacionRack,
    required this.componentes,
  });

  factory RackConComponentes.fromMap(Map<String, dynamic> map) {
    return RackConComponentes(
      rackId: map['rack_id'] ?? '',
      nombreRack: map['nombre_rack'] ?? '',
      ubicacionRack: map['ubicacion_rack'],
      componentes: (map['componentes'] as List<dynamic>? ?? [])
          .map((comp) => ComponenteEnRackDetalle.fromMap(comp))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rack_id': rackId,
      'nombre_rack': nombreRack,
      'ubicacion_rack': ubicacionRack,
      'componentes': componentes.map((comp) => comp.toMap()).toList(),
    };
  }

  factory RackConComponentes.fromJson(String source) =>
      RackConComponentes.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  // Métodos de utilidad
  int get cantidadComponentes => componentes.length;

  int get componentesActivos => componentes.where((c) => c.activo).length;

  int get componentesEnUso => componentes.where((c) => c.enUso).length;

  double get porcentajeOcupacion {
    // Asumiendo racks estándar de 42U
    const int alturaMaximaU = 42;
    final posicionesOcupadas = componentes
        .where((c) => c.posicionU != null)
        .map((c) => c.posicionU!)
        .toSet()
        .length;

    return posicionesOcupadas / alturaMaximaU * 100;
  }

  List<ComponenteEnRackDetalle> get componentesOrdenadosPorPosicion {
    final componentesConPosicion = componentes
        .where((c) => c.posicionU != null)
        .toList()
      ..sort((a, b) => (a.posicionU ?? 0).compareTo(b.posicionU ?? 0));

    final componentesSinPosicion =
        componentes.where((c) => c.posicionU == null).toList();

    return [...componentesConPosicion, ...componentesSinPosicion];
  }
}

class ComponenteEnRackDetalle {
  final String componenteId;
  final String nombre;
  final int categoriaId;
  final String? descripcion;
  final String? ubicacion;
  final String? imagenUrl;
  final bool enUso;
  final bool activo;
  final int? posicionU;

  ComponenteEnRackDetalle({
    required this.componenteId,
    required this.nombre,
    required this.categoriaId,
    this.descripcion,
    this.ubicacion,
    this.imagenUrl,
    required this.enUso,
    required this.activo,
    this.posicionU,
  });

  factory ComponenteEnRackDetalle.fromMap(Map<String, dynamic> map) {
    return ComponenteEnRackDetalle(
      componenteId: map['componente_id'] ?? '',
      nombre: map['nombre'] ?? '',
      categoriaId: map['categoria_id'] ?? 0,
      descripcion: map['descripcion'],
      ubicacion: map['ubicacion'],
      imagenUrl: map['imagen_url'],
      enUso: map['en_uso'] ?? false,
      activo: map['activo'] ?? false,
      posicionU: map['posicion_u'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'nombre': nombre,
      'categoria_id': categoriaId,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'imagen_url': imagenUrl,
      'en_uso': enUso,
      'activo': activo,
      'posicion_u': posicionU,
    };
  }

  String get estadoTexto {
    if (!activo) return 'Inactivo';
    if (enUso) return 'En Uso';
    return 'Disponible';
  }

  Color get colorEstado {
    if (!activo) return Colors.grey;
    if (enUso) return Colors.green;
    return Colors.orange;
  }

  IconData get iconoCategoria {
    // Mapeo básico de categorías a iconos
    switch (categoriaId) {
      case 1: // Switch
        return Icons.router;
      case 2: // Server
        return Icons.dns;
      case 3: // Patch Panel
        return Icons.view_module;
      case 5: // UPS
        return Icons.battery_charging_full;
      case 6: // Router/Firewall
        return Icons.security;
      default:
        return Icons.memory;
    }
  }
}
