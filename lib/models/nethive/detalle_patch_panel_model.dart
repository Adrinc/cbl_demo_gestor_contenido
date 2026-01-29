import 'dart:convert';

class DetallePatchPanel {
  final String componenteId;
  final String? tipoConector;
  final int? numeroPuertos;
  final String? categoria;
  final String? tipoMontaje;
  final bool? numeracionFrontal;
  final bool? panelCiego;

  DetallePatchPanel({
    required this.componenteId,
    this.tipoConector,
    this.numeroPuertos,
    this.categoria,
    this.tipoMontaje,
    this.numeracionFrontal,
    this.panelCiego,
  });

  factory DetallePatchPanel.fromMap(Map<String, dynamic> map) {
    return DetallePatchPanel(
      componenteId: map['componente_id'],
      tipoConector: map['tipo_conector'],
      numeroPuertos: map['numero_puertos'],
      categoria: map['categoria'],
      tipoMontaje: map['tipo_montaje'],
      numeracionFrontal: map['numeracion_frontal'],
      panelCiego: map['panel_ciego'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'tipo_conector': tipoConector,
      'numero_puertos': numeroPuertos,
      'categoria': categoria,
      'tipo_montaje': tipoMontaje,
      'numeracion_frontal': numeracionFrontal,
      'panel_ciego': panelCiego,
    };
  }

  factory DetallePatchPanel.fromJson(String source) =>
      DetallePatchPanel.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
