class SiswaModel {
  final int id;
  final String nama;
  final String nisn;
  final String jenisKelamin;
  final String? tanggalLahir;
  final String? alamat;
  final String? kelas; // nama kelas
  final int? kelasId;

  SiswaModel({
    required this.id,
    required this.nama,
    required this.nisn,
    required this.jenisKelamin,
    this.tanggalLahir,
    this.alamat,
    this.kelas,
    this.kelasId,
  });

  factory SiswaModel.fromJson(Map<String, dynamic> json) => SiswaModel(
        id: json['id'],
        nama: json['nama'],
        nisn: json['nisn'],
        jenisKelamin: json['jenis_kelamin'],
        tanggalLahir: json['tanggal_lahir'],
        alamat: json['alamat'],
        kelas: json['kelas'],
        kelasId: json['kelas_id'],
      );
}