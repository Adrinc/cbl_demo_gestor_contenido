import 'dart:convert';

class VistaConexionesPorCables {
  final String conexionId;
  final String? descripcion;
  final bool activo;
  final String origenId;
  final String componenteOrigen;
  final String destinoId;
  final String componenteDestino;
  final String? cableId;
  final String? cableUsado;
  final String? tipoCable;
  final String? color;
  final double? tamano;
  final String? tipoConector;

  VistaConexionesPorCables({
    required this.conexionId,
    this.descripcion,
    required this.activo,
    required this.origenId,
    required this.componenteOrigen,
    required this.destinoId,
    required this.componenteDestino,
    this.cableId,
    this.cableUsado,
    this.tipoCable,
    this.color,
    this.tamano,
    this.tipoConector,
  });

  factory VistaConexionesPorCables.fromMap(Map<String, dynamic> map) {
    return VistaConexionesPorCables(
      conexionId: map['conexion_id']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
      activo: map['activo'] == true,
      origenId: map['origen_id']?.toString() ?? '',
      componenteOrigen: map['componente_origen']?.toString() ?? '',
      destinoId: map['destino_id']?.toString() ?? '',
      componenteDestino: map['componente_destino']?.toString() ?? '',
      cableId: map['cable_id']?.toString(),
      cableUsado: map['cable_usado']?.toString(),
      tipoCable: map['tipo_cable']?.toString(),
      color: map['color']?.toString(),
      tamano: map['tamaño']?.toDouble(),
      tipoConector: map['tipo_conector']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conexion_id': conexionId,
      'descripcion': descripcion,
      'activo': activo,
      'origen_id': origenId,
      'componente_origen': componenteOrigen,
      'destino_id': destinoId,
      'componente_destino': componenteDestino,
      'cable_id': cableId,
      'cable_usado': cableUsado,
      'tipo_cable': tipoCable,
      'color': color,
      'tamaño': tamano,
      'tipo_conector': tipoConector,
    };
  }

  factory VistaConexionesPorCables.fromJson(String source) =>
      VistaConexionesPorCables.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  // Método para obtener el color del cable para visualización
  String getColorForVisualization() {
    if (color == null || color!.isEmpty) {
      // Color por defecto basado en tipo de cable
      switch (tipoCable?.toLowerCase()) {
        case 'fibra':
        case 'fibra optica':
          return '#00BCD4'; // Cyan
        case 'utp':
        case 'cat6':
        case 'cat5e':
          return '#FFEB3B'; // Yellow
        case 'coaxial':
          return '#FF9800'; // Orange
        default:
          return '#2196F3'; // Blue por defecto
      }
    }

    // Convertir nombre de color a código hex
    switch (color!.toLowerCase()) {
      case 'azul':
      case 'blue':
        return '#2196F3';
      case 'rojo':
      case 'red':
        return '#F44336';
      case 'verde':
      case 'green':
        return '#4CAF50';
      case 'amarillo':
      case 'yellow':
        return '#FFEB3B';
      case 'naranja':
      case 'orange':
        return '#FF9800';
      case 'morado':
      case 'purple':
        return '#9C27B0';
      case 'cyan':
        return '#00BCD4';
      case 'gris':
      case 'gray':
        return '#757575';
      default:
        return '#2196F3';
    }
  }

  // Método para determinar el grosor de línea basado en el tipo de cable
  double getThicknessForVisualization() {
    switch (tipoCable?.toLowerCase()) {
      case 'fibra':
      case 'fibra optica':
        return 5.0; // Más grueso para backbone
      case 'utp':
      case 'cat6':
        return 4.0;
      case 'cat5e':
        return 3.0;
      case 'coaxial':
        return 3.5;
      default:
        return 3.0;
    }
  }
}
