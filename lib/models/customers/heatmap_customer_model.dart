import 'dart:convert';

class HeatmapCustomers {
    int? year;
    int? month;
    Registro? registro;

    HeatmapCustomers({
        this.year,
        this.month,
        this.registro,
    });

    factory HeatmapCustomers.fromJson(String str) => HeatmapCustomers.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory HeatmapCustomers.fromMap(Map<String, dynamic> json) => HeatmapCustomers(
        year: json["year"],
        month: json["month"],
        registro: json["registro"] == null ? null : Registro.fromMap(json["registro"]),
    );

    Map<String, dynamic> toMap() => {
        "year": year,
        "month": month,
        "registro": registro?.toMap(),
    };
}

class Registro {
    double? leads;
    double? total;
    double? actives;

    Registro({
        this.leads,
        this.total,
        this.actives,
    });

    factory Registro.fromJson(String str) => Registro.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Registro.fromMap(Map<String, dynamic> json) => Registro(
        leads: json["Leads"],
        total: json["Total"],
        actives: json["Actives"],
    );

    Map<String, dynamic> toMap() => {
        "Leads": leads,
        "Total": total,
        "Actives": actives,
    };
}
