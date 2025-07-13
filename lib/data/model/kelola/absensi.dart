class AbsensiModel {
  final int? id;
  final int siswaId;
  final int jadwalId;
  final String tanggal;
  final String status;
  final String? foto;
  final double? latitude;
  final double? longitude;

  AbsensiModel({
    this.id,
    required this.siswaId,
    required this.jadwalId,
    required this.tanggal,
    required this.status,
    this.foto,
    this.latitude,
    this.longitude,
  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      id: json['id'],
      siswaId: json['siswa_id'],
      jadwalId: json['jadwal_id'],
      tanggal: json['tanggal'],
      status: json['status'],
      foto: json['foto'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siswa_id': siswaId,
      'jadwal_id': jadwalId,
      'tanggal': tanggal,
      'status': status,
      'foto': foto,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
