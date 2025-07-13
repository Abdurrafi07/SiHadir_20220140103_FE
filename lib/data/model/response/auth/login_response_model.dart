import 'dart:convert';

class LoginResponseModel {
  final String? message;
  final int? statusCode;
  final LoginUserData? data;

  LoginResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory LoginResponseModel.fromJson(String str) =>
      LoginResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoginResponseModel.fromMap(Map<String, dynamic> json) =>
      LoginResponseModel(
        message: json["message"],
        statusCode: json["status_code"],
        data: json["data"] == null ? null : LoginUserData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "status_code": statusCode,
        "data": data?.toMap(),
      };
}

class LoginUserData {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final String? kelas;
  final String? token;

  LoginUserData({
    this.id,
    this.name,
    this.email,
    this.role,
    this.kelas,
    this.token,
  });

  factory LoginUserData.fromJson(String str) =>
      LoginUserData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoginUserData.fromMap(Map<String, dynamic> json) => LoginUserData(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
        kelas: json["kelas"]?.toString(),
        token: json["token"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
        "kelas": kelas,
        "token": token,
      };
}
