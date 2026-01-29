import 'dart:convert';

class DetalleRouterFirewall {
  final String componenteId;
  final String? tipo;
  final String? marca;
  final String? modelo;
  final String? numeroSerie;
  final String? interfaces;
  final double? capacidadRoutingGbps;
  final String? direccionIp;
  final String? firmware;
  final String? licencias;

  DetalleRouterFirewall({
    required this.componenteId,
    this.tipo,
    this.marca,
    this.modelo,
    this.numeroSerie,
    this.interfaces,
    this.capacidadRoutingGbps,
    this.direccionIp,
    this.firmware,
    this.licencias,
  });

  factory DetalleRouterFirewall.fromMap(Map<String, dynamic> map) {
    return DetalleRouterFirewall(
      componenteId: map['componente_id'],
      tipo: map['tipo'],
      marca: map['marca'],
      modelo: map['modelo'],
      numeroSerie: map['numero_serie'],
      interfaces: map['interfaces'],
      capacidadRoutingGbps: map['capacidad_routing_gbps']?.toDouble(),
      direccionIp: map['direccion_ip'],
      firmware: map['firmware'],
      licencias: map['licencias'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'interfaces': interfaces,
      'capacidad_routing_gbps': capacidadRoutingGbps,
      'direccion_ip': direccionIp,
      'firmware': firmware,
      'licencias': licencias,
    };
  }

  factory DetalleRouterFirewall.fromJson(String source) =>
      DetalleRouterFirewall.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
