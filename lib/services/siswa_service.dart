import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sihadir/data/model/kelola/siswa_model.dart';
import 'package:sihadir/services/service_http_client.dart';

class SiswaService {
  final String basePath = 'admin/siswa'; // Endpoint root
  final ServiceHttpClient _httpClient = ServiceHttpClient();

  // ✅ Ambil semua siswa
  Future<List<SiswaModel>> getAllSiswa() async {
    final response = await _httpClient.get(basePath);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => SiswaModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data siswa');
    }
  }

Future<void> addSiswa(SiswaModel siswa) async {
  final body = {
    'nama': siswa.nama,
    'nisn': siswa.nisn,
    'jenis_kelamin': siswa.jenisKelamin,
    'tanggal_lahir': siswa.tanggalLahir ?? '',
    'alamat': siswa.alamat ?? '',
    'kelas_id': siswa.kelasId?.toString() ?? '',
  };

  final response = await _httpClient.postWithToken(basePath, body);
  final data = json.decode(response.body);

  // Tambahkan debugPrint jika perlu
  debugPrint('[SERVICE] ADD SISWA RESPONSE: ${response.statusCode} => $data');

  if (response.statusCode != 200 || data['status_code'] != 201) {
    throw Exception('Gagal menambahkan siswa: ${data['message'] ?? 'Unknown error'}');
  }
}


  // ✏️ Update siswa
  Future<void> updateSiswa(SiswaModel siswa) async {
    final body = {
      'nama': siswa.nama,
      'nisn': siswa.nisn,
      'jenis_kelamin': siswa.jenisKelamin,
      'tanggal_lahir': siswa.tanggalLahir ?? '',
      'alamat': siswa.alamat ?? '',
      'kelas_id': siswa.kelasId?.toString() ?? '',
    };

    // ⛔ Hapus `body:` karena bukan named parameter
    final response = await _httpClient.putWithToken('$basePath/${siswa.id}', body);
    if (response.statusCode != 200) {
      throw Exception('Gagal mengubah data siswa');
    }
  }

  // 🗑️ Hapus siswa
  Future<void> deleteSiswa(int id) async {
    final response = await _httpClient.deleteWithToken('$basePath/$id');
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data siswa');
    }
  }
}
