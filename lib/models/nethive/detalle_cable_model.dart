import 'dart:convert';

class DetalleCable {
  final String componenteId;
  final String? tipoCable;
  final String? color;
  final double? tamano;
  final String? tipoConector;

  DetalleCable({
    required this.componenteId,
    this.tipoCable,
    this.color,
    this.tamano,
    this.tipoConector,
  });

  factory DetalleCable.fromMap(Map<String, dynamic> map) {
    return DetalleCable(
      componenteId: map['componente_id'],
      tipoCable: map['tipo_cable'],
      color: map['color'],
      tamano: map['tamaño']?.toDouble(),
      tipoConector: map['tipo_conector'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'tipo_cable': tipoCable,
      'color': color,
      'tamaño': tamano,
      'tipo_conector': tipoConector,
    };
  }

  factory DetalleCable.fromJson(String source) =>
      DetalleCable.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
