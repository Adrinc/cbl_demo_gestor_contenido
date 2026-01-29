import 'dart:convert';

class DetalleUps {
  final String componenteId;
  final String? tipo;
  final String? marca;
  final String? modelo;
  final String? voltajeEntrada;
  final String? voltajeSalida;
  final int? capacidadVa;
  final int? autonomiaMinutos;
  final int? cantidadTomas;
  final bool? rackeable;

  DetalleUps({
    required this.componenteId,
    this.tipo,
    this.marca,
    this.modelo,
    this.voltajeEntrada,
    this.voltajeSalida,
    this.capacidadVa,
    this.autonomiaMinutos,
    this.cantidadTomas,
    this.rackeable,
  });

  factory DetalleUps.fromMap(Map<String, dynamic> map) {
    return DetalleUps(
      componenteId: map['componente_id'],
      tipo: map['tipo'],
      marca: map['marca'],
      modelo: map['modelo'],
      voltajeEntrada: map['voltaje_entrada'],
      voltajeSalida: map['voltaje_salida'],
      capacidadVa: map['capacidad_va'],
      autonomiaMinutos: map['autonomia_minutos'],
      cantidadTomas: map['cantidad_tomas'],
      rackeable: map['rackeable'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'voltaje_entrada': voltajeEntrada,
      'voltaje_salida': voltajeSalida,
      'capacidad_va': capacidadVa,
      'autonomia_minutos': autonomiaMinutos,
      'cantidad_tomas': cantidadTomas,
      'rackeable': rackeable,
    };
  }

  factory DetalleUps.fromJson(String source) =>
      DetalleUps.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
