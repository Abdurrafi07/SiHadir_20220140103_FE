class PresensiItem {
  final int siswaId;
  final String status;

  PresensiItem({required this.siswaId, required this.status});

  Map<String, dynamic> toJson() => {
        'siswa_id': siswaId,
        'status': status,
      };
}

class AbsensiMassalRequest {
  final int jadwalId;
  final String tanggal;
  final List<PresensiItem> presensi;
  final String? fotoPath;
  final double? latitude;
  final double? longitude;
  final String? alamat; 

  AbsensiMassalRequest({
    required this.jadwalId,
    required this.tanggal,
    required this.presensi,
    this.fotoPath,
    this.latitude,
    this.longitude,
    this.alamat,
  });
}
