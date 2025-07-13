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
  final token = await ServiceHttpClient().secureStorage.read(key: 'authToken');
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
    req.files.add(await http.MultipartFile.fromPath(
      'foto',
      request.fotoPath!,
      contentType: MediaType('image', 'jpeg'),
    ));
  }

  final response = await req.send();
  return http.Response.fromStream(response);
}

}
