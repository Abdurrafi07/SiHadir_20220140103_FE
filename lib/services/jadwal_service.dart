import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sihadir/data/model/kelola/jadwal_model.dart';
import 'package:sihadir/services/service_http_client.dart';

class JadwalService {
  final String baseUrl = 'admin/jadwal'; // endpoint utama
  final ServiceHttpClient _httpClient = ServiceHttpClient();

  Future<List<JadwalModel>> getAllJadwal() async {
    final response = await _httpClient.get(baseUrl);
    debugPrint("[SERVICE] Status GET jadwal: ${response.statusCode}");
    debugPrint("[SERVICE] Body GET jadwal: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<JadwalModel>.from(
        data['data'].map((item) => JadwalModel.fromJson(item)),
      );
    } else {
      throw Exception('Gagal ambil jadwal: ${response.statusCode}');
    }
  }

  Future<void> createJadwal({
    required int kelasId,
    required int mapelId,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
  }) async {
    final response = await _httpClient.postWithToken(baseUrl, {
      "kelas_id": kelasId,
      "mapel_id": mapelId,
      "hari": hari,
      "jam_mulai": jamMulai,
      "jam_selesai": jamSelesai,
    });

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['status_code'] == 201) {
      debugPrint("[SERVICE] CREATE JADWAL SUCCESS: ${response.body}");
      return;
    } else {
      debugPrint("[SERVICE] CREATE JADWAL ERROR: ${response.body}");
      throw Exception("Gagal tambah jadwal");
    }
  }

  Future<void> updateJadwal({
    required int id,
    required int kelasId,
    required int mapelId,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
  }) async {
    final response = await _httpClient.putWithToken('$baseUrl/$id', {
      "kelas_id": kelasId,
      "mapel_id": mapelId,
      "hari": hari,
      "jam_mulai": jamMulai,
      "jam_selesai": jamSelesai,
    });

    debugPrint("[SERVICE] UPDATE JADWAL: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Gagal update jadwal");
    }
  }

  Future<void> deleteJadwal(int id) async {
    final response = await _httpClient.deleteWithToken('$baseUrl/$id');

    debugPrint("[SERVICE] DELETE JADWAL: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Gagal hapus jadwal");
    }
  }
}
