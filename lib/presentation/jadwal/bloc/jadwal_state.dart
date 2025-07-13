import 'package:sihadir/data/model/kelola/jadwal_model.dart';

abstract class JadwalState {}

class JadwalInitial extends JadwalState {}

class JadwalLoading extends JadwalState {}

class JadwalLoaded extends JadwalState {
  final List<JadwalModel> jadwalList;

  JadwalLoaded(this.jadwalList);
}

class JadwalError extends JadwalState {
  final String message;

  JadwalError(this.message);
}
