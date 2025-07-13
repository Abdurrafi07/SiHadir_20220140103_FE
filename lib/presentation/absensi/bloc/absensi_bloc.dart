import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sihadir/data/model/kelola/absensi_massal_request.dart';
import 'package:sihadir/services/absensi_service.dart';
import 'package:sihadir/services/jadwal_guru_service.dart';
import 'absensi_event.dart';
import 'absensi_state.dart';

class AbsensiBloc extends Bloc<AbsensiEvent, AbsensiState> {
  final JadwalGuruService jadwalService;
  final AbsensiService absensiService;

  AbsensiBloc({required this.jadwalService, required this.absensiService})
    : super(AbsensiInitial()) {
    on<LoadDataAbsensi>(_onLoadData);
    on<SubmitAbsensiMassal>(_onSubmit);
    on<FetchAllAbsensi>(_onFetchAllAbsensi);
    on<UpdateAbsensi>(_onUpdateAbsensi);
    on<DeleteAbsensi>(_onDeleteAbsensi);
  }

  Future<void> _onLoadData(
    LoadDataAbsensi event,
    Emitter<AbsensiState> emit,
  ) async {
    emit(AbsensiLoading());
    try {
      final result = await jadwalService.fetchJadwalDanSiswa();
      emit(AbsensiLoaded(jadwal: result['jadwal'], siswa: result['siswa']));
    } catch (e) {
      emit(AbsensiError(e.toString()));
    }
  }

  Future<void> _onSubmit(
    SubmitAbsensiMassal event,
    Emitter<AbsensiState> emit,
  ) async {
    emit(AbsensiSubmitting());
    try {
      final req = AbsensiMassalRequest(
        jadwalId: event.jadwalId,
        tanggal: event.tanggal,
        presensi: event.presensi,
        fotoPath: event.fotoPath,
        latitude: event.latitude,
        longitude: event.longitude,
        alamat: event.alamat,
      );
      final response = await absensiService.kirimMassal(req);
      if (response.statusCode == 201) {
        emit(AbsensiSuccess("Presensi berhasil dikirim"));
      } else {
        emit(AbsensiError("Gagal kirim presensi: ${response.body}"));
      }
    } catch (e) {
      emit(AbsensiError(e.toString()));
    }
  }

  Future<void> _onFetchAllAbsensi(
    FetchAllAbsensi event,
    Emitter<AbsensiState> emit,
  ) async {
    emit(AbsensiLoading());
    try {
      final data = await absensiService.getAllAbsensi();
      emit(AbsensiListLoaded(data));
    } catch (e) {
      emit(AbsensiError("Gagal memuat data absensi: $e"));
    }
  }

  Future<void> _onUpdateAbsensi(
    UpdateAbsensi event,
    Emitter<AbsensiState> emit,
  ) async {
    emit(AbsensiUpdating());
    try {
      final response = await absensiService.updateAbsensi(
        id: event.id,
        status: event.status,
        fotoPath: event.fotoPath,
        latitude: event.latitude,
        longitude: event.longitude,
        alamat: event.alamat,
      );

      if (response.statusCode == 200) {
        emit(AbsensiSuccess("Presensi berhasil diperbarui."));
      } else {
        emit(AbsensiError("Gagal update: ${response.body}"));
      }
    } catch (e) {
      emit(AbsensiError("Error update: $e"));
    }
  }

  Future<void> _onDeleteAbsensi(
    DeleteAbsensi event,
    Emitter<AbsensiState> emit,
  ) async {
    emit(AbsensiDeleting());
    try {
      final response = await absensiService.deleteAbsensi(event.id);

      if (response.statusCode == 200) {
        emit(AbsensiSuccess("Presensi berhasil dihapus."));
      } else {
        emit(AbsensiError("Gagal menghapus: ${response.body}"));
      }
    } catch (e) {
      emit(AbsensiError("Error menghapus: $e"));
    }
  }
}