import 'dart:convert';
import 'package:sihadir/data/model/kelola/kelas_model.dart';
import 'package:sihadir/data/model/kelola/kelas_response_model.dart';
import 'package:sihadir/services/service_http_client.dart';

class KelasService {
  final String baseUrl = 'admin/kelas'; // cukup endpoint saja
  final ServiceHttpClient _httpClient = ServiceHttpClient();

  // ✅ Ambil semua kelas
  Future<List<KelasModel>> getAllKelas() async {
    final response = await _httpClient.get(baseUrl);

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final kelasResponse = KelasResponse.fromJson(jsonResponse);
      return kelasResponse.data;
    } else {
      throw Exception('Gagal mengambil data kelas');
    }
  }

Future<void> createKelas(String namaKelas, List<int> mapelIds) async {
  final Map<String, dynamic> body = {
    'nama_kelas': namaKelas,
  };

  if (mapelIds.isNotEmpty) {
    body['mapel_ids'] = mapelIds;
  }

  final response = await _httpClient.postWithToken(baseUrl, body);

  final jsonResponse = json.decode(response.body);
  print("CREATE STATUS: ${response.statusCode}");
  print("CREATE BODY: ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Gagal membuat kelas: ${jsonResponse['message']}');
  }

  if (jsonResponse['status_code'] != 201) {
    throw Exception('Server tidak mengembalikan status berhasil');
  }
}


  Future<void> updateKelas(int id, String namaKelas, List<int> mapelIds) async {
    final Map<String, dynamic> body = {'nama_kelas': namaKelas};

    if (mapelIds.isNotEmpty) {
      body['mapel_ids'] = mapelIds;
    }

    final response = await _httpClient.putWithToken('$baseUrl/$id', body);

    if (response.statusCode != 200) {
      print("UPDATE ERROR: ${response.body}");
      throw Exception('Gagal memperbarui kelas');
    }
  }

  // ✅ Hapus kelas
  Future<void> deleteKelas(int id) async {
    final response = await _httpClient.deleteWithToken('$baseUrl/$id');

    if (response.statusCode != 200) {
      print("DELETE ERROR: ${response.body}");
      throw Exception('Gagal menghapus kelas');
    }
  }
}
