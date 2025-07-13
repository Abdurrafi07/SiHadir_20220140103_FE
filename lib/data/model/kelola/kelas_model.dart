class KelasModel {
  final int id;
  final String namaKelas;
  final List<String> mapel;

  KelasModel({
    required this.id,
    required this.namaKelas,
    required this.mapel,
  });

  factory KelasModel.fromMap(Map<String, dynamic> json) {
    return KelasModel(
      id: json['id'],
      namaKelas: json['nama_kelas'],
      mapel: List<String>.from(json['mapel']),
    );
  }
}
