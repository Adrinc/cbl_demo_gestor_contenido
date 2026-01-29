import 'dart:convert';

class DetalleSwitch {
  final String componenteId;
  final String? marca;
  final String? modelo;
  final String? numeroSerie;
  final bool? administrable;
  final bool? poe;
  final int? cantidadPuertos;
  final String? velocidadPuertos;
  final String? tipoPuertos;
  final String? ubicacionEnRack;
  final String? direccionIp;
  final String? firmware;

  DetalleSwitch({
    required this.componenteId,
    this.marca,
    this.modelo,
    this.numeroSerie,
    this.administrable,
    this.poe,
    this.cantidadPuertos,
    this.velocidadPuertos,
    this.tipoPuertos,
    this.ubicacionEnRack,
    this.direccionIp,
    this.firmware,
  });

  factory DetalleSwitch.fromMap(Map<String, dynamic> map) {
    return DetalleSwitch(
      componenteId: map['componente_id'],
      marca: map['marca'],
      modelo: map['modelo'],
      numeroSerie: map['numero_serie'],
      administrable: map['administrable'],
      poe: map['poe'],
      cantidadPuertos: map['cantidad_puertos'],
      velocidadPuertos: map['velocidad_puertos'],
      tipoPuertos: map['tipo_puertos'],
      ubicacionEnRack: map['ubicacion_en_rack'],
      direccionIp: map['direccion_ip'],
      firmware: map['firmware'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'administrable': administrable,
      'poe': poe,
      'cantidad_puertos': cantidadPuertos,
      'velocidad_puertos': velocidadPuertos,
      'tipo_puertos': tipoPuertos,
      'ubicacion_en_rack': ubicacionEnRack,
      'direccion_ip': direccionIp,
      'firmware': firmware,
    };
  }

  factory DetalleSwitch.fromJson(String source) =>
      DetalleSwitch.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
