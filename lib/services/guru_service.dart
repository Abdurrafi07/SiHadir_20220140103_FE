import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sihadir/data/model/kelola/guru_model.dart';
import 'package:sihadir/services/service_http_client.dart';

class GuruService {
  final String baseUrl = 'admin/guru';
  final ServiceHttpClient _httpClient = ServiceHttpClient();

  // 🔍 Ambil semua guru
  Future<List<GuruModel>> getAllGuru() async {
    final response = await _httpClient.get(baseUrl);
    debugPrint("[SERVICE] GET GURU: ${response.body}");

    final data = json.decode(response.body);
    final statusCode = data['status_code'];
    final message = data['message'];
    final rawData = data['data'];

    // ✅ Tangani khusus jika status_code 404 dan data kosong
    if (response.statusCode == 200 && statusCode == 200) {
      if (rawData == null || rawData is! List) return [];
      return rawData.map((e) => GuruModel.fromJson(e)).toList();
    } else if (statusCode == 404 &&
        message.toString().toLowerCase().contains("tidak ada data")) {
      return []; // ✅ Perlakukan "tidak ada data" sebagai list kosong
    } else {
      throw Exception("Gagal ambil guru: $message");
    }
  }

  // 🆕 Tambah guru
  Future<void> createGuru({
    required String name,
    required String email,
    required String password,
    int? idKelas,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      if (idKelas != null) 'id_kelas': idKelas,
    };

    final response = await _httpClient.postWithToken(baseUrl, body);
    debugPrint("[SERVICE] CREATE GURU: ${response.body}");

    final data = json.decode(response.body);
    if (response.statusCode != 200 || data['status_code'] != 201) {
      throw Exception("Gagal tambah guru: ${data['message']}");
    }
  }

  // 🔍 Detail guru
  Future<GuruModel> getGuruById(int id) async {
    final response = await _httpClient.get('$baseUrl/$id');
    final data = json.decode(response.body);
    debugPrint("[SERVICE] SHOW GURU: ${response.body}");

    if (response.statusCode == 200 && data['status_code'] == 200) {
      return GuruModel.fromJson(data['data']);
    } else {
      throw Exception("Guru tidak ditemukan: ${data['message']}");
    }
  }

  // ✏️ Update guru
  Future<void> updateGuru({
    required int id,
    String? name,
    String? email,
    String? password,
    int? idKelas,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (idKelas != null) 'id_kelas': idKelas,
    };

    final response = await _httpClient.putWithToken('$baseUrl/$id', body);
    final data = json.decode(response.body);
    debugPrint("[SERVICE] UPDATE GURU: ${response.body}");

    if (response.statusCode != 200 || data['status_code'] != 200) {
      throw Exception("Gagal update guru: ${data['message']}");
    }
  }

  // 🗑️ Hapus guru
  Future<void> deleteGuru(int id) async {
    final response = await _httpClient.deleteWithToken('$baseUrl/$id');
    final data = json.decode(response.body);
    debugPrint("[SERVICE] DELETE GURU: ${response.body}");

    if (response.statusCode != 200 || data['status_code'] != 200) {
      throw Exception("Gagal hapus guru: ${data['message']}");
    }
  }
}
