abstract class SiswaEvent {}

class FetchSiswa extends SiswaEvent {}

class AddSiswa extends SiswaEvent {
  final String nama, nisn, jenisKelamin;
  final String? tanggalLahir, alamat;
  final int? kelasId;

  AddSiswa({
    required this.nama,
    required this.nisn,
    required this.jenisKelamin,
    this.tanggalLahir,
    this.alamat,
    this.kelasId,
  });
}

class UpdateSiswa extends SiswaEvent {
  final int id;
  final String nama, nisn, jenisKelamin;
  final String? tanggalLahir, alamat;
  final int? kelasId;

  UpdateSiswa({
    required this.id,
    required this.nama,
    required this.nisn,
    required this.jenisKelamin,
    this.tanggalLahir,
    this.alamat,
    this.kelasId,
  });
}

class DeleteSiswa extends SiswaEvent {
  final int id;
  DeleteSiswa(this.id);
}
