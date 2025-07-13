import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sihadir/data/model/kelola/absensi_massal_request.dart';
import 'package:sihadir/services/service_http_client.dart';

class AbsensiService {
  final String baseUrl;
  AbsensiService(this.baseUrl);

  Future<http.Response> kirimMassal(AbsensiMassalRequest request) async {
    final uri = Uri.parse('$baseUrl/absensi/massal');
    final token = await ServiceHttpClient().secureStorage.read(
      key: 'authToken',
    );
    var req = http.MultipartRequest('POST', uri);

    req.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    req.fields['jadwal_id'] = request.jadwalId.toString();
    req.fields['tanggal'] = request.tanggal;
    req.fields['latitude'] = request.latitude?.toString() ?? '';
    req.fields['longitude'] = request.longitude?.toString() ?? '';
    req.fields['alamat'] = request.alamat ?? '';

    for (int i = 0; i < request.presensi.length; i++) {
      final p = request.presensi[i];
      req.fields['presensi[$i][siswa_id]'] = p.siswaId.toString();
      req.fields['presensi[$i][status]'] = p.status;
    }

    if (request.fotoPath != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          request.fotoPath!,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await req.send();
    return http.Response.fromStream(response);
  }

  Future<List<dynamic>> getAllAbsensi() async {
    final uri = Uri.parse('$baseUrl/absensi');
    final token = await ServiceHttpClient().secureStorage.read(
      key: 'authToken',
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data absensi');
    }
  }

  Future<http.Response> updateAbsensi({
    required int id,
    String? status,
    String? fotoPath,
    double? latitude,
    double? longitude,
    String? alamat,
  }) async {
    final uri = Uri.parse('$baseUrl/absensi/$id');
    final token = await ServiceHttpClient().secureStorage.read(
      key: 'authToken',
    );
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

    // Laravel pakai POST + _method = PATCH
    request.fields['_method'] = 'PATCH';

    if (status != null) request.fields['status'] = status;
    if (latitude != null) request.fields['latitude'] = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();
    if (alamat != null) request.fields['alamat'] = alamat;

    if (fotoPath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          fotoPath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> deleteAbsensi(int id) async {
    final uri = Uri.parse('$baseUrl/absensi/$id');
    final token = await ServiceHttpClient().secureStorage.read(
      key: 'authToken',
    );

    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Gagal menghapus data presensi');
    }
  }
}
