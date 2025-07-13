import 'package:sihadir/data/model/kelola/siswa_model.dart';

abstract class SiswaState {}

class SiswaInitial extends SiswaState {}

class SiswaLoading extends SiswaState {}

class SiswaLoaded extends SiswaState {
  final List<SiswaModel> siswaList;
  SiswaLoaded(this.siswaList);
}

class SiswaError extends SiswaState {
  final String message;
  SiswaError(this.message);
}
