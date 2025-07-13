import 'package:sihadir/data/model/kelola/jadwal_model.dart';
import 'package:sihadir/data/model/kelola/siswa_model.dart';

abstract class AbsensiState {}

class AbsensiInitial extends AbsensiState {}

class AbsensiLoading extends AbsensiState {}

class AbsensiLoaded extends AbsensiState {
  final List<JadwalModel> jadwal;
  final List<SiswaModel> siswa;

  AbsensiLoaded({required this.jadwal, required this.siswa});
}

class AbsensiSubmitting extends AbsensiState {}

class AbsensiSuccess extends AbsensiState {
  final String message;
  AbsensiSuccess(this.message);
}

class AbsensiError extends AbsensiState {
  final String message;
  AbsensiError(this.message);
}
