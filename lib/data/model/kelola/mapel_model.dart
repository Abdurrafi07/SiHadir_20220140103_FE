class MapelModel {
  final int id;
  final String namaMapel;
  final List<String> kelas;

  MapelModel({required this.id, required this.namaMapel, required this.kelas});

  factory MapelModel.fromJson(Map<String, dynamic> json) => MapelModel(
    id: json['id'],
    namaMapel: json['nama_mapel'],
    kelas: List<String>.from(json['kelas']),
  );
}