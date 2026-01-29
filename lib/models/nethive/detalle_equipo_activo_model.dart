import 'dart:convert';

class DetalleEquipoActivo {
  final String componenteId;
  final String? tipo;
  final String? marca;
  final String? modelo;
  final String? numeroSerie;
  final String? especificaciones;
  final String? direccionIp;
  final String? firmware;

  DetalleEquipoActivo({
    required this.componenteId,
    this.tipo,
    this.marca,
    this.modelo,
    this.numeroSerie,
    this.especificaciones,
    this.direccionIp,
    this.firmware,
  });

  factory DetalleEquipoActivo.fromMap(Map<String, dynamic> map) {
    return DetalleEquipoActivo(
      componenteId: map['componente_id'],
      tipo: map['tipo'],
      marca: map['marca'],
      modelo: map['modelo'],
      numeroSerie: map['numero_serie'],
      especificaciones: map['especificaciones'],
      direccionIp: map['direccion_ip'],
      firmware: map['firmware'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'especificaciones': especificaciones,
      'direccion_ip': direccionIp,
      'firmware': firmware,
    };
  }

  factory DetalleEquipoActivo.fromJson(String source) =>
      DetalleEquipoActivo.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
