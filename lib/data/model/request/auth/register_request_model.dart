import 'dart:convert';

class RegisterRequestModel {
    final String? username;
    final String? email;
    final String? password;

    RegisterRequestModel({
        this.username,
        this.email,
        this.password,
    });

    factory RegisterRequestModel.fromJson(String str) => RegisterRequestModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory RegisterRequestModel.fromMap(Map<String, dynamic> json) => RegisterRequestModel(
        username: json["username"],
        email: json["email"],
        password: json["password"],
    );

    Map<String, dynamic> toMap() => {
        "username": username,
        "email": email,
        "password": password,
    };
}
