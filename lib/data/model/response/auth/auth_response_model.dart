import 'dart:convert';

class AuthResponseModel {
  final int? statusCode;
  final String? message;
  final RegisterUserData? data;

  AuthResponseModel({
    this.statusCode,
    this.message,
    this.data,
  });

  factory AuthResponseModel.fromJson(String str) =>
      AuthResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AuthResponseModel.fromMap(Map<String, dynamic> json) =>
      AuthResponseModel(
        statusCode: json["status_code"],
        message: json["message"],
        data: json["data"] == null ? null : RegisterUserData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "status_code": statusCode,
        "message": message,
        "data": data?.toMap(),
      };
}

class RegisterUserData {
  final int? id;
  final String? name;
  final String? email;
  final int? roleId;
  final dynamic idKelas;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  RegisterUserData({
    this.id,
    this.name,
    this.email,
    this.roleId,
    this.idKelas,
    this.updatedAt,
    this.createdAt,
  });

  factory RegisterUserData.fromJson(String str) =>
      RegisterUserData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RegisterUserData.fromMap(Map<String, dynamic> json) => RegisterUserData(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        roleId: json["role_id"],
        idKelas: json["id_kelas"],
        updatedAt: json["updated_at"] == null ? null : DateTime.tryParse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "role_id": roleId,
        "id_kelas": idKelas,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
      };
}
