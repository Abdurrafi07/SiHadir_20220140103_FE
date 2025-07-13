class GuruModel {
  final int id;
  final String nama;
  final String email;
  final String? kelasDiampu; // 👈 sekarang hanya nama kelas (String)

  GuruModel({
    required this.id,
    required this.nama,
    required this.email,
    this.kelasDiampu,
  });

  factory GuruModel.fromJson(Map<String, dynamic> json) {
    return GuruModel(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      kelasDiampu: json['kelas_diampu'], // ini udah string dari API
    );
  }
}
