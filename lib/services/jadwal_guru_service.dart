import 'dart:convert';
import 'package:sihadir/data/model/kelola/jadwal_model.dart';
import 'package:sihadir/data/model/kelola/siswa_model.dart';
import 'package:sihadir/services/service_http_client.dart';

class JadwalGuruService {
  final ServiceHttpClient _client;

  JadwalGuruService(this._client);

  Future<Map<String, dynamic>> fetchJadwalDanSiswa() async {
    final response = await _client.get('jadwal/guru');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<JadwalModel> jadwal = (data['jadwal'] as List)
          .map((e) => JadwalModel.fromJson(e))
          .toList();
      final List<SiswaModel> siswa = (data['siswa'] as List)
          .map((e) => SiswaModel.fromJson(e))
          .toList();
      return {
        'jadwal': jadwal,
        'siswa': siswa,
      };
    } else {
      throw Exception('Gagal mengambil data jadwal dan siswa. Status: ${response.statusCode}');
    }
  }
}
