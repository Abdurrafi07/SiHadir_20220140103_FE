import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sihadir/data/model/kelola/mapel_model.dart';
import 'package:sihadir/services/service_http_client.dart';

class MapelService {
  final String baseUrl = 'admin/mapel'; // hanya endpoint
  final ServiceHttpClient _httpClient = ServiceHttpClient();

  Future<List<MapelModel>> getAllMapel() async {
    final response = await _httpClient.get(baseUrl);
    debugPrint("[SERVICE] Status GET mapel: ${response.statusCode}");
    debugPrint("[SERVICE] Body GET mapel: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<MapelModel>.from(
        data['data'].map((item) => MapelModel.fromJson(item)),
      );
    } else {
      throw Exception('Gagal ambil mapel: ${response.statusCode}');
    }
  }

  Future<void> createMapel(String namaMapel, List<int> kelasIds) async {
    final response = await _httpClient.postWithToken(baseUrl, {
      "nama_mapel": namaMapel,
      "kelas_ids": kelasIds,
    });

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['status_code'] == 201) {
      debugPrint("[SERVICE] CREATE MAPEL SUCCESS: ${response.body}");
      return;
    } else {
      debugPrint("[SERVICE] CREATE MAPEL ERROR: ${response.body}");
      throw Exception("Gagal tambah mapel");
    }
  }

  Future<void> updateMapel(int id, String namaMapel, List<int> kelasIds) async {
    final response = await _httpClient.putWithToken('$baseUrl/$id', {
      "nama_mapel": namaMapel,
      "kelas_ids": kelasIds,
    });

    debugPrint("[SERVICE] UPDATE MAPEL: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Gagal update mapel");
    }
  }

  Future<void> deleteMapel(int id) async {
    final response = await _httpClient.deleteWithToken('$baseUrl/$id');

    if (response.statusCode != 200) {
      throw Exception("Gagal hapus mapel");
    }
  }
}
