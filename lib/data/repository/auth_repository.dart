import 'dart:convert';

import 'package:sihadir/data/model/request/auth/login_request_model.dart';
import 'package:sihadir/data/model/request/auth/register_request_model.dart';
import 'package:sihadir/data/model/response/auth/login_response_model.dart';
import 'package:sihadir/services/service_http_client.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final ServiceHttpClient _serviceHttpClient;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  AuthRepository(this._serviceHttpClient);

  Future<Either<String, LoginResponseModel>> login(
  LoginRequestModel requestModel,
) async {
  try {
    final response = await _serviceHttpClient.post(
      'login',
      requestModel.toMap(),
    );

    final jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      final loginResponse = LoginResponseModel.fromMap(jsonResponse);

      await secureStorage.write(
        key: 'authToken',
        value: loginResponse.data?.token ?? '',
      );
      await secureStorage.write(
        key: 'userRole',
        value: loginResponse.data?.role ?? '',
      );
      await secureStorage.write(
        key: 'userName',
        value: loginResponse.data?.name ?? '',
      );

      return right(loginResponse);
    } else {
      return left(jsonResponse['message'] ?? 'Login failed');
    }
  } catch (e) {
    return left('An error occurred while logging in: $e');
  }
}


  Future<Either<String, String>> register(
    RegisterRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttpClient.post(
        'register',
        requestModel.toMap(),
      );

      final jsonResponse = json.decode(response.body);
      final message = jsonResponse['message'];

      if (response.statusCode == 201) {
        return right(message ?? 'Registration successful');
      } else {
        return left(message ?? 'Registration failed');
      }
    } catch (e) {
      return left('An error occurred while registering: $e');
    }
  }
}
