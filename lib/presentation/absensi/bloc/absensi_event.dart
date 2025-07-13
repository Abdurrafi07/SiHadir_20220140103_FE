import 'package:sihadir/data/model/kelola/absensi_massal_request.dart';

abstract class AbsensiEvent {}

class LoadDataAbsensi extends AbsensiEvent {}

class SubmitAbsensiMassal extends AbsensiEvent {
  final int jadwalId;
  final String tanggal;
  final List<PresensiItem> presensi;
  final String? fotoPath;
  final double? latitude;
  final double? longitude;
  final String? alamat;

  SubmitAbsensiMassal({
    required this.jadwalId,
    required this.tanggal,
    required this.presensi,
    this.fotoPath,
    this.latitude,
    this.longitude,
    this.alamat,
  });
}

class FetchAllAbsensi extends AbsensiEvent {}

class UpdateAbsensi extends AbsensiEvent {
  final int id;
  final String? status;
  final String? fotoPath;
  final double? latitude;
  final double? longitude;
  final String? alamat;

  UpdateAbsensi({
    required this.id,
    this.status,
    this.fotoPath,
    this.latitude,
    this.longitude,
    this.alamat,
  });
}

class DeleteAbsensi extends AbsensiEvent {
  final int id;

  DeleteAbsensi(this.id);
}