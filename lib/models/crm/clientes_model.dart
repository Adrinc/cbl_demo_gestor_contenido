import 'dart:convert';

class ClientesModel {
    int? customerId;
    String? firstName;
    String? lastName;
    String? email;
    String? telefono;
    String? zipcode;
    DateTime? createdAt;
    String? direccion;
    String? ciudad;
    String? estado;
    String? proximaActualizacion;
    String? creadoPor;
    String? imagen;
    int? diasDisponibles;
    int? id;
    String? empresa;
    int? qr;
    String? service;
    String? status;

    ClientesModel({
        this.customerId,
        this.firstName,
        this.lastName,
        this.email,
        this.telefono,
        this.zipcode,
        this.createdAt,
        this.direccion,
        this.ciudad,
        this.estado,
        this.proximaActualizacion,
        this.creadoPor,
        this.imagen,
        this.diasDisponibles,
        this.id,
        this.empresa,
        this.qr,
        this.service,
        this.status,
    });

    factory ClientesModel.fromJson(String str) => ClientesModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ClientesModel.fromMap(Map<String, dynamic> json) => ClientesModel(
        customerId: json["customer_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        telefono: json["telefono"],
        zipcode: json["zipcode"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        direccion: json["direccion"],
        ciudad: json["ciudad"],
        estado: json["estado"],
        proximaActualizacion: json["proxima_actualizacion"],
        creadoPor: json["creado_por"],
        imagen: json["imagen"],
        diasDisponibles: json["dias_disponibles"],
        id: json["id"],
        empresa: json["empresa"],
        qr: json["qr"],
        service: json["service"],
        status: json["status"],
    );

    Map<String, dynamic> toMap() => {
        "customer_id": customerId,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "telefono": telefono,
        "zipcode": zipcode,
        "created_at": createdAt?.toIso8601String(),
        "direccion": direccion,
        "ciudad": ciudad,
        "estado": estado,
        "proxima_actualizacion": proximaActualizacion,
        "creado_por": creadoPor,
        "imagen": imagen,
        "dias_disponibles": diasDisponibles,
        "id": id,
        "empresa": empresa,
        "qr": qr,
        "service": service,
        "status": status,
    };
}
