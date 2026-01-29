import 'dart:convert';

class DetalleOrganizador {
  final String componenteId;
  final String? tipo;
  final String? material;
  final String? tamano;
  final String? color;

  DetalleOrganizador({
    required this.componenteId,
    this.tipo,
    this.material,
    this.tamano,
    this.color,
  });

  factory DetalleOrganizador.fromMap(Map<String, dynamic> map) {
    return DetalleOrganizador(
      componenteId: map['componente_id'],
      tipo: map['tipo'],
      material: map['material'],
      tamano: map['tamaño'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'tipo': tipo,
      'material': material,
      'tamaño': tamano,
      'color': color,
    };
  }

  factory DetalleOrganizador.fromJson(String source) =>
      DetalleOrganizador.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
