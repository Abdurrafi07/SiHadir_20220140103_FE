class JadwalModel {
  final int id;
  final int kelasId;
  final int mapelId;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String? namaKelas;
  final String? namaMapel;

  JadwalModel({
    required this.id,
    required this.kelasId,
    required this.mapelId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    this.namaKelas,
    this.namaMapel,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'],
      kelasId: json['kelas_id'],
      mapelId: json['mapel_id'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      namaKelas: json['kelas']?['nama_kelas'],
      namaMapel: json['mapel']?['nama_mapel'],
    );
  }
}