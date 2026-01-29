import 'dart:convert';

class DetalleRack {
  final String componenteId;
  final String? tipo;
  final int? alturaU;
  final int? profundidadCm;
  final int? anchoCm;
  final bool? ventilacionIntegrada;
  final bool? puertasConLlave;
  final bool? ruedas;
  final String? color;

  DetalleRack({
    required this.componenteId,
    this.tipo,
    this.alturaU,
    this.profundidadCm,
    this.anchoCm,
    this.ventilacionIntegrada,
    this.puertasConLlave,
    this.ruedas,
    this.color,
  });

  factory DetalleRack.fromMap(Map<String, dynamic> map) {
    return DetalleRack(
      componenteId: map['componente_id'],
      tipo: map['tipo'],
      alturaU: map['altura_u'],
      profundidadCm: map['profundidad_cm'],
      anchoCm: map['ancho_cm'],
      ventilacionIntegrada: map['ventilacion_integrada'],
      puertasConLlave: map['puertas_con_llave'],
      ruedas: map['ruedas'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'tipo': tipo,
      'altura_u': alturaU,
      'profundidad_cm': profundidadCm,
      'ancho_cm': anchoCm,
      'ventilacion_integrada': ventilacionIntegrada,
      'puertas_con_llave': puertasConLlave,
      'ruedas': ruedas,
      'color': color,
    };
  }

  factory DetalleRack.fromJson(String source) =>
      DetalleRack.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
