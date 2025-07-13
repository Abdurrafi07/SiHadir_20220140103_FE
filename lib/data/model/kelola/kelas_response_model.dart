import 'package:sihadir/data/model/kelola/kelas_model.dart';

class KelasResponse {
  final String message;
  final int statusCode;
  final List<KelasModel> data;

  KelasResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory KelasResponse.fromJson(Map<String, dynamic> json) {
    return KelasResponse(
      message: json['message'],
      statusCode: json['status_code'],
      data: List<KelasModel>.from(
        (json['data'] ?? []).map((x) => KelasModel.fromMap(x)),
      ),
    );
  }
}
