import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ServiceHttpClient {
  final String baseUrl = 'http://10.0.2.2:8000/api/';
  final secureStorage = FlutterSecureStorage();

  //post
  Future<http.Response> post(String endPoint, Map<String, dynamic> body) async{
    final url = Uri.parse("$baseUrl$endPoint");
    final token = await secureStorage.read(key: 'authToken');
    
    try{
      final respone = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );
      return respone;
    }catch (e) {
      throw Exception("Post request failed: $e");
    }
  }

  //postWithToken
  Future<http.Response> postWithToken(String endPoint, Map<String, dynamic> body) async{
    final token = await secureStorage.read(key: "authToken");
    final url = Uri.parse("$baseUrl$endPoint");
    try{
      final respone = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );
      return respone;
    }catch (e) {
      throw Exception("Post request failed: $e");
    }
  }

  //get
  Future<http.Response> get(String endPoint) async{
    final token = await secureStorage.read(key: "authToken");
    final url = Uri.parse("$baseUrl$endPoint");
    try{
      final respone = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
      );
      return respone;
    }catch (e) {
      throw Exception("Get request failed: $e");
    }
  }

  // putWithToken
Future<http.Response> putWithToken(String endPoint, Map<String, dynamic> body) async {
  final token = await secureStorage.read(key: 'authToken');
  final url = Uri.parse("$baseUrl$endPoint");
  try {
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body),
    );
    return response;
  } catch (e) {
    throw Exception("Put request failed: $e");
  }
}

// deleteWithToken
Future<http.Response> deleteWithToken(String endPoint) async {
  final token = await secureStorage.read(key: 'authToken');
  final url = Uri.parse("$baseUrl$endPoint");
  try {
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    return response;
  } catch (e) {
    throw Exception("Delete request failed: $e");
  }
}

}